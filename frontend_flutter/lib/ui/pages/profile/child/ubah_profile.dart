import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../services/geocoding.dart';
import '../../../../services/geolocator.dart';
import '../../../../services/location.dart';
import '../../../../services/permission_handler.dart';
import '../../../../services/pocketbase.dart';
import '../../../../services/shared_preferences.dart';

class UbahProfilePage extends StatefulWidget {
  const UbahProfilePage(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<UbahProfilePage> createState() => _UbahProfilePageState();
}

class _UbahProfilePageState extends State<UbahProfilePage> {
  final TextEditingController namaPenggunaController =
      TextEditingController(text: "");
  final TextEditingController namaDaganganController =
      TextEditingController(text: "");
  final TextEditingController alamatLengkapController =
      TextEditingController(text: "");

  String? inputNamaPenggunaMsgError,
      inputNamaDaganganMsgError,
      inputAlamatLengkapMsgError;

  String? namaPengguna;

  String? idPenjual, tipePenjual, namaDagangan;

  String? idPembeli;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null) {
      final settings = route.settings;
      final arguments = settings.arguments as Map<String, dynamic>;

      if (arguments.containsKey("id_penjual")) {
        idPenjual = arguments["id_penjual"];
      }

      if (arguments.containsKey("tipe_penjual")) {
        tipePenjual = arguments["tipe_penjual"];

        if (tipePenjual == 'Tetap') {
          handleGetAlamatPenjualTetap();
        }
      }

      if (arguments.containsKey("nama_penjual")) {
        namaPengguna = arguments["nama_penjual"];

        setState(() {
          namaPenggunaController.text = namaPengguna!;
        });
      }

      if (arguments.containsKey("nama_dagangan")) {
        namaDagangan = arguments["nama_dagangan"];

        setState(() {
          namaDaganganController.text = namaDagangan!;
        });
      }

      if (arguments.containsKey("id_pembeli")) {
        idPembeli = arguments["id_pembeli"];
      }

      if (arguments.containsKey("nama_pembeli")) {
        namaPengguna = arguments["nama_pembeli"];

        setState(() {
          namaPenggunaController.text = namaPengguna!;
        });
      }
    }
  }

  PocketbaseService pocketbaseService = PocketbaseService();
  GeocodingService geocodingService = GeocodingService();
  String? subLocality, locality, administrativeArea, postalCode, country;
  String? alamatLengkap;
  void handleGetAlamatPenjualTetap() async {
    final getPenggunaPenjual =
        await pocketbaseService.getPenggunaPenjual(idPenjual);

    var toString = jsonEncode(getPenggunaPenjual);
    var toMap = jsonDecode(toString);
    var alamatTetap = toMap['alamat_tetap'];
    double latitude = alamatTetap['latitude'];
    double longitude = alamatTetap['longitude'];

    final getPlace = await geocodingService.getPlace(latitude, longitude);
    setState(() {
      subLocality = getPlace['subLocality'];
      locality = getPlace['locality'];
      administrativeArea = getPlace['administrativeArea'];
      postalCode = getPlace['postalCode'];
      country = getPlace['country'];
    });

    alamatLengkap = alamatTetap['alamat_lengkap'];
  }

  bool isUpdateAlamat = false;
  void showModalBottom() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Anda sedang berada di Toko?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Pastikan anda sedang berada ditoko saat mengisi alamat.',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isUpdateAlamat = true;
                      });
                      Navigator.pop(context);

                      await handleGetLokasiTerbaru();
                    },
                    child: const Text('Ya'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> handleGetLokasiTerbaru() async {
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
      indicator: const CircularProgressIndicator(),
      dismissOnTap: false,
    );

    await cekLokasiAndroid();
    await cekLokasiAPP();

    if (isServiceLocationAndroidEnabled == false) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Gagal Mengaktifkan Lokasi Android'),
          content: const Text('Mohon nyalakan Lokasi di Android anda.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    if (permissionLocationStatus == PermissionStatus.deniedForever) {
      print(
          'permissionLocationStatus = deniedForever(LOKASI APLIKASI SUDAH DISET JANGAN IZINKAN OLEH USER), MAKA SEDANG MEMINTA IZIN BUKA SETTINGAN IZIN APLIKASI SECARA MANUAL..');

      showPermissionDeniedForeverDialog(context);
    }

    if (isServiceLocationAndroidEnabled == true &&
        permissionLocationStatus == PermissionStatus.granted) {
      await handleGetLocation();
    }

    await EasyLoading.dismiss();
  }

  bool isServiceLocationAndroidEnabled = false;
  Future<void> cekLokasiAndroid() async {
    await checkServiceLocation();
    await requestServiceLocation();

    print(
        'cekLokasiAndroid() / isServiceLocationAndroidEnabled = $isServiceLocationAndroidEnabled');
  }

  LocationService locationService = LocationService();

  Future<void> checkServiceLocation() async {
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

  PermissionStatus? permissionLocationStatus;
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
      barrierDismissible:
          false, // Dialog tidak bisa ditutup dengan mengetuk di luar dialog
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
  }

  GeolocatorServices geolocatorServices = GeolocatorServices();

  double? latitudeNew, longitudeNew;
  String? subLocalityNew,
      localityNew,
      administrativeAreaNew,
      postalCodeNew,
      countryNew;
  Future<void> handleGetLocation() async {
    final handleGetLastKnownPosition =
        await geolocatorServices.handleGetLastKnownPosition();

    if (handleGetLastKnownPosition != null) {
      latitudeNew = handleGetLastKnownPosition.latitude;
      longitudeNew = handleGetLastKnownPosition.longitude;
    }

    if (handleGetLastKnownPosition == null) {
      final getLocation = await locationService.getLocation();
      print("getLocation ${getLocation}");

      latitudeNew = getLocation.latitude!;
      longitudeNew = getLocation.longitude!;
    }

    final getPlace = await geocodingService.getPlace(latitudeNew, longitudeNew);
    print('getPlace = ${getPlace}');

    setState(() {
      subLocalityNew = getPlace['subLocality'];
      localityNew = getPlace['locality'];
      administrativeAreaNew = getPlace['administrativeArea'];
      postalCodeNew = getPlace['postalCode'];
      countryNew = getPlace['country'];
    });
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  bool isMemenuhiSyaratUpdateProfile = false;
  Future<void> handleUpdateProfilePB() async {
    await EasyLoading.show(
      status: 'Sedang mengupdate profile..',
      maskType: EasyLoadingMaskType.black,
      indicator: const CircularProgressIndicator(),
      dismissOnTap: false,
    );

    var rolePengguna = '';
    var idPengguna = '';
    var obj = <String, dynamic>{};
    if (idPembeli != null) {
      // Pembeli
      rolePengguna = 'Pembeli';
      idPengguna = idPembeli!;

      obj = <String, dynamic>{"nama": namaPenggunaController.text};
    }

    if (idPenjual != null) {
      // Penjual
      rolePengguna = 'Penjual';
      idPengguna = idPenjual!;

      if (tipePenjual == 'Tetap') {
        if (isUpdateAlamat) {
          var objAlamatTetap = {
            "latitude": latitudeNew,
            "longitude": longitudeNew,
            "alamat_lengkap": alamatLengkapController.text
          };
          obj = <String, dynamic>{
            "nama_dagang": namaDaganganController.text,
            "nama_penjual": namaPenggunaController.text,
            "alamat_tetap": objAlamatTetap
          };
        } else {
          obj = <String, dynamic>{
            "nama_dagang": namaDaganganController.text,
            "nama_penjual": namaPenggunaController.text
          };
        }
      } else {
        obj = <String, dynamic>{
          "nama_dagang": namaDaganganController.text,
          "nama_penjual": namaPenggunaController.text
        };
      }
    }

    final updateProfilePengguna = await pocketbaseService.updateProfilePengguna(
        rolePengguna, idPengguna, obj);

    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var tokenAuthStore = toMap['token'];

    var objAuthStoreNew = {
      "token": tokenAuthStore,
      "model": updateProfilePengguna
    };
    await sharedPreferencesService.removeLocalDataString('authStoreData');
    await sharedPreferencesService.setLocalDataString(
        'authStoreData', objAuthStoreNew);

    await EasyLoading.dismiss();

    await EasyLoading.showSuccess('Sukses update profile!');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    void handleUpdateProfile() async {
      if (idPembeli != null) {
        // Pembeli
        if (namaPenggunaController.text.length != 0) {
          setState(() {
            isMemenuhiSyaratUpdateProfile = true;
          });
        } else {
          setState(() {
            isMemenuhiSyaratUpdateProfile = false;
          });
        }
      }

      if (idPenjual != null) {
        // Penjual

        if (namaPenggunaController.text.length != 0) {
          setState(() {
            isMemenuhiSyaratUpdateProfile = true;
          });
        } else {
          setState(() {
            isMemenuhiSyaratUpdateProfile = false;
          });
        }

        if (namaDaganganController.text.length != 0) {
          setState(() {
            isMemenuhiSyaratUpdateProfile = true;
          });
        } else {
          setState(() {
            isMemenuhiSyaratUpdateProfile = false;
          });
        }

        if (tipePenjual == 'Tetap') {
          if (isUpdateAlamat) {
            if (alamatLengkapController.text.length != 0) {
              setState(() {
                isMemenuhiSyaratUpdateProfile = true;
              });
            } else {
              setState(() {
                isMemenuhiSyaratUpdateProfile = false;
              });
            }
          }
        }
      }

      if (isMemenuhiSyaratUpdateProfile) {
        await handleUpdateProfilePB();
      } else {
        await EasyLoading.showInfo("Mohon isi form dengan benar!");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah profile'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Nama anda *", //(opsional)
                errorText: inputNamaPenggunaMsgError == null
                    ? null
                    : inputNamaPenggunaMsgError,
              ),
              controller: namaPenggunaController,
              // controller:
              //     TextEditingController(text:  namaPenggunaController)
              onChanged: (value) {
                // print(value);
                if (value.length != 0) {
                  setState(() {
                    inputNamaPenggunaMsgError = null;
                  });
                } else {
                  setState(() {
                    inputNamaPenggunaMsgError = "Tidak boleh kosong";
                  });
                }
              },
            ),
            idPenjual != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Nama dagangan *",
                          errorText: inputNamaDaganganMsgError == null
                              ? null
                              : inputNamaDaganganMsgError,
                        ),
                        controller: namaDaganganController,
                        onChanged: (value) {
                          // print(value);
                          if (value.length != 0) {
                            setState(() {
                              inputNamaDaganganMsgError = null;
                            });
                          } else {
                            setState(() {
                              inputNamaDaganganMsgError = "Tidak boleh kosong";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 11.0),
                      tipePenjual == 'Tetap'
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              child: isUpdateAlamat == false
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Alamat ",
                                              style: TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                textStyle: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              onPressed: () =>
                                                  showModalBottom(),
                                              child: const Text('Ubah'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        alamatLengkap != null &&
                                                subLocality != null &&
                                                locality != null &&
                                                administrativeArea != null &&
                                                postalCode != null
                                            ? Text(
                                                '$alamatLengkap. $subLocality, $locality, $administrativeArea, $postalCode',
                                                style: TextStyle(
                                                  fontSize: 14.4,
                                                ),
                                              )
                                            : Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        TextField(
                                          minLines:
                                              1, // Tinggi minimum satu baris
                                          maxLines:
                                              7, // Untuk tumbuh secara dinamis
                                          enabled:
                                              false, // Mengatur TextField menjadi non-interaktif
                                          decoration: const InputDecoration(
                                            labelText: "Alamat baru anda",
                                          ),
                                          // Masukkan teks default jika diperlukan
                                          controller: TextEditingController(
                                              text:
                                                  '$subLocalityNew, $localityNew, $administrativeAreaNew, $postalCodeNew'),
                                        ),
                                        const SizedBox(height: 20.0),
                                        TextField(
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            labelText:
                                                "Alamat lengkap yang baru *",
                                            errorText:
                                                inputAlamatLengkapMsgError ==
                                                        null
                                                    ? null
                                                    : inputAlamatLengkapMsgError,
                                          ),
                                          controller: alamatLengkapController,
                                          onChanged: (value) {
                                            // print(value);
                                            if (value.length != 0) {
                                              setState(() {
                                                inputAlamatLengkapMsgError =
                                                    null;
                                              });
                                            } else {
                                              setState(() {
                                                inputAlamatLengkapMsgError =
                                                    "Tidak boleh kosong";
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ))
                          : const SizedBox(),
                    ],
                  )
                : const SizedBox(),
            const SizedBox(
              height: 26,
            ),
            ElevatedButton(
              onPressed: () => handleUpdateProfile(),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
