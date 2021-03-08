import 'dart:io';
import 'dart:math';

import 'package:SILPH_Q/app/home/care-info/careinfo_widget.dart';
import 'package:SILPH_Q/app/home/history/history_widget.dart';
import 'package:SILPH_Q/app/home/init-form/initform_widget.dart';
import 'package:SILPH_Q/app/home/question-form/questionform_widget.dart';
import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/rsa_toolkit.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:string_validator/string_validator.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _codeStatus = 'green';

  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();
  NetworkLayer _networkLayer = new NetworkLayer();
  RSAToolkit _rsaToolkit = new RSAToolkit();

  ScanResult scanResult;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  var _autoEnableFlash = false;
  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;

  String userName;
  String userMail;
  String userNumb;
  String userCode;
  String userAddr;

  String _userName;
  String _userMail;
  String _userNumb;
  String _userCode;
  String _userAddr;

  bool _dataHide = false;
  bool profiled = true;

  bool _startedCameraSession = false;
  bool _viewRequestCode = false;
  bool _buttonRelease = true;

  bool publicKeyLoaded = false;
  String publicKey = '\0';

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await synchronize();
    _refreshController.refreshCompleted();
  }

  saveUserData(payload) async {
    await _networkLayer.saveLocalData(payload);
    await _networkLayer.registerMe(3);
    await synchronize();

    setState(() {
      userName = payload['userName'];
      userCode = payload['userCode'];
      userMail = payload['userMail'];
      userNumb = payload['userNumb'];
      userAddr = payload['userAddr'];

      _userName = userName;
      _userCode = userCode;
      _userMail = userMail;
      _userNumb = userNumb;
      _userAddr = userAddr;
    });
  }

  toggleQr() async {
    _viewRequestCode = false;
    final spotted = await spotScan();
    if (isUUID(spotted)) {
      setState(() => _startedCameraSession = false);
      final check = await _networkLayer.takeReservation(spotted);

      if (check != false)
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 3),
          titleText: Text(
            'CHECK-IN ESEGUITO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFBFCFF),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          messageText: Text(
            'SPOT CORRETTAMENTE SCANNERIZZATO E REGISTRATO',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFFBFCFF)),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          backgroundColor: Color(0xFF1C6E8C).withOpacity(.95),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context);
      else
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 3),
          titleText: Text(
            'ERRORE NEL CHECK-IN',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFBFCFF),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          messageText: Text(
            'ERRORE NELLA SCANSIONE...\nPER FAVORE RIPROVA',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFFBFCFF)),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          backgroundColor: Color(0xFFFF3D71).withOpacity(.95),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context);
    }
  }

  synchronize() async {
    final defcon = await _networkLayer.syncState();
    profiled = defcon != 0;

    setState(() => _codeStatus = !profiled
        ? 'black'
        : defcon == 3 ? 'green' : defcon == 2 ? 'yellow' : 'red');

//    if (!profiled) _displayMedSurvey();
  }

  evaluateSurvey(int survey) async {
    var defcon;
    if (survey >= 89)
      defcon = 1;
    else if (survey >= 45)
      defcon = 2;
    else
      defcon = 3;

    setState(() {
      profiled = true;
      _codeStatus = defcon == 1 ? 'red' : defcon == 2 ? 'yellow' : 'green';
    });
  }

  riskDetected() {
    setState(() {
      this._codeStatus = 'red';
    });
  }

  _dataMask() {
    setState(() {
      if (_dataHide) {
        userNumb =
            _userNumb.substring(0, 3) + ' ' + ('*' * (userNumb.length - 3));
        userName =
            _userName.substring(0, 3) + ' ' + ('*' * (userName.length - 3));
        userAddr = _userAddr.substring(0, 3) +
            ' ' +
            ('*' * ((userAddr.length - 3)).round());
        userCode =
            _userCode.substring(0, 3) + ' ' + ('*' * (userCode.length - 3));
        userMail =
            _userMail.substring(0, 3) + ' ' + ('*' * (userMail.length - 3));
      } else {
        userNumb = _userNumb;
        userName = _userName;
        userAddr = _userAddr;
        userCode = _userCode;
        userMail = _userMail;
      }
    });
  }

  _displayInfo() {
    showModalBottomSheet(
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: CareInfoWidget(),
          ),
        );
      },
    );
  }

  _displayInitForm() {
    showModalBottomSheet(
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: InitFormWidget(
              saveElement: saveUserData,
            ),
          ),
        );
      },
    );
  }

  _displayMedSurvey() {
    showModalBottomSheet(
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: QuestionFormWidget(
              saveElement: evaluateSurvey,
            ),
          ),
        );
      },
    );
  }

  _displayHistory() {
    showModalBottomSheet(
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: new Container(
            height: MediaQuery.of(context).size.height,
            child: HistoryWidget(),
          ),
        );
      },
    );
  }

  spotScan() async {
    return await scan();
  }

  Future<String> scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": 'Indietro',
          "flash_on": 'Flash ON',
          "flash_off": 'Flash OFF',
        },
        restrictFormat: [BarcodeFormat.qr],
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);
      return result.rawContent;
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
        return result.rawContent;
      } else {
        result.rawContent = 'Unknown error: $e';
        return result.rawContent;
      }
    }
  }

//  void _onQRViewCreated(QRViewController controller) async {
//    const max = 1;
//    var mutex = 0;
//
//    if (qrController == null) qrController = controller;
//
//    controller.scannedDataStream.listen((scanData) async {
//      if (mutex < max) {
//        mutex++;
//        if (isUUID(scanData)) {
//          qrController.dispose();
//
//          setState(() => _startedCameraSession = false);
//
//          final check = await _networkLayer.takeReservation(scanData);
//          if (check != false)
//            Flushbar(
//              animationDuration: Duration(milliseconds: 500),
//              duration: Duration(seconds: 5),
//              titleText: Text(
//                'CHECK-IN ESEGUITO',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  color: Color(0xFFFBFCFF),
//                  fontWeight: FontWeight.bold,
//                  letterSpacing: 2,
//                ),
//              ),
//              messageText: Text(
//                'SPOT CORRETTAMENTE SCANNERIZZATO E REGISTRATO',
//                textAlign: TextAlign.center,
//                style: TextStyle(color: Color(0xFFFBFCFF)),
//              ),
//              margin: EdgeInsets.symmetric(
//                horizontal: 20,
//                vertical: 40,
//              ),
//              backgroundColor: Color(0xFF1C6E8C),
//              borderRadius: 8,
//              flushbarPosition: FlushbarPosition.TOP,
//            )..show(context);
//          else
//            Flushbar(
//              animationDuration: Duration(milliseconds: 500),
//              duration: Duration(seconds: 5),
//              titleText: Text(
//                'ERRORE NEL CHECK-IN',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  color: Color(0xFFFBFCFF),
//                  fontWeight: FontWeight.bold,
//                  letterSpacing: 2,
//                ),
//              ),
//              messageText: Text(
//                'ERRORE NELLA SCANSIONE...\nPER FAVORE RIPROVA',
//                textAlign: TextAlign.center,
//                style: TextStyle(color: Color(0xFFFBFCFF)),
//              ),
//              margin: EdgeInsets.symmetric(
//                horizontal: 20,
//                vertical: 40,
//              ),
//              backgroundColor: Color(0xFFFF3D71),
//              borderRadius: 8,
//              flushbarPosition: FlushbarPosition.TOP,
//            )..show(context);
//        } else {
//          mutex--;
//        }
//      }
//    });
//  }

  @override
  void initState() {
    super.initState();
    synchronize();

    _rsaToolkit.initRSAStrategy().then((pKey) async {
      userNumb = await _safeZoneHandler.getTelNumber();
      userName = await _safeZoneHandler.getFullName();
      userAddr = await _safeZoneHandler.getAddress();
      userCode = await _safeZoneHandler.getIDCode();
      userMail = await _safeZoneHandler.getEmail();

      _userName = userName;
      _userCode = userCode;
      _userMail = userMail;
      _userNumb = userNumb;
      _userAddr = userAddr;

      profiled = await _safeZoneHandler.getRegStatus();

      setState(() {
        publicKey = pKey;
        publicKeyLoaded = true;

        if (userName == null) this._displayInitForm();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                Color(0xFF605856),
                Color(0xFFD0CCD0),
                Color(0xFFD0CCD0),
                Color(0xFFD0CCD0),
              ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  tileMode: TileMode.clamp)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              padding: EdgeInsets.only(top: 35),
              height: _codeStatus == 'green'
                  ? MediaQuery.of(context).size.height - 80
                  : MediaQuery.of(context).size.height,
              child: SmartRefresher(
                enablePullDown: true,
                dragStartBehavior: DragStartBehavior.down,
                physics: BouncingScrollPhysics(),
                header: WaterDropMaterialHeader(
                  backgroundColor: Color(0xFF274156).withAlpha(215),
                  distance: 100,
                  offset: 40,
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, int) {
                    return Column(children: <Widget>[
                      SizedBox(height: 45),
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        color: Color(0xFFFBFCFF).withAlpha(180),
                        semanticContainer: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        child: Container(
                          alignment: FractionalOffset(0.5, 0),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: publicKeyLoaded
                                ? Container(
                                    child: _startedCameraSession
                                        ? ClipRRect(
                                            child: Stack(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      50,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: new Container(),
                                                ),
                                                Transform.scale(
                                                  scale: .5,
                                                  child: Image.asset(
                                                      'assets/qr-overlap.png'),
                                                )
                                              ],
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                          )
                                        : Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                50,
                                            alignment: FractionalOffset(.5, .5),
                                            child: Transform.scale(
                                              scale: .99,
                                              child: new PrettyQr(
                                                  typeNumber: 19,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      60,
                                                  data: publicKey,
                                                  elementColor:
//                                          !profiled
//                                              ? Colors.black26:
                                                      _codeStatus == 'green'
                                                          ? Color(0xFF23b87c)
//                                                          ? Colors.black87
                                                          : _codeStatus ==
                                                                  'yellow'
                                                              ? Color(
                                                                  0xFFE6A100)
                                                              : _codeStatus == 'red'
                                                                  ? Colors
                                                                      .redAccent
                                                                  : Colors
                                                                      .white12,
                                                  errorCorrectLevel:
                                                      QrErrorCorrectLevel.L,
                                                  roundEdges: true),
                                            ),
                                          ),
                                  )
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.width - 50,
                                    width: 360,
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Container(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5,
                                            ),
                                            margin: EdgeInsets.only(top: 100),
                                            height: 120,
                                            width: 120,
                                          ),
                                        ),
                                        Container(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(16),
                                              ),
                                              color: Color(0xFF605856)
                                                  .withOpacity(.11),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              'Genero le Chiavi RSA di Cifratura ...\nPotrebbe volerci un po\' di tempo',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF605856),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          alignment: FractionalOffset(.5, .2),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      !publicKeyLoaded ? new Container() : SizedBox(height: 20),
                      !publicKeyLoaded
                          ? new Container()
                          : Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              color: Color(0xFFFBFCFF).withAlpha(180),
                              semanticContainer: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  children: <Widget>[
                                    _startedCameraSession ||
                                            _codeStatus != 'green'
                                        ? Container()
                                        : Positioned(
                                            bottom: 0,
                                            right: 18,
                                            top: 0,
                                            child: GestureDetector(
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 4),
                                                decoration: BoxDecoration(
                                                    color: _viewRequestCode
                                                        ? Color(0xFF274156)
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(16),
                                                    )),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.code,
                                                    size: 25,
                                                    color: _viewRequestCode
                                                        ? Color(0xFFD0CCD0)
                                                        : Color(0xFF274156),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() =>
                                                    _viewRequestCode =
                                                        !_viewRequestCode);
                                              },
                                            ),
                                          ),
                                    _viewRequestCode
                                        ? Container(
                                            height: 80,
                                            alignment: FractionalOffset(.5, .5),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Center(
                                                  child: Text(
                                                    '_REQUEST_CODE_',
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      letterSpacing: 2,
                                                      color: Color(0xFF274156),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(
                                            height: 80,
                                            alignment: FractionalOffset(.5, .5),
                                            child: Column(
                                              children: <Widget>[
                                                Center(
                                                  child: _startedCameraSession
                                                      ? Text(
                                                          '[ INQUADRA IL QR ]',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            letterSpacing: 2,
                                                            color: Color(
                                                                0xFF274156),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : Text(
                                                          _codeStatus == 'green'
                                                              ? '[ QR VERDE ]'
                                                              : _codeStatus ==
                                                                      'yellow'
                                                                  ? '[ QR GIALLO ]'
                                                                  : _codeStatus ==
                                                                          'red'
                                                                      ? '[ QR ROSSO ]'
                                                                      : '',
                                                          textAlign:
                                                              TextAlign.justify,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            letterSpacing: 2,
                                                            color: Color(
                                                                0xFF274156),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                ),
                                                Center(
                                                  child: _startedCameraSession
                                                      ? Container(height: 0)
                                                      : Text(
                                                          _codeStatus == 'green'
                                                              ? 'Circolazione Consentita'
                                                              : _codeStatus ==
                                                                      'yellow'
                                                                  ? 'È stato rilevato un caso di contagio tra le persone che hanno fatto la stessa strada che hai fatto anche tu.\n\nPer adesso preferiamo non correre rischi di ulteriori contagi, pertanto non ti è consentito l\'accesso e sei inoltre invitato a seguire una quarantena volontaria di 10 giorni.'
                                                                  : _codeStatus ==
                                                                          'red'
                                                                      ? 'È stato rilevato un alto pericolo di contagio dai dati che ci hai fornito, pertanto sei invitato a restare a casa e contattare le autorità competenti qualora dovessi sviluppare sintomi.'
                                                                      : '',
                                                          textAlign: _codeStatus ==
                                                                  'green'
                                                              ? TextAlign.center
                                                              : _codeStatus ==
                                                                      'yellow'
                                                                  ? TextAlign
                                                                      .justify
                                                                  : TextAlign
                                                                      .justify,
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF274156),
                                                          ),
                                                        ),
                                                ),
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                      !publicKeyLoaded ||
                              _codeStatus != 'green' ||
                              _startedCameraSession
                          ? new Container()
                          : Card(
                              color: Color(0xFFD0CCD0).withAlpha(200),
                              margin: EdgeInsets.fromLTRB(20, 20, 20, 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                alignment: FractionalOffset(.5, .5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(width: 70),
                                    Text(
                                      "PASSPORT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF274156),
                                        letterSpacing: 2,
                                        fontSize: 16,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _dataHide = !_dataHide;
                                        _dataMask();
                                      },
                                      child: Container(
                                        width: 70,
                                        height: 50,
                                        color: Colors.transparent,
                                        padding: EdgeInsets.only(
                                          right: 20,
                                          left: 20,
                                        ),
                                        child: Icon(
                                          Icons.remove_red_eye,
                                          size: 25,
                                          color: _dataHide
                                              ? Color(0xFF605856).withAlpha(64)
                                              : Color(0xFF274156),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      !publicKeyLoaded ||
                              _codeStatus != 'green' ||
                              _startedCameraSession
                          ? new Container()
                          : Container(
                              margin: EdgeInsets.symmetric(horizontal: 23),
                              child: Container(
                                alignment: FractionalOffset(0.5, 0),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          userName ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF274156),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          userCode ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF274156),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 23),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          userNumb ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF274156),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          userMail ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF274156),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 23),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          userAddr ?? '',
                                          style: TextStyle(
                                            color: Color(0xFF274156),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                      !publicKeyLoaded ? new Container() : SizedBox(height: 35),
//                      SizedBox(height: 12),
//                      _codeStatus != 'black' || !publicKeyLoaded
//                          ? new Container()
//                          : Container(
//                              height: 200,
//                              margin: EdgeInsets.symmetric(horizontal: 23),
//                              child: Container(
//                                alignment: FractionalOffset(0.5, 0),
//                                child: FloatingActionButton.extended(
//                                  backgroundColor: Color(0xFFE6A100),
//                                  isExtended: true,
//                                  onPressed: () {
//                                    _displayMedSurvey();
//                                  },
//                                  label: Container(
//                                    child: Text(
//                                      'Autovalutazione',
//                                      textAlign: TextAlign.center,
//                                      style: TextStyle(
//                                        fontSize: 14.0,
//                                        fontWeight: FontWeight.bold,
//                                      ),
//                                    ),
//                                    width: 240,
//                                  ),
//                                  icon: Icon(Icons.healing),
//                                ),
//                              ),
//                            )
                    ]);
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 46, bottom: 10),
            height: 80,
//            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xFFD0CCD0)),
            child: Text(
              'SILPH CARE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontFamily: "Orbitron-black",
                letterSpacing: 7.5,
                color: Color(0xFF605856),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        _codeStatus != 'green'
            ? Container(height: 0)
            : Positioned(
                bottom: 0,
                left: 0,
                child: (!publicKeyLoaded)
                    ? new Container()
                    : Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
                        height: Platform.isAndroid ? 70 : 80,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                            color: Color(0xFFD0CCD0).withAlpha(100),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16),
                              topLeft: Radius.circular(16),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: 80,
                              alignment: FractionalOffset(1, 0),
                              child: FloatingActionButton.extended(
                                backgroundColor: Color(0xFF274156),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                isExtended: true,
                                onPressed: _displayHistory,
                                label: Container(
                                  child: Text(''),
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(
                                    Icons.history,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: FractionalOffset(1, 0),
                              height: 45,
                              child: FloatingActionButton.extended(
                                backgroundColor: _buttonRelease
                                    ? Color(0xFF274156)
                                    : Color(0xFF274156).withOpacity(.46),
                                isExtended: true,
                                onPressed: toggleQr,
                                label: Container(
                                  child: Text(
                                    _startedCameraSession
                                        ? 'Indietro'
                                        : 'QR Scan',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _buttonRelease
                                          ? Color(0xFFFBFCFF)
                                          : Colors.transparent,
                                    ),
                                  ),
                                  width: 125,
                                ),
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    _startedCameraSession
                                        ? Icons.arrow_back
                                        : Icons.settings_overscan,
                                    size: 28,
                                    color: _buttonRelease
                                        ? Color(0xFFFBFCFF)
                                        : Colors.transparent,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(right: 18, top: 40, bottom: 10),
            height: 80,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(16),
                ),
              ),
              padding: EdgeInsets.all(0),
              child: Icon(
                Icons.info_outline,
                color: Color(0xFF605856),
              ),
              onPressed: () {
                _displayInfo();
              },
            ),
          ),
        ),
        !publicKeyLoaded
            ? Container()
            : Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 18, top: 40, bottom: 10),
                  height: 80,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    padding: EdgeInsets.all(0),
                    child: Icon(
                      Icons.perm_identity,
                      color: Color(0xFF605856),
                    ),
                    onPressed: () {
                      _displayInitForm();
                    },
                  ),
                ),
              ),
      ],
    );
  }
}
