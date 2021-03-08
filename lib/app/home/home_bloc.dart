import 'dart:convert';

import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dio/dio.dart';

class HomeBloc extends BlocBase {
  NetworkLayer _networkLayer = new NetworkLayer();

  //dispose will be called automatically by closing its streams
  @override
  void dispose() {
    super.dispose();
  }
}
