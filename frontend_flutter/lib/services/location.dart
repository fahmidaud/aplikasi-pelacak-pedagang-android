import 'dart:async';
import 'dart:convert';

import 'package:location/location.dart';
import 'package:flutter/services.dart';

export 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  // Berfungsi untk MELIHAT INFORMASI MENGENAI LOKASI ANDROID
  Future<bool?> checkService() async {
    final serviceLocationEnabledResult = await _location.serviceEnabled();
    return serviceLocationEnabledResult;
  }

  // Berfungsi untk MEMINTA REKUEST UNTUK MENYALAKAN LOKASI ANDROID
  Future<bool?> requestService() async {
    final serviceLocationRequestedResult = await _location.requestService();
    return serviceLocationRequestedResult;
  }

  // Berfungsi untk MELIHAT INFORMASI LOKASI APP
  Future<PermissionStatus> checkPermissions() async {
    final permissionLocationStatusResult = await _location.hasPermission();

    return permissionLocationStatusResult;
  }

  // Berfungsi untk MEMINTA REQUEST LOKASI APLIKASI
  Future<PermissionStatus> requestPermission() async {
    final permissionLocationRequestedResult =
        await _location.requestPermission();

    return permissionLocationRequestedResult;
  }

  Future<LocationData> getLocation() async {
    final locationResult = await _location.getLocation();

    return locationResult;
  }

  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

  // Berfungsi untk MENGIRIMKAN LOKASI TERKINI PENGGUNA KE UI
  Stream<LocationData?> listenLocation() {
    return _location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        // Handle error
      }
      _locationSubscription?.cancel();
    });
  }

  // Berfungsi untk STOP MENGIRIMKAN LOKASI TERKINI PENGGUNA KE UI
  Future<void> stopListen() async {
    await _locationSubscription?.cancel();
  }

  // Berfungsi untk MELIHAT INFO APAKAH IZIN LOKASI YANG DIPILIH ADALAH "IZINKAN SEPANJANG WAKTU(TRUE) ATAU TIDAK"
  Future<bool> checkBackgroundMode() async {
    final isBackgroundModeEnabled = await _location.isBackgroundModeEnabled();
    print('isBackgroundModeEnabled = ${isBackgroundModeEnabled}');

    return isBackgroundModeEnabled;
  }

  // Berfungsi untk MENGARAHKAN USER UNTUK MEMILIH "IZINKAN SEPANJANG WAKTU" PADA LOKASI
  // Manfaatnya listen_lokasi BISA TETAP BERJALAN KETIKA APLIKASI DI MINIMAZE(TEKAN TOMBOL TENGAH)
  Future<String> handleEnableBackgroundMode() async {
    try {
      final enableBackgroundMode =
          await _location.enableBackgroundMode(enable: true);

      var obj = {"message": "success", "status": enableBackgroundMode};

      String convertToJSONString = jsonEncode(obj);

      return convertToJSONString;
    } on PlatformException catch (err) {
      print("err dari handleEnableBackgroundMode");
      print(err);

      print("err.code hasilnya dibawah,");
      print(err.code);

      var obj = {"message": err.code, "status": false};

      String convertToJSONString = jsonEncode(obj);

      return convertToJSONString;
    }
  }
}
