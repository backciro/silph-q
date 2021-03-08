import 'dart:convert';
import 'dart:io';

import 'package:SILPH_Q/app/services/rsa_toolkit.dart';
import 'package:dio/dio.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';

class NetworkLayer {
  RSAToolkit _rsaToolkit = new RSAToolkit();
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();

  String _apiPath = 'https://silph-care.ey.r.appspot.com';

//  String _apiPath =
//      Platform.isAndroid ? 'http://10.0.2.2:8090' : 'http://localhost:8080';

  syncState() async {
    final pubKey = await _safeZoneHandler.readPublicKey();

    final response = await new Dio().get(
      "$_apiPath/synchronization/sync",
      options: Options(headers: {
        "pubkey": pubKey.toString().replaceAll('\n', '|'),
      }),
    );

    if (response.data is bool) {
      return 0;
    } else {
      final decrypted = _rsaToolkit.rsaDecrypt(
        await _safeZoneHandler.readPrivateKey(),
        base64.decode(response.data),
      );

      if (utf8.decode(decrypted) == '"first access"')
        return 0;
      else {
        final defcon = jsonDecode(utf8.decode(decrypted))[0]['defcon'];
        _safeZoneHandler.setDEFCON(defcon);

        return defcon;
      }
    }
  }

  saveLocalData(data) async {
    await _safeZoneHandler.setTelNumber(data['userNumb']);
    await _safeZoneHandler.setFullName(data['userName']);
    await _safeZoneHandler.setAddress(data['userAddr']);
    await _safeZoneHandler.setIDCode(data['userCode']);
    await _safeZoneHandler.setEmail(data['userMail']);
  }

  reviewMe(data, defcon) async {
    final pubKey = await _safeZoneHandler.readPublicKey();
    _safeZoneHandler.setDEFCON(defcon);

    final payload = {
      "pubkey": pubKey,
      "defcon": defcon,
    };

    final response = await new Dio().post(
      "$_apiPath/checkin/reviewState",
      data: jsonEncode(payload),
    );

    this._safeZoneHandler.setRegStatus(true);
    return response.data;
  }

  registerMe(defcon) async {
    final pubKey = await _safeZoneHandler.readPublicKey();
    _safeZoneHandler.setDEFCON(defcon);

    final payload = {
      "pubkey": pubKey,
      "defcon": defcon,
    };

    final response = await new Dio().post(
      "$_apiPath/checkin/jumpIn",
      data: jsonEncode(payload),
    );

    this._safeZoneHandler.setRegStatus(true);
    return response.data;
  }

  takeReservation(localeUUID) async {
    final data = {
      "pubkey": await this._safeZoneHandler.readPublicKey(),
      "timestamp": DateTime.now().toString(),
      "spot": localeUUID,
    };

    final response =
        await new Dio().post(_apiPath + '/checkin/reservation', data: data);

    if (response.data != false)
      await _safeZoneHandler.encodeInTrackList({
        "spotname": response.data,
        "timestamp": data['timestamp'],
      });

    return response.data;
  }

  alertContamination() async {
//    final data = {
//      "publicKey": await this._safeZoneHandler.readSecureValue(key: 'publicKey')
//    };

    final dioHandler = new Dio();
    final response =
        await dioHandler.post(_apiPath + '/contamination', data: 'data');

    if (response.statusCode == 200) {
      print('Successfully Alerted');
      return true;
    } else {
      print('Something Wen Wrong :/');
      return false;
    }
  }
}
