import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/home/infobox/infobox_widget.dart';
import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:string_validator/string_validator.dart';

class AddPlace extends StatefulWidget {
  final List<dynamic> historyTracks = new List();

  final String spotId;

  AddPlace({this.spotId});

  @override
  _AddPlaceWidgetState createState() => _AddPlaceWidgetState();
}

class _AddPlaceWidgetState extends State<AddPlace> {
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();
  NetworkLayer _networkLayer = new NetworkLayer();

  HomeBloc _homeBloc = AppModule.to.getBloc();

  GlobalKey qrKey = new GlobalKey();

//  QRViewController qrController;

  List<dynamic> trackList;

  bool _startedCameraSession = false;
  bool scannedSpot = false;

  String _spotId;
  String _spotName;
  String _spotAddress;
  String _spotCapacity;

  saveSpot() async {
    final list = await _safeZoneHandler.getSavedSpots();
    list.add({
      "sid": _spotId,
      "nameidentity": _spotName,
      "address": _spotAddress,
      "capacity": _spotCapacity,
      "selected": false,
    });

    _homeBloc.placeListEventSink.add(list);

    Navigator.pop(context);
    Flushbar(
      animationDuration: Duration(milliseconds: 500),
      duration: Duration(seconds: 3),
      titleText: Text(
        'SPOT AGGIUNTO',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFFBFCFF),
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      messageText: Text(
        'SPOT CORRETTAMENTE SALVATO NELLA LISTA PERSONALE',
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
  }

//  fakeScan() async {
//    final spot =
////        await _networkLayer.getSpotInfo('ddb0b0b2-612a-409f-a011-ba178d4e8974');
//        await _networkLayer.getSpotInfo('ed7598f8-cfc7-4d15-96a4-5ebedbf28196');
////        await _networkLayer.getSpotInfo('2b74110d-1d28-47f3-b691-2e3b4b6af04e');
//
//    _spotId = spot['sid'];
//    _spotName = spot['nameidentity'];
//    _spotAddress = spot['address'];
//    _spotCapacity = spot['capacity'] ?? 0;
//
//    scannedSpot = true;
//    _startedCameraSession = false;
//    setState(() {});
//  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _retrieveData();
  }

  void _retrieveData() async {
    if (widget.spotId != null) {
      if (_homeBloc.placeList
          .every((element) => element["sid"] != widget.spotId)) {
        final spot = await _networkLayer.getSpotInfo(widget.spotId);
        setState(() {
          _spotId = spot['sid'];
          _spotName = spot['nameidentity'];
          _spotAddress = spot['address'];
          _spotCapacity = spot['capacity'].toString() ?? '0';

          scannedSpot = true;
          _startedCameraSession = false;
        });
      } else {
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 1),
          isDismissible: true,
          messageText: Text(''),
          padding: EdgeInsets.only(top: 30),
          titleText: Center(
            child: Text(
              'SPOT GIÀ PRESENTE',
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
      }
    }
  }

  void showConfirmDialog(BuildContext context) {
    SimpleDialog fancyDialog = SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      title: Center(
          child: new Text(
        "Elimina Spot Salvati",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      )),
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: new Text(
              'Sei sicuro di voler eliminare l\'elenco degli spot '
              'salvati nel dispositivo?',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: new Text(
              'Quest\'operazione è irreversibile,\ndovrai scannerizzare nuovamente il QRCode dello Spot',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SimpleDialogOption(
              child: new Text(
                "Annulla",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
                child: new Text(
                  "Conferma",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  _deleteSpots();
                  Navigator.pop(context);
                  Navigator.pop(context);
                })
          ],
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => fancyDialog,
    );
  }

  void _deleteSpots() async {
    _homeBloc.placeListEventSink.add([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        primary: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: Icon(Icons.keyboard_arrow_down),
          ),
        ),
        title: Text(
          'AGGIUNGI SPOT',
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD0CCD0),
          ),
        ),
        backgroundColor: Color(0xFF274156),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: new Stack(
          children: <Widget>[
            Positioned(
              child: Container(
                child: !scannedSpot
                    ? Container()
                    : Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Nome',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text(
                                          _spotName ?? '',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 1,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.all(8),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          'Indirizzo',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .5,
                                        child: Text(
                                          _spotAddress ?? '',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 1,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.all(8),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        'Capienza',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        _spotCapacity ?? '',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: 1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  margin: EdgeInsets.all(8),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .75,
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: FloatingActionButton.extended(
                                    onPressed: () => saveSpot(),
                                    icon: Icon(Icons.save),
                                    label: Text('AGGIUNGI SPOT'),
                                  ),
                                  margin: EdgeInsets.all(8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 0,
              right: 8,
              child: FlatButton.icon(
                onPressed: () => showConfirmDialog(context),
                icon: Icon(Icons.clear_all),
                label: Text('Elimina Spot Salvati'),
              ),
            ),
//            Positioned(
//              top: 0,
//              left: 8,
//              child: FlatButton.icon(
//                onPressed: () => fakeScan(),
//                icon: Icon(Icons.scanner),
//                label: Text('Fake Scan'),
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
