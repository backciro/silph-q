import 'dart:io';

import 'package:SILPH_Q/app/home/question-form/questionform_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_module.dart';
import 'home_bloc.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc = AppModule.to.getBloc();

  String _codeStatus = 'green';

  var cardAspectRatio;
  var currentPage;

  riskDetected() {
    setState(() {
      this._codeStatus = 'red';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardAspectRatio = 12.0 / 16.0;
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
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 100),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    color: Color(0xFFFBFCFF).withAlpha(200),
                    semanticContainer: true,
                    child: Container(
                      alignment: FractionalOffset(0.5, 0),
                      child: QrImage(
                        gapless: true,
                        data: "1234567890",
                        version: QrVersions.auto,
                        foregroundColor: this._codeStatus == 'green'
                            ? Colors.green
                            : this._codeStatus == 'yellow'
                                ? Color(0xFFE6A100)
                                : Colors.redAccent,
                        size: 200,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    color: Color(0xFFFBFCFF).withAlpha(200),
                    semanticContainer: true,
                    child: Container(
                      alignment: FractionalOffset(0.5, 0),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              this._codeStatus == 'green'
                                  ? '[QR VERDE]'
                                  : this._codeStatus == 'yellow'
                                      ? '[QR GIALLO]'
                                      : '[QR ROSSO]',
                              textAlign: TextAlign.justify,
                              style: TextStyle(color: Color(0xFF274156)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 8,
                              bottom: 16,
                            ),
                            child: Text(
                              this._codeStatus == 'green'
                                  ? 'Accesso Consentito al Servizio\nBuona Permanenza!'
                                  : this._codeStatus == 'yellow'
                                      ? 'È stato rilevato un caso di contagio tra le persone che hanno fatto accesso nello stesso Centro Commerciale in cui sei stato anche tu. \nPer adesso preferiamo non correre rischi di contagi ulteriori, per questo ti abbiamo limitato l\'accesso ai nostri servizi.'
                                      : 'È stato rilevato un alto pericolo di contagio dai dati che ci hai fornito, pertanto sei invitato a restare a casa e contattare le autoritaà competenti qualora dovessi sviluppare sintomi della malattia',
                              textAlign: this._codeStatus == 'green'
                                  ? TextAlign.center
                                  : this._codeStatus == 'yellow'
                                      ? TextAlign.justify
                                      : TextAlign.justify,
                              style: TextStyle(color: Color(0xFF274156)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 42),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 23),
                    child: Container(
                      alignment: FractionalOffset(0.5, 0),
                      child: Column(
                        children: <Widget>[
                          this._codeStatus == 'green'
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Matteo Minutti',
                                      style: TextStyle(
                                        color: Color(0xFF274156),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'MNT ********* B',
                                      style: TextStyle(
                                        color: Color(0xFF274156),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : new Container()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 42),
                  this._codeStatus == 'green'
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 23),
                          child: Container(
                            alignment: FractionalOffset(0.5, 0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 23),
                                FloatingActionButton.extended(
                                  backgroundColor: Color(0xFFE6A100),
                                  isExtended: true,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      useRootNavigator: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(16),
                                        ),
                                      ),
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.9,
                                          child: new Container(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: QuestionFormWidget(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  label: Container(
                                    child: Text(
                                      'Test di Autovalutazione',
                                      textAlign: TextAlign.center,
                                    ),
                                    width: 240,
                                  ),
                                  icon: Icon(Icons.healing),
                                ),
                                SizedBox(height: 42),
                                FloatingActionButton.extended(
                                  backgroundColor: Colors.redAccent,
                                  isExtended: true,
                                  onPressed: () {
                                    riskDetected();
                                  },
                                  label: Container(
                                    child: Text(
                                      'Segnala Rischio Contagio',
                                      textAlign: TextAlign.center,
                                    ),
                                    width: 240,
                                  ),
                                  icon: Icon(Icons.warning),
                                ),
                              ],
                            ),
                          ),
                        )
                      : new Container(),
                  SizedBox(height: 42),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.only(left: 18, top: 50),
            height: 70,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xFFD0CCD0)),
            child: Text(
              'SILPH Q',
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
          bottom: 0,
          left: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(8),
            height: Platform.isAndroid ? 70 : 110,
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
                color: Color(0xFFD0CCD0),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: FractionalOffset(1, 0),
                  child: FloatingActionButton(
                    backgroundColor: Color(0xFF274156),
                    isExtended: true,
                    onPressed: () {
                      setState(() {
                        this._codeStatus = this._codeStatus == 'green'
                            ? 'yellow'
                            : this._codeStatus == 'yellow' ? 'red' : 'green';
                      });
                    },
                    child: Icon(
                      Icons.settings_overscan,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
