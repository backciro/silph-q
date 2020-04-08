import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:SILPH_Q/app/home/home_module.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SILPH Q',
      darkTheme: ThemeData(
        primaryColor: Color(0xFFD0CCD0),
        canvasColor: Color(0xFF1C6E8C),
        fontFamily: 'Poppins-Reg',
      ),
      theme: ThemeData(
        primaryColor: Color(0xFF1C6E8C),
        canvasColor: Color(0xFFD0CCD0),
        fontFamily: 'Poppins-Reg',
      ),
      home: HomeModule(),
    );
  }
}
