import 'dart:async';
import 'dart:convert';

import 'package:SILPH_Q/app/services/network-layer.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:SILPH_Q/app/services/socket-layer.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

class HomeBloc extends BlocBase {
  NetworkLayer _networkLayer = new NetworkLayer();
  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();

  int currentMode;
  List<dynamic> placeList = [];

  HomeBloc() {
    _opModeEventController.stream.listen(_mapEventModeToState);
    _placeListEventController.stream.listen(_mapEventPlaceListToState);
  }

  //OPMODE
  final StreamController<int> _opModeEventController = new BehaviorSubject();

  Sink<int> get opModeEventSink => _opModeEventController.sink;

  final StreamController<int> _opModeStateController = new BehaviorSubject();

  StreamSink<int> get _inOpModeEvent => _opModeStateController.sink;

  Stream<int> get opModeState => _opModeStateController.stream;

  void _mapEventModeToState(int event) async {
    currentMode = event;
    await _safeZoneHandler.setSelectedMode(event);

    _inOpModeEvent.add(event);
  }


  //PLACELIST
  final StreamController<List<dynamic>> _placeListEventController =
      new BehaviorSubject();

  Sink<List<dynamic>> get placeListEventSink => _placeListEventController.sink;

  final StreamController<List<dynamic>> _placeListStateController =
      new BehaviorSubject();

  StreamSink<List<dynamic>> get _inPlaceListEvent =>
      _placeListStateController.sink;

  Stream<List<dynamic>> get placeListState => _placeListStateController.stream;

  void _mapEventPlaceListToState(List<dynamic> event) async {
    placeList = event;
    _inPlaceListEvent.add(placeList);

    await _safeZoneHandler.setSavedSpots(event);
  }

  tapClick(i) {
    placeList.forEach((f) => f['selected'] = false);
    placeList[i]['selected'] = true;

    placeListEventSink.add(placeList);
  }

  // disposal
  @override
  void dispose() {
    super.dispose();
    _opModeEventController.close();
    _opModeStateController.close();
    _placeListEventController.close();
    _placeListStateController.close();
  }
}
