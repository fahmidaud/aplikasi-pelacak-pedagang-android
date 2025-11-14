import 'package:socket_io_client/socket_io_client.dart';

class SocketClientService {
  Socket? socket;

  String url_local = "http://192.168.43.75:3000";
  // String url_online = "https://realtime-online-yoapp-fahmi-gundar.koyeb.app";
  // String url_online = "https://realtime-online-yoapp-devwork.koyeb.app";
  String url_online = "https://realtime-online-yoapp.pages.dev";
  // var url = url_online;

  Future<void> initSocket() async {
    socket = io(url_online, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  Future<void> initConnectSocket() async {
    await initSocket();
  }

  Future<void> onConnectSocket() async {
    await socket!.connect();

    socket!.on('connect', (_) async {
      print('connect: ${socket!.id}');
    });
  }

  Future<void> onDisconnectSocket() async {
    socket!.on('disconnect', (_) async {
      print('disconnect');
    });
  }

  Future<void> sendDataToServerSocket(isPenggunaAnonim, identifier,
      isPenggunaPembeli, isPenggunaPenjual, idPengguna) async {
    print('${socket!.id} UNTUK sendDataToServerSocket');

    if (socket!.id == null) {
      socket!.on('connect', (_) async {
        final objData = {
          'is_pengguna_anonim': isPenggunaAnonim,
          'imei': identifier,
          "is_pengguna_pembeli": isPenggunaPembeli,
          "is_pengguna_penjual": isPenggunaPenjual,
          "id_pengguna": idPengguna,
          'socket_id': socket!.id,
        };
        socket!.emit('sendDataToServer', objData);
      });
      print('socket_id NULLLLL');
    } else {
      final objData = {
        'is_pengguna_anonim': isPenggunaAnonim,
        'imei': identifier,
        "is_pengguna_pembeli": isPenggunaPembeli,
        "is_pengguna_penjual": isPenggunaPenjual,
        "id_pengguna": idPengguna,
        'socket_id': socket!.id,
      };
      socket!.emit('sendDataToServer', objData);

      print('sendDataToServerSocket objData = ${objData}');
    }
  }
}
