import 'dart:io';
import 'dart:math';

import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/addplace/addplace_widget.dart';
import 'package:SILPH_Q/app/home/care-info/careinfo_widget.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/home/infobox/infobox_widget.dart';
import 'package:SILPH_Q/app/home/init-form/initform_widget.dart';
import 'package:SILPH_Q/app/home/listplace/listplace_widget.dart';
import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:SILPH_Q/app/services/socket-layer.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:string_validator/string_validator.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc = AppModule.to.getBloc();

  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();
  NetworkLayer _networkLayer = new NetworkLayer();
  SocketLayer _socketLayer = new SocketLayer();

  ScanResult scanResult;

  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  GlobalKey qrKey = new GlobalKey();

  bool _loggedIn = false;
  bool _startedCameraSession = false;
  bool _capacityExceed = false;

  List placeList;

  hasSelectSpot(List<dynamic> data) {
    final _data = data.where((w) => w['selected']);
    return _data.length > 0;
  }

  _loginDone(val) {
    setState(() {
      _loggedIn = val;
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
          heightFactor: .8,
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
      isScrollControlled: false,
      useRootNavigator: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .5,
          child: new Container(
              height: MediaQuery.of(context).size.height,
              child: InitFormWidget(
                loginDone: _loginDone,
              )),
        );
      },
    );
  }

  _displayAddSpot() async {
    final spot = await spotScan();
    if (isUUID(spot))
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
            heightFactor: .6,
            child: new Container(
              height: MediaQuery.of(context).size.height,
              child: AddPlace(spotId: spot),
            ),
          );
        },
      );
  }

  //

  spotScan() async {
    return await scan();
  }

  qRScan() async {
    final res = await scan();

    if (res.startsWith('-----BEGIN RSA PUBLIC KEY-----')) {
      scannedAction(res);
    }

    setState(() {
      _startedCameraSession = false;
    });
  }

  scannedAction(pubKey) {
    final spot = _homeBloc.placeList.firstWhere((f) => f['selected']);

    switch (_homeBloc.currentMode) {
      case 0: // ENTRANCE
        _socketLayer.enterPlace(
          spot['sid'],
          pubKey,
        );

        if (_capacityExceed) {
          Flushbar(
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 1),
            isDismissible: true,
            messageText: Text(''),
            padding: EdgeInsets.only(top: 30),
            titleText: Center(
              child: Text(
                'CAPIENZA MASSIMA RAGGIUNTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFBFCFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            backgroundColor: Color(0xFFCCA03D).withOpacity(.95),
            borderRadius: 8,
            flushbarPosition: FlushbarPosition.TOP,
          )..show(context);
        } else {
          Flushbar(
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 1),
            messageText: Text(''),
            padding: EdgeInsets.only(top: 30),
            titleText: Center(
              child: Text(
                'INGRESSO EFFETTUATO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFBFCFF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            backgroundColor: Color(0xFF1C6E8C).withOpacity(.95),
            borderRadius: 8,
            flushbarPosition: FlushbarPosition.TOP,
          )..show(context);
        }
        break;
      case 1: // CHECK
        _networkLayer
            .checkQueue(
          pubKey,
          spot['sid'],
        )
            .then((onValue) {
          if (onValue == true)
            Flushbar(
              animationDuration: Duration(milliseconds: 500),
              duration: Duration(seconds: 3),
              titleText: Text(
                'ACCESSO CONSENTITO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFBFCFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              messageText: Text(
                'UTENTE PROVENIENTE DALLA FILA CORRETTA',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFBFCFF)),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              backgroundColor: Color(0xFF1A8A5D).withOpacity(.95),
              borderRadius: 8,
              flushbarPosition: FlushbarPosition.TOP,
            )..show(context);
          else
            Flushbar(
              animationDuration: Duration(milliseconds: 500),
              duration: Duration(seconds: 3),
              titleText: Text(
                'ACCESSO NEGATO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFBFCFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              messageText: Text(
                'UTENTE PROVENIENTE DALLA FILA SBAGLIATA',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFBFCFF)),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),
              backgroundColor: Color(0xFFE53665).withOpacity(.95),
              borderRadius: 8,
              flushbarPosition: FlushbarPosition.TOP,
            )..show(context);
        });
        break;
      case 2: // EXIT
        _socketLayer.exitOne(
          pubKey,
          spot['sid'],
        );

        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 1),
          messageText: Text(''),
          padding: EdgeInsets.only(top: 30),
          titleText: Center(
            child: Text(
              'USCITA EFFETTUATA',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFBFCFF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          backgroundColor: Color(0xFF1C6E8C).withOpacity(.95),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
        )..show(context);

        break;
    }
  }

  _capacityCallback(exceeded) {
    setState(() {
      _capacityExceed = exceeded;
    });
  }

  emitRefresh(i) {
    _socketLayer.spotRefresh(_homeBloc.placeList[i]['sid']);
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

  @override
  void initState() {
    super.initState();
    _networkLayer.firstAccess().then((grant) {
      if (grant) {
        setState(() => _loggedIn = true);
      } else {
        _displayInitForm();
      }
    }).catchError((e) {
      _displayInitForm();
    }).then((chain) {
      _safeZoneHandler.getSelectedMode().then((mode) {
        mode != null
            ? _homeBloc.opModeEventSink.add(mode)
            : _homeBloc.opModeEventSink.add(0);
      });
    }).then((value) {
      _safeZoneHandler.getSavedSpots().then((spots) {
        _homeBloc.placeListEventSink.add(spots);

        if (spots.length > 0) {
          final spot = spots.firstWhere((f) => f['selected'], orElse: spots[0]);
          _socketLayer.initLayer(spot: spot['sid']);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
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
                tileMode: TileMode.clamp,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Container(
                margin: EdgeInsets.fromLTRB(16, 50, 16, 0),
                width: MediaQuery.of(context).size.width,
//                constraints: BoxConstraints(
//                  maxHeight: Platform.isAndroid
//                      ? MediaQuery.of(context).size.height - 120
//                      : MediaQuery.of(context).size.height - 130,
//                ),
                height:
//                Platform.isAndroid
//                    ? MediaQuery.of(context).size.height - 120
//                    : MediaQuery.of(context).size.height - 130,
                    MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                child: !_loggedIn
                    ? Center(
                        child: Container(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : ListView(
                        children: <Widget>[
                          SizedBox(height: 30),
                          Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            color: Color(0xFFFBFCFF).withAlpha(180),
                            semanticContainer: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: Container(
                              height: 240,
                              alignment: FractionalOffset(0.5, 0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 0,
                                ),
                                child: Container(
                                  child: new InfoBoxWidget(
                                    triggerCapacityExceed: _capacityCallback,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          _startedCameraSession
                              ? Column(
                                  children: <Widget>[
                                    Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      color: Color(0xFFFBFCFF).withAlpha(180),
                                      semanticContainer: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: FractionalOffset(0.5, 0.5),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 8,
                                                  ),
                                                  child: Text(
                                                    'TIPOLOGIA DI VERIFICA',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      letterSpacing: 2,
                                                      color: Color(0xFF274156),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      24, 8, 24, 8),
                                              child: _startedCameraSession
                                                  ? Container(height: 0)
                                                  : Text(
                                                      '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF274156),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      color: Color(0xFFFBFCFF).withAlpha(180),
                                      semanticContainer: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        alignment: FractionalOffset(0.5, 0.5),
                                        child: FlatButton(
                                          color: Color(0xFFCCA03D),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                            width: 175,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0),
                                                      child: Icon(
                                                        Icons.feedback,
                                                        color:
                                                            Color(0xFFFBFCFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'SENZA CODICE',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFFFBFCFF),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          onPressed: () {
                                            final pubKey = 'no_public_key';
                                            scannedAction(pubKey);

                                            setState(() =>
                                                _startedCameraSession = false);
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      color: Color(0xFFFBFCFF).withAlpha(180),
                                      semanticContainer: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 4),
                                        alignment: FractionalOffset(0.5, 0.5),
                                        child: FlatButton(
                                          color: Color(0xFF1A8A5D),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                          ),
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                            width: 175,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 0),
                                                      child: Icon(
                                                        Icons.perm_identity,
                                                        color:
                                                            Color(0xFFFBFCFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'CON CODICE',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFFFBFCFF),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          onPressed: () {
                                            qRScan();
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                )
                              : Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  color: Color(0xFFFBFCFF).withAlpha(180),
                                  semanticContainer: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  child: Container(
                                    height:
                                        (MediaQuery.of(context).size.height /
                                                3) +
                                            60,
                                    alignment: FractionalOffset(0.5, 0.2),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0, bottom: 16),
                                            child: new ListPlace(
                                              emit: emitRefresh,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          SizedBox(height: 60),
                        ],
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
            padding: const EdgeInsets.only(top: 48, bottom: 10),
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFD0CCD0),
            ),
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
        Positioned(
          top: 75,
          left: 0,
          right: 0,
          child: Container(
            height: 20,
//            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color(0xFFD0CCD0),
            ),
            child: Text(
              'GUARD',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontFamily: "Orbitron-black",
                letterSpacing: 7.5,
                color: Color(0xFF605856),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        !_loggedIn
            ? Container()
            : Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  padding: Platform.isAndroid
                      ? EdgeInsets.fromLTRB(8, 12, 8, 12)
                      : EdgeInsets.fromLTRB(8, 12, 8, 24),
                  height: Platform.isAndroid ? 70 : 80,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFada6a4),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: StreamBuilder<Object>(
                    stream: _homeBloc.placeListState,
                    initialData: _homeBloc.placeList,
                    builder: (context, snapshot) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            width: 80,
                            child: _startedCameraSession
                                ? Container()
                                : FloatingActionButton(
                                    backgroundColor: Color(0xFF274156),
                                    isExtended: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                    ),
                                    onPressed: _displayAddSpot,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Icon(
                                        Icons.add_circle_outline,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                          ),
                          !hasSelectSpot(snapshot.data)
                              ? Container(
                                  alignment: FractionalOffset(1, 0),
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        'Seleziona SPOT',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          letterSpacing: .5,
                                          fontFamily: 'Poppins-Reg',
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF274156),
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    width: 175,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFD0CCD0).withOpacity(.1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                      border: Border.all(
                                        color: Color(0xFF274156),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 45,
                                  alignment: FractionalOffset(1, 0),
                                  child: FloatingActionButton.extended(
                                    backgroundColor: Color(0xFF274156),
                                    isExtended: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(
                                        () {
                                          _startedCameraSession =
                                              !_startedCameraSession;

                                          emitRefresh(
                                            _homeBloc.placeList.indexOf(
                                              (element) => element['selected'],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    label: Container(
                                      child: Text(
                                        _startedCameraSession
                                            ? 'Indietro'
                                            : 'QR Scan',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xFFFBFCFF),
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
                                        color: Color(0xFFFBFCFF),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ),
              ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(right: 18, top: 38, bottom: 10),
            height: 90,
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
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.only(left: 18, top: 38, bottom: 10),
            height: 90,
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
