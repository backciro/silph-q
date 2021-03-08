import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:SILPH_Q/app/services/rsa_toolkit.dart';
import 'package:SILPH_Q/app/services/secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketLayer {
//  String _apiPath =
//      Platform.isAndroid ? 'http://10.0.2.2:8090' : 'http://localhost:8080';
  String _apiPath = 'https://socket-dot-silph-care.ey.r.appspot.com';

  SafeZoneHandler _safeZoneHandler = new SafeZoneHandler();
  RSAToolkit _rsaToolkit = new RSAToolkit();

  Socket _socket;

  initLayer() {
    Socket socket = io(_apiPath, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.on('connect', (_) => onConnect(socket));
    socket.on('disconnect', (_) => onDisconnect(socket));
    socket.on('broadcastMessage', (_) => onBroadcasting(socket, _));
    socket.on('armyCallResponse', (_) => onArmyCallResponse(socket, _));
    if (!socket.connected) socket.connect();
  }

  testBroadcastRequest() async {
    _socket.emit(
      'requestContract',
      jsonEncode({
        "pub": '-----BEGIN RSA PUBLIC KEY-----\n'
            'MIICCgKCAgEAhgh368ty14KuTjyTIvhwt0g/i7CTigXIErYgjRvZWmPhrqUnuCuC9m91IZVfP0DmXSUsdxpLHxlrOpXp7GDqsDhVBH5FCqt+xBOeAeWFTvKR8sIS2G/Sw/dDT1x6PMhfZkR4A9Ox2tS9bpEFjQcI3gzTKSdDrsrS55b5MZiQcAe0f10vR98taAZ164eDyXH/78KVg33SwMo6RurEi81lE+QED3wcoYLqHJ2jXlyXAygHz0Gl3NvIBRKg9GxE0VDvkg/B0+bCzcD5yZGvUwnvDgLhjBJqaWM2cgdDRJhNU3IMX3J8RcBBJs7YGaO0Ic59YqIYDbY/TpS9y24UQrF2UfJP8X1OMIxYjKDRvz7/+VWuDDJeUQKUTTS7Bsi2K4OuwB5UO/kKru/Rc0nOlAcrz7f/RG8kfbrl+cyOxxpR8sVWxuF2ZOKKmOGGOjBjPeiZQ9v3DA2hq+eI8YAypncgRC9+s5jdo7/Zl1AHvi66xjG/EYH7E8pF/6Disq1CL+qeO7Kq+89HyrYiOZIS4AoH2ZRIE1FWkh2G+ON/9jVJ9W2zbO8Om0p5ykyVdHDXgVz3YAkQei2kaw7bibAs5IJM4wK7E5rnBNcbx1VaaO1Dtzk57XZUZBz49/ZmwKiCtzEQy0icI9HQdIjeP/l7GGD2hP6n60rsBbG8q13+mS4Z6nkCAwEAAQ=='
            '\n-----END RSA PUBLIC KEY-----',
        "pubMed": '-----BEGIN RSA PUBLIC KEY-----\n'
            'MIICCgKCAgEAszSnU8WB0YNZc1nV22mtFpR8ca2UQw6NwfDiZ3QVrLOgvICSka5yiZBuRDtbgUeuTOOjM/K42I0FHPMwBs8bH9FdXSATKQCX1IDrLtFAEihwNxErtIc/VpcT2zGfyIk/FsXLFWy1BXe9b7DTEmIMzjYl6fPz0C9lG4hGxrRVlAGwFln2SSTMNte2uIaZpebexLnOaJq0BbDAQNLpiiJOmWraLD0huX+n+x7WVPahggOxu5JGIsBSQ7POf/fZE7fum/PwPOZpIpqikEyu866KaaOVH9BTR6/xLYLOdnMuIHpw+n9+b81eWzoLfDPzuK3QWsWONzoE2tPWnXx6LUDshSkB18FfaCtz4VbaSNBkr9GzjcesgYVbIlQqk/fnIbCUSR4sZ22DkfWNHLLoUQVu+h7apQlZqr8SMh8gs4Wc16BMLrqIlmAyyoar/5hPNpjUvBNXISLa3x9rNMhYml4PFEfC72LUHluOKzpWq2/2eOXIJNaqf/1YP+ZLy4fo85LJj7owCA+zq4TVxfTUgZS3GxcEymJkdj2rHAPxMo8Z6LgjTvHSIAC4ejWsuG4OJqGE2Ic6ai1wRcu1G8uqeHWgt/ItfoMjrCj/hTjV36rHNfNrutThvARUGQ8UnOATIwFUIlbjfkDzQZFiJGrLhBsJDoryQS2Y6BZKz2kkagD2vIcCAwEAAQ=='
            '\n-----END RSA PUBLIC KEY-----',
        "request": 0
      }),
    );
  }

  onConnect(Socket socket) {
    _socket = socket;
    print('connected successfully');
  }

  onDisconnect(Socket socket) {
    print('disconnected from socket');
    _socket = null;
  }

  onCastMyself(Uint8List encryptData, String pubMed) {
    _socket.emit('requestContract',
        jsonEncode({"crypto": encryptData, "pubMed": pubMed, "request": 1}));
  }

  onBroadcasting(Socket socket, String msg) async {
    print('!! broadcastMessage ATTENTION !!');
    // if myKey is equal to the key provided in the request
    // i'll be asked if encrypt then send my data to the owner in order
    // to allow him to scan me and set my health status

    final myKey = await _safeZoneHandler.readPublicKey();
    final data = jsonDecode(msg);

    if (myKey == data['pub']) {
      final particularData = {
        "fullname": await _safeZoneHandler.getFullName(),
        "birthdate": await _safeZoneHandler.getTelNumber(),
        "fiscalcode": await _safeZoneHandler.getIDCode(),
        "defcon": await _safeZoneHandler.getDEFCON(),
      };

      final encrypted = _rsaToolkit.rsaEncrypt(
        data['pubMed'],
        base64.decode(
          base64.encode(
            utf8.encode(
              jsonEncode(particularData),
            ),
          ),
        ),
      );

      onCastMyself(encrypted, data['pubMed']);
    }
  }

  onArmyCallResponse(Socket socket, String msg) async {
    print('!! ARMYCALL RESPONSE !!');
    // if myKey is equal to the MEDkey IM THE BEST
    final data = jsonDecode(msg);
    final myKey = await _safeZoneHandler.readPublicKey();

    if (myKey == data['pubMed']) {
      final myPrivateKey = await _safeZoneHandler.readPrivateKey();

      //try to decrpt with ma secret yo
      try {
        final List<int> particularDataFootprint =
            new List<int>.from(data['crypto']);

        final decrypted = _rsaToolkit.rsaDecrypt(
          myPrivateKey,
          base64.decode(
            base64.encode(particularDataFootprint),
          ),
        );

        print('yeee');
        print(
          jsonDecode(
            utf8.decode(decrypted),
          ),
        );
      } catch (e) {
        print("ERROR DECRYPT LOG FOR MORE");
        print(e);
      }
    }
  }
}
