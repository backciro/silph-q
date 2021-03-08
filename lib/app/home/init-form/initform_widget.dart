import 'dart:convert';

import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InitFormWidget extends StatefulWidget {
  final Function saveElement;

  InitFormWidget({this.saveElement});

  @override
  _InitFormWidgetState createState() => _InitFormWidgetState();
}

class _InitFormWidgetState extends State<InitFormWidget> {
  final _formKey = GlobalKey<FormState>();
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();

  TextEditingController usernameController;
  TextEditingController usercodeController;
  TextEditingController usermailController;
  TextEditingController usercellController;
  TextEditingController useraddrController;

  setDataForm() async {
    usernameController = new TextEditingController();
    usercodeController = new TextEditingController();
    usermailController = new TextEditingController();
    usercellController = new TextEditingController();
    useraddrController = new TextEditingController();

    usercellController.text = await _safeZoneHandler.getTelNumber() ?? '';
    usernameController.text = await _safeZoneHandler.getFullName() ?? '';
    useraddrController.text = await _safeZoneHandler.getAddress() ?? '';
    usercodeController.text = await _safeZoneHandler.getIDCode() ?? '';
    usermailController.text = await _safeZoneHandler.getEmail() ?? '';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setDataForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(width: 0),
        title: Text(
          'IL MIO PROFILO',
          style: TextStyle(
            fontSize: 18.0,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD0CCD0),
          ),
        ),
        backgroundColor: Color(0xFF274156),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFD0CCD0),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  new Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('Nome & Cognome'),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFormField(
                          controller: usernameController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Per favore compila questo campo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  new Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('Codice Fiscale'),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFormField(
                          controller: usercodeController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Per favore compila questo campo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  new Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('Indirizzo di Residenza o Domicilio'),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFormField(
                          controller: useraddrController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Per favore compila questo campo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  new Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('Numero di Telefono'),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFormField(
                          controller: usercellController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Per favore compila questo campo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  new Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text('Indirizzo Email'),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextFormField(
                          controller: usermailController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Per favore compila questo campo';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  new Container(height: 0),
                  new Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: FlatButton(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          final formData = {
                            "userName": usernameController.text,
                            "userCode": usercodeController.text,
                            "userMail": usermailController.text,
                            "userNumb": usercellController.text,
                            "userAddr": useraddrController.text,
                          };

                          widget.saveElement(formData);
                          Navigator.pop(context);
                          _showDialog(context);
                        }
                      },
                      child: Text(
                        'SALVA',
                        style: TextStyle(
                            color: Color(0xFF274156),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    Flushbar(
      animationDuration: Duration(milliseconds: 500),
      duration: Duration(seconds: 3),
      titleText: Text(
        'DATI SALVATI',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFFBFCFF),
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      messageText: Text(
        'NELLA MEMORIA DEL TUO DISPOSITIVO',
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
}
