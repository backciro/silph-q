import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SafeZoneHandler {
  static FlutterSecureStorage storage = new FlutterSecureStorage();

  SafeZoneHandler() {
    storage = new FlutterSecureStorage();
  }

  isPresent({key}) async {
    final value = await storage.read(key: key);
    return value != null;
  }

  _readSecureValue({key}) async {
    final value = await storage.read(key: key);
    return value;
  }

  _writeSecureValue({key, value}) async {
    await storage.write(key: key, value: value);
  }

  // PUBLIC
  // // KeyChain
  readPublicKey() async {
    return await _readSecureValue(key: 'publicKey');
  }

  readPrivateKey() async {
    return await _readSecureValue(key: 'privateKey');
  }

  writePublicKey(val) async {
    return await _writeSecureValue(key: 'publicKey', value: val);
  }

  writePrivateKey(val) async {
    return await _writeSecureValue(key: 'privateKey', value: val);
  }

  // // Data Stored
  getDEFCON() async {
    return await _readSecureValue(key: 'DEFCON');
  }

  getRegStatus() async {
    return (await _readSecureValue(key: 'RegStatus')) == 'true';
  }

  getFullName() async {
    return await _readSecureValue(key: 'FullName');
  }

  getAddress() async {
    return await _readSecureValue(key: 'Address');
  }

  getTelNumber() async {
    return await _readSecureValue(key: 'TelNumber');
  }

  getEmail() async {
    return await _readSecureValue(key: 'Email');
  }

  getIDCode() async {
    return await _readSecureValue(key: 'IDCode');
  }

  setDEFCON(int data) async {
    await _writeSecureValue(key: 'DEFCON', value: data.toString());
  }

  setRegStatus(bool data) async {
    if (data)
      await _writeSecureValue(key: 'RegStatus', value: 'true');
    else
      await _writeSecureValue(key: 'RegStatus', value: 'false');
  }

  setFullName(data) async {
    await _writeSecureValue(key: 'FullName', value: data);
  }

  setAddress(data) async {
    await _writeSecureValue(key: 'Address', value: data);
  }

  setTelNumber(data) async {
    await _writeSecureValue(key: 'TelNumber', value: data);
  }

  setEmail(data) async {
    await _writeSecureValue(key: 'Email', value: data);
  }

  setIDCode(data) async {
    await _writeSecureValue(key: 'IDCode', value: data);
  }

  // // Track List
  Future<List<dynamic>> getTrackList() async {
    final plainData = await _readSecureValue(key: 'TrackList');
    final List<dynamic> list = (plainData != null) ? jsonDecode(plainData) : [];
    return list;
  }

  setTrackList(data) async {
    await _writeSecureValue(key: 'TrackList', value: jsonEncode(data));
  }

  encodeInTrackList(data) async {
    List<dynamic> list = (await getTrackList()) ?? [];
    list.add(data);

    await setTrackList(list);
  }
}
