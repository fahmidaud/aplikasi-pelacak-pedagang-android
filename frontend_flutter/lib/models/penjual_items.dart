import 'package:meta/meta.dart';
import 'dart:convert';

List<PenjualItems> penjualItemsFromJson(String str) => List<PenjualItems>.from(
    json.decode(str).map((x) => PenjualItems.fromJson(x)));

String penjualItemsToJson(List<PenjualItems> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PenjualItems {
  final String id;
  final bool isLogOut;
  final DateTime created;
  final DateTime updated;
  final String collectionId;
  final String collectionName;
  final Expand expand;
  final AlamatKeliling alamatKeliling;
  final AlamatTetap alamatTetap;
  final String email;
  final bool emailVisibility;
  final String idSocket;
  final bool isOnline;
  final String namaDagang;
  final String namaPenjual;
  final Expand onlineDetails;
  final String subLocality;
  final List<String> tipePenjual;
  final String username;
  final bool verified;
  final double jaraknya;
  final bool isMarkerClicked;
  final String tokenFcm;

  PenjualItems({
    required this.id,
    required this.isLogOut,
    required this.created,
    required this.updated,
    required this.collectionId,
    required this.collectionName,
    required this.expand,
    required this.alamatKeliling,
    required this.alamatTetap,
    required this.email,
    required this.emailVisibility,
    required this.idSocket,
    required this.isOnline,
    required this.namaDagang,
    required this.namaPenjual,
    required this.onlineDetails,
    required this.subLocality,
    required this.tipePenjual,
    required this.username,
    required this.verified,
    required this.jaraknya,
    required this.isMarkerClicked,
    required this.tokenFcm,
  });

  factory PenjualItems.fromJson(Map<String, dynamic> json) => PenjualItems(
        id: json["id"],
        isLogOut: json["is_log_out"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        expand: Expand.fromJson(json["expand"]),
        alamatKeliling: AlamatKeliling.fromJson(json["alamat_keliling"]),
        alamatTetap: AlamatTetap.fromJson(json["alamat_tetap"]),
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        idSocket: json["id_socket"],
        isOnline: json["is_online"],
        namaDagang: json["nama_dagang"],
        namaPenjual: json["nama_penjual"],
        onlineDetails: Expand.fromJson(json["online_details"]),
        subLocality: json["sub_locality"],
        tipePenjual: List<String>.from(json["tipe_penjual"].map((x) => x)),
        username: json["username"],
        verified: json["verified"],
        jaraknya: json["jaraknya"]?.toDouble(),
        isMarkerClicked: json["is_marker_clicked"],
        tokenFcm: json["token_fcm"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "is_log_out": isLogOut,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "expand": expand.toJson(),
        "alamat_keliling": alamatKeliling.toJson(),
        "alamat_tetap": alamatTetap.toJson(),
        "email": email,
        "emailVisibility": emailVisibility,
        "id_socket": idSocket,
        "is_online": isOnline,
        "nama_dagang": namaDagang,
        "nama_penjual": namaPenjual,
        "online_details": onlineDetails.toJson(),
        "sub_locality": subLocality,
        "tipe_penjual": List<dynamic>.from(tipePenjual.map((x) => x)),
        "username": username,
        "verified": verified,
        "jaraknya": jaraknya,
        "is_marker_clicked": isMarkerClicked,
        "token_fcm": tokenFcm,
      };
}

// class Alamat {
//   final double latitude;
//   final double longitude;

//   Alamat({
//     required this.latitude,
//     required this.longitude,
//   });

//   factory Alamat.fromJson(Map<String, dynamic> json) => Alamat(
//         latitude: json["latitude"]?.toDouble(),
//         longitude: json["longitude"]?.toDouble(),
//       );

//   Map<String, dynamic> toJson() => {
//         "latitude": latitude,
//         "longitude": longitude,
//       };
// }
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

class Expand {
  Expand();

  factory Expand.fromJson(Map<String, dynamic> json) => Expand();

  Map<String, dynamic> toJson() => {};
}
