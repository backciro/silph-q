import 'dart:convert';

import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class InitFormWidget extends StatefulWidget {
  final Function loginDone;

  InitFormWidget({this.loginDone});

  @override
  _InitFormWidgetState createState() => _InitFormWidgetState();
}

class _InitFormWidgetState extends State<InitFormWidget> {
  final _formKey = GlobalKey<FormState>();
  SafeZoneHandler _safeZoneHandler;
  NetworkLayer _networkLayer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _safeZoneHandler = new SafeZoneHandler();
    _networkLayer = new NetworkLayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(width: 0),
        centerTitle: true,
        title: Text(
          'AUTENTICAZIONE',
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD0CCD0),
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xFF274156),
      ),
      body: Container(
        child: Center(
          child: Container(
            alignment: FractionalOffset(.5, .25),
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Container(
              width: 161,
              height: 40,
              child: SignInButton(
                Buttons.Google,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
                text: 'Secure Login',
                onPressed: () {
                  _networkLayer.registerLogin().then((onValue) {
                    if (onValue) {
                      widget.loginDone(true);
                      Navigator.pop(context);
                      Flushbar(
                        animationDuration: Duration(milliseconds: 500),
                        duration: Duration(seconds: 5),
                        titleText: Text(
                          'LOG-IN EFFETTUATO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFBFCFF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        messageText: Text(
                          'ORA PUOI INIZIARE AD USARE IL SERVIZIO',
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
                    } else {
                      widget.loginDone(false);
                      Flushbar(
                        animationDuration: Duration(milliseconds: 500),
                        duration: Duration(seconds: 5),
                        titleText: Text(
                          'ERRORE NEL LOG-IN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFBFCFF),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        messageText: Text(
                          'QUALCOSA È ANDATO STORTO ...\nCONTROLLA I TUOI DATI E RIPROVA',
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
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
