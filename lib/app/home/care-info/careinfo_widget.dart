import 'package:SILPH_Q/app/services/socket-layer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CareInfoWidget extends StatelessWidget {
  final SocketLayer _socketLayer = new SocketLayer();

  testSocket() {
//    _socketLayer.testBroadcastRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            child: Icon(Icons.keyboard_arrow_down),
          ),
        ),
        centerTitle: true,
        title: Text(
          'IL NOSTRO SERVIZIO',
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
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    10,
                  ),
                  child: Text(
                    'COME USIAMO I DATI',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF274156),
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'I dati che vedi nella homepage sono salvati nella memoria '
                    'del tuo cellulare, e non sono accessibili dai nostri '
                    'servizi poiché sono criptati in maniera diversa per ogni '
                    'dispositivo. Gli algoritmi sono basati su una cifratura '
                    'RSA, un sistema che prevede una coppia di chiavi univoche, '
                    'garantendo una sicurezza fondata su forti e consolidate '
                    'basi matematiche, ma sul nostro sito maggiori dettagli '
                    'su come funziona il progetto SILPH CARE.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Color(0xFF274156),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    10,
                  ),
                  child: Text(
                    'NOI CHI SIAMO',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF274156),
                      letterSpacing: 1,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    'Noi siamo la SILPH Technologies, una StartUp italiana nata '
                    'nel Luglio del 2019 fondata sull\' esperienza di ITALAMBIENTE, '
                    'società che opera da più di 30 anni nel settore della Sicurezza.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Color(0xFF274156),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Container(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
//                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Image.asset(
                      'assets/logo-emboss-silph.png',
                      width: 150,
                    ),
                  ),
                  Container(
//                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Image.asset(
                      'assets/logo-emboss-ital.png',
                      width: 100,
                    ),
                  ),
                ],
              ),
              Container(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
