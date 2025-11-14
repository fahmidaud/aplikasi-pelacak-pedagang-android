import 'package:meta/meta.dart';
import 'dart:convert';

// PenjualResultList penjualResultListFromJson(String str) =>
//     PenjualResultList.fromJson(json.decode(str));

List<PenjualResultList> penjualResultListFromJson(String str) =>
    List<PenjualResultList>.from(
        json.decode(str).map((x) => PenjualResultList.fromJson(x)));

// String penjualResultListToJson(PenjualResultList data) =>
//     json.encode(data.toJson());
String penjualResultListToJson(List<PenjualResultList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PenjualResultList {
  final Data data;
  final String status;

  PenjualResultList({
    required this.data,
    required this.status,
  });

  factory PenjualResultList.fromJson(Map<String, dynamic> json) =>
      PenjualResultList(
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "status": status,
      };
}

class Data {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<Item> items;

  Data({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        page: json["page"],
        perPage: json["perPage"],
        totalItems: json["totalItems"],
        totalPages: json["totalPages"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "perPage": perPage,
        "totalItems": totalItems,
        "totalPages": totalPages,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  final String id;
  final DateTime created;
  final DateTime updated;
  final String collectionId;
  final String collectionName;
  final Expand expand;
  final dynamic alamatKeliling;
  final AlamatTetap alamatTetap;
  final String email;
  final bool emailVisibility;
  final String idSocket;
  final bool isOnline;
  final String namaDagang;
  final String namaPenjual;
  final OnlineDetails onlineDetails;
  final String subLocality;
  final List<String> tipePenjual;
  final String username;
  final bool verified;

  Item({
    required this.id,
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
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        created: DateTime.parse(json["created"]),
        updated: DateTime.parse(json["updated"]),
        collectionId: json["collectionId"],
        collectionName: json["collectionName"],
        expand: Expand.fromJson(json["expand"]),
        alamatKeliling: json["alamat_keliling"],
        alamatTetap: AlamatTetap.fromJson(json["alamat_tetap"]),
        email: json["email"],
        emailVisibility: json["emailVisibility"],
        idSocket: json["id_socket"],
        isOnline: json["is_online"],
        namaDagang: json["nama_dagang"],
        namaPenjual: json["nama_penjual"],
        onlineDetails: OnlineDetails.fromJson(json["online_details"]),
        subLocality: json["sub_locality"],
        tipePenjual: List<String>.from(json["tipe_penjual"].map((x) => x)),
        username: json["username"],
        verified: json["verified"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created.toIso8601String(),
        "updated": updated.toIso8601String(),
        "collectionId": collectionId,
        "collectionName": collectionName,
        "expand": expand.toJson(),
        "alamat_keliling": alamatKeliling,
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
      };
}

class AlamatTetap {
  final double latitude;
  final double longitude;
  final PlaceDetails placeDetails;
  final String alamatLengkap;

  AlamatTetap({
    required this.latitude,
    required this.longitude,
    required this.placeDetails,
    required this.alamatLengkap,
  });

  factory AlamatTetap.fromJson(Map<String, dynamic> json) => AlamatTetap(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        placeDetails: PlaceDetails.fromJson(json["place_details"]),
        alamatLengkap: json["alamat_lengkap"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "place_details": placeDetails.toJson(),
        "alamat_lengkap": alamatLengkap,
      };
}

class PlaceDetails {
  final String subLocality;
  final String locality;
  final String administrativeArea;
  final String postalCode;
  final String country;

  PlaceDetails({
    required this.subLocality,
    required this.locality,
    required this.administrativeArea,
    required this.postalCode,
    required this.country,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) => PlaceDetails(
        subLocality: json["sub_locality"],
        locality: json["locality"],
        administrativeArea: json["administrative_area"],
        postalCode: json["postal_code"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "sub_locality": subLocality,
        "locality": locality,
        "administrative_area": administrativeArea,
        "postal_code": postalCode,
        "country": country,
      };
}

class Expand {
  Expand();

  factory Expand.fromJson(Map<String, dynamic> json) => Expand();

  Map<String, dynamic> toJson() => {};
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
