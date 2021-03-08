import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:SILPH_Q/app/app_module.dart';
import 'package:SILPH_Q/app/home/home_bloc.dart';
import 'package:SILPH_Q/app/services/rsa_toolkit.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketLayer {
  HomeBloc _homeBloc = AppModule.to.getBloc();
  String _socketPath = 'https://socket-dot-silph-care.ey.r.appspot.com';

//  String _socketPath =
//      Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';

  Socket _socket;

  initLayer({String spot}) {
    var _sc = true;
    Socket socket = io(_socketPath + '/guard', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'spot': spot ?? ''},
    });

    socket.on('connect', (_) => onConnect(socket));
    socket.on('disconnect', (_) => onDisconnect(socket));
    socket.on('valueRefresh', (_) => capacityRecalculate(socket, _));
    _socket = socket;

    if (_sc) {
      _sc = false;
      if (!socket.connected)
        socket.connect();
      else
        socket.disconnect().connect();
      _sc = true;
    }
  }

  testRequest(pubKey, spot) async {
    await enterPlace(pubKey, spot);
  }

  onConnect(Socket socket) {
    _socket = socket;
    print('connected successfully');
  }

  onDisconnect(Socket socket) {
    print('disconnected from socket');
    _socket = null;
  }

  spotRefresh(spot) async {
    try {
      _socket.emit(
        'spotRefresh',
        jsonEncode({
          "spot": spot,
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  enterPlace(pubKey, spot) async {
    if (_socket != null && _socket.connected)
      _socket.emit(
        'enterPlace',
        jsonEncode({
          "spot": spot,
          "pubkey": pubKey,
          "timestamp": DateTime.now().toString(),
        }),
      );
    else
      initLayer();
  }

  exitOne(pubKey, spot) async {
    if (_socket != null && _socket.connected)
      _socket.emit(
        'placeQuit',
        jsonEncode({
          "pubkey": pubKey,
          "spot": spot,
          "timestamp": DateTime.now().toString(),
        }),
      );
    else
      initLayer();
  }

  capacityRecalculate(socket, Map data) {
    print(data);
    if (data.isEmpty) {
      _homeBloc.placeList.forEach((f) => f['currentInside'] = 0);
      _homeBloc.placeListEventSink.add(_homeBloc.placeList);
    } else {
      if (_homeBloc.placeList.length > 0) {
        _homeBloc.placeList.forEach((f) {
          data.keys.forEach((key) {
            if (f['sid'] == key) {
              f['currentInside'] = data[key];
            }
          });
        });
        _homeBloc.placeListEventSink.add(_homeBloc.placeList);
      }
    }
  }
}
