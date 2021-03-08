import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:SILPH_Q/app/services/rsa_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NetworkLayer {
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();

  GoogleSignIn _googleSignIn;

  String _apiPath = 'https://silph-care.ey.r.appspot.com';

//  String _apiPath =
//      Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

  Future<bool> firstAccess() async {
    final token = await _safeZoneHandler.readToken();
    final response = await new Dio().get(
      "$_apiPath/guard/firstCheck",
      options: Options(headers: {
        "authorization": 'Bearer $token',
      }),
    );

    return response.data['success'] != null;
  }

  Future<bool> registerLogin() async {
    _googleSignIn = new GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    return _googleSignIn.signIn().then((result) async {
      if (result != null) {
        final dataProfile = {
          "account": result.email,
          "name": result.displayName,
        };

        final token = (await result.authentication).accessToken;

        final response = await Dio()
            .post(_apiPath + '/guard/login', data: {"authToken": token});

        if (response.data != null && response.data) {
          await _safeZoneHandler.writeProfile(jsonEncode(dataProfile));
          await _safeZoneHandler.writeToken(token);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    });
  }

  Future<dynamic> checkQueue(pubKey, spotId) async {
    final token = await _safeZoneHandler.readToken();

    try {
      final response = await new Dio().get(
        "$_apiPath/guard/checkTruth",
        options: Options(headers: {
          "authorization": 'Bearer $token',
          "pubkey": pubKey.toString().replaceAll('\n', '|'),
          "spot": spotId,
        }),
      );

      return response.data;
    } on DioError catch (e) {
      print(e);
      print(e.type);
      return false;
    }
  }

  Future<dynamic> getSpotInfo(spotId) async {
    final token = await _safeZoneHandler.readToken();

    try {
      final response = await new Dio().get(
        "$_apiPath/guard/getSpot",
        options: Options(headers: {
          "authorization": 'Bearer $token',
          "spot": spotId,
        }),
      );

      return response.data;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
