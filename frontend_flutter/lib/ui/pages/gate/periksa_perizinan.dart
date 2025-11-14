import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../routes/router.dart';
import '../../../services/location.dart';
import '../../../services/permission_handler.dart';
import '../../../services/shared_preferences.dart';

class PeriksaPerizinanPage extends StatefulWidget {
  const PeriksaPerizinanPage({super.key});

  @override
  State<PeriksaPerizinanPage> createState() => _PeriksaPerizinanPageState();
}

class _PeriksaPerizinanPageState extends State<PeriksaPerizinanPage> {
  LocationService locationService = LocationService();
  PermissionStatus? permissionLocationStatus;

  String pesanProses = "Sedang memeriksa perizinan..";
  bool prosesCekPerizinanSelesai = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilSebelumHalamanLoad();
  }

  Future<void> antriPanggilSebelumHalamanLoad() async {
    await hapusStatusPromosiDaganganLokal();

    setState(() {
      pesanProses = "Sedang memeriksa perizinan lokasi device..";
    });
    await cekLokasiAndroid();

    setState(() {
      pesanProses = "Sedang memeriksa perizinan lokasi aplikasi..";
    });
    await cekLokasiAPP();

    bool? _hanldeCekIzinBackgroundLokasi =
        await hanldeCekIzinBackgroundLokasi();
    print('_hanldeCekIzinBackgroundLokasi ${_hanldeCekIzinBackgroundLokasi}');

    if (_hanldeCekIzinBackgroundLokasi == false) {
      await _showModalBottomSheet(context);
    } else {
      await hanldeCekPerizinanUlang();
    }
  }

  Future<void> hapusStatusPromosiDaganganLokal() async {
    final cariStatusPromosiDagangan = await sharedPreferencesService
        .cariLocalDataString('statusPromosiDagangan');

    if (cariStatusPromosiDagangan!) {
      await sharedPreferencesService
          .removeLocalDataString('statusPromosiDagangan');
    }
  }

  bool isServiceLocationAndroidEnabled = false;
  Future<void> cekLokasiAndroid() async {
    await checkServiceLocation();
    await requestServiceLocation();

    print(
        'cekLokasiAndroid() / isServiceLocationAndroidEnabled = $isServiceLocationAndroidEnabled');
  }

  Future<void> checkServiceLocation() async {
    print("Menjalankan checkServiceLocation() dari Lokasi");

    final serviceLocationEnabledResult = await locationService.checkService();
    print('Hasil serviceLocationEnabledResult = $serviceLocationEnabledResult');
    // serviceLocationEnabledResult berupa true(Lokasi Android NYALA) atau false

    setState(() {
      isServiceLocationAndroidEnabled = serviceLocationEnabledResult!;
    });
  }

  Future<void> requestServiceLocation() async {
    if (isServiceLocationAndroidEnabled == true) {
      print(
          "isServiceLocationAndroidEnabled itu TRUE(Lokasi Android SUDAH ON), MAKA TIDAK JADI requestServiceLocation()");
      return;
    }

    print(
        "isServiceLocationAndroidEnabled itu $isServiceLocationAndroidEnabled(Lokasi Android MASIH OFF), MAKA LAKUKAN requestServiceLocation()");
    final serviceLocationRequestedResult =
        await locationService.requestService();
    print("serviceLocationRequestedResult = $serviceLocationRequestedResult");

    setState(() {
      isServiceLocationAndroidEnabled = serviceLocationRequestedResult!;
    });
  }

  Future<void> cekLokasiAPP() async {
    await checkPermissionsLocation();
    await requestPermissionLocation();

    print(
        'cekLokasiAPP() / permissionLocationStatus = $permissionLocationStatus');
  }

  Future<void> checkPermissionsLocation() async {
    final permissionLocationStatusResult =
        await locationService.checkPermissions();
    print(
        'Hasil permissionLocationStatusResult = $permissionLocationStatusResult');
    // outputnya = PermissionStatus.denied

    setState(() {
      permissionLocationStatus = permissionLocationStatusResult;
    });
  }

  PermissionHandlerService _permissionHandlerService =
      PermissionHandlerService();

  Future<void> showPermissionDeniedForeverDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Aplikasi Ditolak'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda telah menolak izin lokasi secara permanen.'),
                Text(
                    'Untuk mengaktifkan izin, silakan buka pengaturan aplikasi dan izinkan lokasi secara manual.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Buka Pengaturan"),
              onPressed: () async {
                // await permission_pakcage.openAppSettings();
                _permissionHandlerService.handleOpenAppSetting();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermissionLocation() async {
    if (permissionLocationStatus == PermissionStatus.granted) {
      print(
          "permissionLocationStatus itu GRANTED(Lokasi APP SUDAH ON), MAKA TIDAK JADI requestPermissionLocation()");
      return;
    }

    print(
        "permissionLocationStatus itu $permissionLocationStatus(Lokasi APP MASIH OFF), MAKA LAKUKAN requestPermissionLocation()");
    final permissionLocationRequestedResult =
        await locationService.requestPermission();
    print(
        "permissionLocationRequestedResult = $permissionLocationRequestedResult");

    setState(() {
      permissionLocationStatus = permissionLocationRequestedResult;
    });

    if (permissionLocationStatus == PermissionStatus.deniedForever) {
      print(
          'permissionLocationStatus = deniedForever(LOKASI APLIKASI SUDAH DISET JANGAN IZINKAN OLEH USER), MAKA SEDANG MEMINTA IZIN BUKA SETTINGAN IZIN APLIKASI SECARA MANUAL..');

      showPermissionDeniedForeverDialog(context);
    }
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  bool isHarusNyalakanBackgroundLokasi = false;
  var collectionName = "", tipePenjual;
  Future<bool?> hanldeCekIzinBackgroundLokasi() async {
    // final _checkBackgroundMode = await locationService.checkBackgroundMode();
    final cekApakahLokasiDiizinkanSepanjangWaktu =
        await _permissionHandlerService
            .cekApakahLokasiDiizinkanSepanjangWaktu();
    print(
        'hanldeCekIzinBackgroundLokasi | cekApakahLokasiDiizinkanSepanjangWaktu = ${cekApakahLokasiDiizinkanSepanjangWaktu}');

    // PermissionStatus status = cekApakahLokasiDiizinkanSepanjangWaktu;

    bool? returnStatus;
    if (cekApakahLokasiDiizinkanSepanjangWaktu != true) {
      print("Oopps belum bisa background lokasi");

      returnStatus = false;
      final cariLocalDataStringAuthStore =
          await sharedPreferencesService.cariLocalDataString('authStoreData');

      if (cariLocalDataStringAuthStore!) {
        final getLocalAuthStoreData =
            await sharedPreferencesService.getLocalDataString('authStoreData');

        var toString = jsonEncode(getLocalAuthStoreData);
        var toMap = jsonDecode(toString);

        var modelAuthStore = toMap['model'];

        collectionName = modelAuthStore['collectionName'];

        if (collectionName == "pengguna_penjual") {
          tipePenjual = modelAuthStore['tipe_penjual'];
          if (tipePenjual[0] == "Keliling") {
            setState(() {
              isHarusNyalakanBackgroundLokasi = true;
            });
          }
        }
      }

      return returnStatus;
    } else {
      print("Yeyy sudah bisa background lokasi");
      returnStatus = true;

      return returnStatus;
    }
  }

  bool isSuksesModeLokasiBackgroud = false;
  Future<void> _showModalBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Aktifkan lokasi background',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                "Mohon aktifkan lokasi background mode dengan cara 'Izinkan sepanjang waktu' dipengaturan aplikasi.",
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  isHarusNyalakanBackgroundLokasi == false
                      ? ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);

                            await hanldeCekPerizinanUlang();
                          },
                          child: const Text('Nanti saja'),
                        )
                      : const SizedBox(),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      final _handleEnableBackgroundMode =
                          await locationService.handleEnableBackgroundMode();

                      var toMap = jsonDecode(_handleEnableBackgroundMode);

                      if (toMap['status'] != false) {
                        setState(() {
                          isSuksesModeLokasiBackgroud = true;
                        });
                      }

                      await hanldeCekPerizinanUlang();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> hanldeCekPerizinanUlang() async {
    setState(() {
      prosesCekPerizinanSelesai = true;
    });

    context.pushReplacementNamed(Routes.instalisasiDataLokal);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: prosesCekPerizinanSelesai == false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(pesanProses),
                ],
              )
            : Center(
                child: isHarusNyalakanBackgroundLokasi
                    ? isServiceLocationAndroidEnabled == false ||
                            permissionLocationStatus !=
                                PermissionStatus.granted ||
                            isSuksesModeLokasiBackgroud == false
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Perizinan aplikasi gagal.'),
                              const SizedBox(
                                height: 11,
                              ),
                              ElevatedButton(
                                child: const Text(
                                  'Coba lagi',
                                ),
                                onPressed: () async {
                                  context.pushReplacementNamed(
                                    Routes.gatePage,
                                    queryParameters: {
                                      "is_sudah_diperiksa": "false",
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        : const CircularProgressIndicator()
                    : isServiceLocationAndroidEnabled == false ||
                            permissionLocationStatus != PermissionStatus.granted
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Perizinan aplikasi gagal.'),
                              const SizedBox(
                                height: 11,
                              ),
                              ElevatedButton(
                                child: const Text(
                                  'Coba lagi',
                                ),
                                onPressed: () async {
                                  context.pushReplacementNamed(
                                    Routes.gatePage,
                                    queryParameters: {
                                      "is_sudah_diperiksa": "false",
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        : const CircularProgressIndicator(),
              ),
      ),
    );
  }
}
