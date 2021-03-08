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
  readToken() async {
    return await _readSecureValue(key: 'token');
  }

  writeToken(val) async {
    return await _writeSecureValue(key: 'token', value: val);
  }

  readProfile() async {
    return await _readSecureValue(key: 'profile');
  }

  writeProfile(val) async {
    return await _writeSecureValue(key: 'profile', value: val);
  }

  // config
  Future<int> getSelectedMode() async {
    final data = await _readSecureValue(key: 'selectedMode');
    if (data != null)
      return int.parse(data);
    else
      return 0;
  }

  setSelectedMode(val) async {
    return await _writeSecureValue(key: 'selectedMode', value: val.toString());
  }

  Future<List<dynamic>> getSavedSpots() async {
    final plainData = await _readSecureValue(key: 'SavedSpot');
    final List<dynamic> list = (plainData != null) ? jsonDecode(plainData) : [];
    return list;
  }

  setSavedSpots(data) async {
    await _writeSecureValue(key: 'SavedSpot', value: jsonEncode(data));
  }

  encodeInSavedSpots(data) async {
    List<dynamic> list = (await getSavedSpots()) ?? [];
    list.add(data);
    await setSavedSpots(list);
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
