import 'package:meta/meta.dart';
import 'dart:convert';

List<PesananItems> pesananItemsFromJson(String str) => List<PesananItems>.from(
    json.decode(str).map((x) => PesananItems.fromJson(x)));

String pesananItemsToJson(List<PesananItems> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PesananItems {
  final AlamatTujuan alamatTujuan;
  final String collectionId;
  final String collectionName;
  final DateTime created;
  final Expand expand;
  final String id;
  final String idPembeli;
  final String idPenjual;
  final bool isBatal;
  final bool isSukses;
  final bool isTerima;
  final String timestampAwalPemesanan;
  final String timestampTerimaPemesanan;
  final DateTime updated;

  PesananItems({
    required this.alamatTujuan,
    required this.collectionId,
    required this.collectionName,
    required this.created,
    required this.expand,
    required this.id,
    required this.idPembeli,
    required this.idPenjual,
    required this.isBatal,
    required this.isSukses,
    required this.isTerima,
    required this.timestampAwalPemesanan,
    required this.timestampTerimaPemesanan,
    required this.updated,
  });

  factory PesananItems.fromJson(Map<String, dynamic> json) => PesananItems(
        alamatTujuan: AlamatTujuan.fromJson(json["alamat_tujuan"]),
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        created: DateTime.parse(json["created"]),
        expand: Expand.fromJson(json["expand"]),
        id: json["id"],
        idPembeli: json["id_pembeli"],
        idPenjual: json["id_penjual"],
        isBatal: json["is_batal"],
        isSukses: json["is_sukses"],
        isTerima: json["is_terima"],
        timestampAwalPemesanan: json["timestamp_awal_pemesanan"],
        timestampTerimaPemesanan: json["timestamp_terima_pemesanan"],
        updated: DateTime.parse(json["updated"]),
      );

  Map<String, dynamic> toJson() => {
        "alamat_tujuan": alamatTujuan.toJson(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "created": created.toIso8601String(),
        "expand": expand.toJson(),
        "id": id,
        "id_pembeli": idPembeli,
        "id_penjual": idPenjual,
        "is_batal": isBatal,
        "is_sukses": isSukses,
        "is_terima": isTerima,
        "timestamp_awal_pemesanan": timestampAwalPemesanan,
        "timestamp_terima_pemesanan": timestampTerimaPemesanan,
        "updated": updated.toIso8601String(),
      };
}

class AlamatTujuan {
  final String administrativeArea;
  final String alamatLengkap;
  final double latitude;
  final String locality;
  final double longitude;
  final String postalCode;
  final String subLocality;

  AlamatTujuan({
    required this.administrativeArea,
    required this.alamatLengkap,
    required this.latitude,
    required this.locality,
    required this.longitude,
    required this.postalCode,
    required this.subLocality,
  });

  factory AlamatTujuan.fromJson(Map<String, dynamic> json) => AlamatTujuan(
        administrativeArea: json["administrative_area"],
        alamatLengkap: json["alamat_lengkap"],
        latitude: json["latitude"]?.toDouble(),
        locality: json["locality"],
        longitude: json["longitude"]?.toDouble(),
        postalCode: json["postal_code"],
        subLocality: json["sub_locality"],
      );

  Map<String, dynamic> toJson() => {
        "administrative_area": administrativeArea,
        "alamat_lengkap": alamatLengkap,
        "latitude": latitude,
        "locality": locality,
        "longitude": longitude,
        "postal_code": postalCode,
        "sub_locality": subLocality,
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
