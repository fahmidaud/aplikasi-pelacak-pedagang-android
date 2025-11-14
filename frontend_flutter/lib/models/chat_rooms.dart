import 'package:meta/meta.dart';
import 'dart:convert';

List<ChatRooms> chatRoomsFromJson(String str) =>
    List<ChatRooms>.from(json.decode(str).map((x) => ChatRooms.fromJson(x)));

String chatRoomsToJson(List<ChatRooms> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatRooms {
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final Expand expand;
  final String id;
  final String idPembeli;
  final String idPenjual;
  final Is isHapusChat;
  final Is isRead;
  final LastMessage lastMessage;
  final DateTime updated;

  ChatRooms({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.expand,
    required this.id,
    required this.idPembeli,
    required this.idPenjual,
    required this.isHapusChat,
    required this.isRead,
    required this.lastMessage,
    required this.updated,
  });

  factory ChatRooms.fromJson(Map<String, dynamic> json) => ChatRooms(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        expand: Expand.fromJson(json["expand"]),
        id: json["id"],
        idPembeli: json["id_pembeli"],
        idPenjual: json["id_penjual"],
        isHapusChat: Is.fromJson(json["is_hapus_chat"]),
        isRead: Is.fromJson(json["is_read"]),
        lastMessage: LastMessage.fromJson(json["last_message"]),
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "expand": expand.toJson(),
        "id": id,
        "id_pembeli": idPembeli,
        "id_penjual": idPenjual,
        "is_hapus_chat": isHapusChat.toJson(),
        "is_read": isRead.toJson(),
        "last_message": lastMessage.toJson(),
        "updated": updated.toIso8601String(),
      };
}

class Expand {
  final IdPembeli idPembeli;
  final IdPenjual idPenjual;

  Expand({
    required this.idPembeli,
    required this.idPenjual,
  });

  factory Expand.fromJson(Map<String, dynamic> json) => Expand(
        idPembeli: IdPembeli.fromJson(json["id_pembeli"]),
        idPenjual: IdPenjual.fromJson(json["id_penjual"]),
      );

  Map<String, dynamic> toJson() => {
        "id_pembeli": idPembeli.toJson(),
        "id_penjual": idPenjual.toJson(),
      };
}

class IdPembeli {
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String email;
  final bool emailVisibility;
  final String id;
  final String idSocket;
  final bool isLogOut;
  final bool isOnline;
  final String nama;
  final OnlineDetails onlineDetails;
  final String subLocality;
  final DateTime updated;
  final String username;
  final bool verified;
  final String tokenFcm;

  IdPembeli({
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.email,
    required this.emailVisibility,
    required this.id,
    required this.idSocket,
    required this.isLogOut,
    required this.isOnline,
    required this.nama,
    required this.onlineDetails,
    required this.subLocality,
    required this.updated,
    required this.username,
    required this.verified,
    required this.tokenFcm,
  });

  factory IdPembeli.fromJson(Map<String, dynamic> json) => IdPembeli(
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        id: json["id"],
        idSocket: json["id_socket"],
        isLogOut: json["is_log_out"],
        isOnline: json["is_online"],
        nama: json["nama"],
        onlineDetails: OnlineDetails.fromJson(json["online_details"]),
        subLocality: json["sub_locality"],
        updated: DateTime.parse(json["updated"]),
        username: json["username"],
        verified: json["verified"],
        tokenFcm: json["token_fcm"],
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "email": email,
        "emailVisibility": emailVisibility,
        "id": id,
        "id_socket": idSocket,
        "is_log_out": isLogOut,
        "is_online": isOnline,
        "nama": nama,
        "online_details": onlineDetails.toJson(),
        "sub_locality": subLocality,
        "updated": updated.toIso8601String(),
        "username": username,
        "verified": verified,
        "token_fcm": tokenFcm,
      };
}

class OnlineDetails {
  final int timestampOffline;
  final int timestampOnline;

  OnlineDetails({
    required this.timestampOffline,
    required this.timestampOnline,
  });

  factory OnlineDetails.fromJson(Map<String, dynamic> json) => OnlineDetails(
        timestampOffline: json["timestamp_offline"],
        timestampOnline: json["timestamp_online"],
      );

  Map<String, dynamic> toJson() => {
        "timestamp_offline": timestampOffline,
        "timestamp_online": timestampOnline,
      };
}

class IdPenjual {
  final AlamatKeliling alamatKeliling;
  final AlamatTetap alamatTetap;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final String email;
  final bool emailVisibility;
  final String id;
  final String idSocket;
  final bool isLogOut;
  final bool isOnline;
  final String namaDagang;
  final String namaPenjual;
  final OnlineDetails onlineDetails;
  final String subLocality;
  final List<String> tipePenjual;
  final DateTime updated;
  final String username;
  final bool verified;
  final String tokenFcm;

  IdPenjual({
    required this.alamatKeliling,
    required this.alamatTetap,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.email,
    required this.emailVisibility,
    required this.id,
    required this.idSocket,
    required this.isLogOut,
    required this.isOnline,
    required this.namaDagang,
    required this.namaPenjual,
    required this.onlineDetails,
    required this.subLocality,
    required this.tipePenjual,
    required this.updated,
    required this.username,
    required this.verified,
    required this.tokenFcm,
  });

  factory IdPenjual.fromJson(Map<String, dynamic> json) => IdPenjual(
        alamatKeliling: AlamatKeliling.fromJson(json["alamat_keliling"]),
        alamatTetap: AlamatTetap.fromJson(json["alamat_tetap"]),
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        id: json["id"],
        idSocket: json["id_socket"],
        isLogOut: json["is_log_out"],
        isOnline: json["is_online"],
        namaDagang: json["nama_dagang"],
        namaPenjual: json["nama_penjual"],
        onlineDetails: OnlineDetails.fromJson(json["online_details"]),
        subLocality: json["sub_locality"],
        tipePenjual: List<String>.from(json["tipe_penjual"].map((x) => x)),
        updated: DateTime.parse(json["updated"]),
        username: json["username"],
        verified: json["verified"],
        tokenFcm: json["token_fcm"],
      );

  Map<String, dynamic> toJson() => {
        "alamat_keliling": alamatKeliling.toJson(),
        "alamat_tetap": alamatTetap.toJson(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "email": email,
        "emailVisibility": emailVisibility,
        "id": id,
        "id_socket": idSocket,
        "is_log_out": isLogOut,
        "is_online": isOnline,
        "nama_dagang": namaDagang,
        "nama_penjual": namaPenjual,
        "online_details": onlineDetails.toJson(),
        "sub_locality": subLocality,
        "tipe_penjual": List<dynamic>.from(tipePenjual.map((x) => x)),
        "updated": updated.toIso8601String(),
        "username": username,
        "verified": verified,
        "token_fcm": tokenFcm,
      };
}

class AlamatKeliling {
  final double latitude;
  final double longitude;

  AlamatKeliling({
    required this.latitude,
    required this.longitude,
  });

  factory AlamatKeliling.fromJson(Map<String, dynamic> json) => AlamatKeliling(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class AlamatTetap {
  final double latitude;
  final double longitude;
  final String alamatLengkap;

  AlamatTetap({
    required this.latitude,
    required this.longitude,
    required this.alamatLengkap,
  });

  factory AlamatTetap.fromJson(Map<String, dynamic> json) => AlamatTetap(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        alamatLengkap: json["alamat_lengkap"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "alamat_lengkap": alamatLengkap,
      };
}

class Is {
  final bool byPembeli;
  final bool byPenjual;

  Is({
    required this.byPembeli,
    required this.byPenjual,
  });

  factory Is.fromJson(Map<String, dynamic> json) => Is(
        byPembeli: json["by_pembeli"],
        byPenjual: json["by_penjual"],
      );

  Map<String, dynamic> toJson() => {
        "by_pembeli": byPembeli,
        "by_penjual": byPenjual,
      };
}

class LastMessage {
  final String message;
  final String senderId;
  final int timestamp;

  LastMessage({
    required this.message,
    required this.senderId,
    required this.timestamp,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        message: json["message"],
        senderId: json["sender_id"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "sender_id": senderId,
        "timestamp": timestamp,
      };
}
