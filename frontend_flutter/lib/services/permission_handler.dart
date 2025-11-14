import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  void handleOpenAppSetting() async {
    await openAppSettings();
  }

  Future<bool?> cekApakahLokasiDiizinkanSepanjangWaktu() async {
    PermissionStatus status = await Permission.locationAlways.status;

    print('cekApakahLokasiDiizinkanSepanjangWaktu = ${status}');
    // cekApakahLokasiDiizinkanSepanjangWaktu = PermissionStatus.granted => Ini kalau `Izinkan sepanjang waktu`
    // PermissionStatus.denied => Ini kalau `Izinkan saat app dibuka`

    bool returnStatus;
    if (status == PermissionStatus.granted) {
      returnStatus = true;
      print('return cekApakahLokasiDiizinkanSepanjangWaktu = ${returnStatus}');
    } else {
      returnStatus = false;
    }

    return returnStatus;
  }
}
