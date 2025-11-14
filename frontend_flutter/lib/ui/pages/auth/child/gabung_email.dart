import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../../../routes/router.dart';
import '../../../../services/geocoding.dart';
import '../../../../services/geolocator.dart';
import '../../../../services/location.dart';
import '../../../../services/permission_handler.dart';
import '../../../../services/pocketbase.dart';
import '../../../../services/shared_preferences.dart';

class GabungViaEmailPage extends StatefulWidget {
  const GabungViaEmailPage({super.key});

  @override
  State<GabungViaEmailPage> createState() => _GabungViaEmailPageState();
}

class _GabungViaEmailPageState extends State<GabungViaEmailPage> {
  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  int _currentStep = 0;
  int? rolePengguna = 1;
  int? tipePenjual = 1;

  final TextEditingController _namaPengguna = TextEditingController(text: "");
  final TextEditingController _namaDagangan = TextEditingController(text: "");
  final TextEditingController _email = TextEditingController(text: "");
  bool? isSudahGabung;

  final TextEditingController _password = TextEditingController(text: "");
  bool _obscureTextPassword = true;
  int countPassword = 0;
  bool isPassedRequirePassword = false;

  final TextEditingController _alamatLengkap = TextEditingController(text: "");

  String? inputNamaPenggunaMsgError,
      inputNamaDaganganMsgError,
      inputEmailMsgError,
      inputPasswordMsgError,
      inputAlamatLengkapMsgError;

  bool isFinishCekIzinLokasi = false, isLoadingIsiAlamat = false;

  void setNullInputan() {
    setState(() {
      _email.text = "";
      _password.text = "";
      _namaPengguna.text = "";
      _namaDagangan.text = "";
      _alamatLengkap.text = "";
    });
  }

  PocketbaseService pocketbaseService = PocketbaseService();
  List<Step> stepList() => [
        Step(
          title: const Text('Account'),
          isActive: _currentStep >= 0,
          state: _currentStep <= 0 ? StepState.editing : StepState.complete,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Kamu adalah?',
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 5.0,
                children: [
                  ChoiceChip(
                    label: const Text('Pembeli'),
                    selected: rolePengguna == 1,
                    onSelected: (bool selected) {
                      setState(() {
                        rolePengguna = 1;
                      });

                      setNullInputan();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Penjual'),
                    selected: rolePengguna == 2,
                    onSelected: (bool selected) {
                      setState(() {
                        rolePengguna = 2;
                      });

                      setNullInputan();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Email *",
                  errorText:
                      inputEmailMsgError == null ? null : inputEmailMsgError,
                ),
                controller: _email,
                onChanged: (value) async {
                  print(value);
                  if (value.length != 0) {
                    setState(() {
                      inputEmailMsgError = null;
                    });
                  }

                  final bool isValidEmail = EmailValidator.validate(value);
                  if (isValidEmail) {
                    setState(() {
                      inputEmailMsgError = null;
                    });

                    String jenisPengguna = "";
                    if (rolePengguna == 1) {
                      jenisPengguna = 'pembeli';
                    } else {
                      jenisPengguna = 'penjual';
                    }
                    final cekApakahSudahGabung = await pocketbaseService
                        .cekApakahSudahGabung(jenisPengguna, _email.text);

                    if (cekApakahSudahGabung!.totalItems == 0) {
                      setState(() {
                        isSudahGabung = false;
                      });
                    } else {
                      setState(() {
                        isSudahGabung = true;
                      });
                    }
                  } else {
                    if (value.length == 0) {
                      setState(() {
                        inputEmailMsgError = null;
                      });
                    } else {
                      setState(() {
                        inputEmailMsgError = "Mohon isi email yang valid.";
                      });
                    }
                  }
                },
              ),
              isSudahGabung == false
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rolePengguna == 2
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20.0),
                                  const Text(
                                    'Penjual tipe?',
                                  ),
                                  const SizedBox(height: 10.0),
                                  Wrap(
                                    spacing: 5.0,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('Keliling'),
                                        selected: tipePenjual == 1,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            tipePenjual = 1;
                                          });
                                        },
                                      ),
                                      ChoiceChip(
                                        label: const Text('Tetap'),
                                        selected: tipePenjual == 2,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            tipePenjual = 2;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(height: 20.0),
                        TextField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: rolePengguna == 1
                                ? "Nama anda *"
                                : tipePenjual == 1
                                    ? "Nama penjual *"
                                    : "Nama penjual *", //(opsional)
                            errorText: inputNamaPenggunaMsgError == null
                                ? null
                                : inputNamaPenggunaMsgError,
                          ),
                          controller: _namaPengguna,
                          onChanged: (value) {
                            if (value.length != 0) {
                              setState(() {
                                inputNamaPenggunaMsgError = null;
                              });
                            }
                          },
                        ),
                        rolePengguna == 2
                            ? Column(
                                children: [
                                  const SizedBox(height: 20.0),
                                  TextField(
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Nama dagangan *",
                                      errorText:
                                          inputNamaDaganganMsgError == null
                                              ? null
                                              : inputNamaDaganganMsgError,
                                    ),
                                    controller: _namaDagangan,
                                    onChanged: (value) {
                                      // print(value);
                                      if (value.length != 0) {
                                        setState(() {
                                          inputNamaDaganganMsgError = null;
                                        });
                                      }
                                    },
                                  )
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 20,
                        ),
                        TextField(
                          obscureText: _obscureTextPassword,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Password *",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureTextPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureTextPassword = !_obscureTextPassword;
                                });
                              },
                            ),
                            errorText: inputPasswordMsgError == null
                                ? null
                                : inputPasswordMsgError,
                            helperText: isPassedRequirePassword
                                ? null
                                : 'Terdiri dari 8 karakter atau lebih',
                            counterText: isPassedRequirePassword
                                ? null
                                : '${countPassword} characters',
                          ),
                          controller: _password,
                          onChanged: (value) {
                            // print(value);
                            if (value.length != 0) {
                              setState(() {
                                inputPasswordMsgError = null;
                              });
                            }

                            setState(() {
                              countPassword = value.length;
                            });

                            if (countPassword >= 8) {
                              setState(() {
                                isPassedRequirePassword = true;
                              });
                            } else {
                              setState(() {
                                isPassedRequirePassword = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        rolePengguna == 2 &&
                                tipePenjual == 2 &&
                                isFinishCekIzinLokasi == false
                            ? OutlinedButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Tidak'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await cekLokasiAndroid();
                                                    await cekLokasiAPP();

                                                    Navigator.pop(context);

                                                    if (isServiceLocationAndroidEnabled ==
                                                        false) {
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Gagal Mengaktifkan Lokasi Android'),
                                                          content: const Text(
                                                              'Mohon nyalakan Lokasi di Android anda.'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      'OK'),
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }

                                                    if (permissionLocationStatus ==
                                                        PermissionStatus
                                                            .deniedForever) {
                                                      print(
                                                          'permissionLocationStatus = deniedForever(LOKASI APLIKASI SUDAH DISET JANGAN IZINKAN OLEH USER), MAKA SEDANG MEMINTA IZIN BUKA SETTINGAN IZIN APLIKASI SECARA MANUAL..');

                                                      showPermissionDeniedForeverDialog(
                                                          context);
                                                    }

                                                    if (isServiceLocationAndroidEnabled ==
                                                            true &&
                                                        permissionLocationStatus ==
                                                            PermissionStatus
                                                                .granted) {
                                                      setState(() {
                                                        isLoadingIsiAlamat =
                                                            true;
                                                      });
                                                      await handleGetLocation();
                                                      setState(() {
                                                        isLoadingIsiAlamat =
                                                            false;
                                                        isFinishCekIzinLokasi =
                                                            true;
                                                      });
                                                    }
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
                                },
                                child: Text(isLoadingIsiAlamat
                                    ? 'Tunggu..'
                                    : 'Isi alamat'),
                              )
                            : const SizedBox(height: 20.0),
                        rolePengguna == 2 &&
                                tipePenjual == 2 &&
                                isFinishCekIzinLokasi == true
                            ? Column(
                                children: [
                                  const Text(
                                    'Alamat',
                                  ),
                                  const SizedBox(height: 20.0),
                                  TextField(
                                    minLines: 1, // Tinggi minimum satu baris
                                    maxLines: 7, // Untuk tumbuh secara dinamis
                                    enabled:
                                        false, // Mengatur TextField menjadi non-interaktif
                                    decoration: const InputDecoration(
                                      labelText: "Alamat anda",
                                    ),
                                    // Masukkan teks default jika diperlukan
                                    controller: TextEditingController(
                                        text:
                                            '$subLocality, $locality, $administrativeArea, $postalCode'),
                                  ),
                                  const SizedBox(height: 20.0),
                                  TextField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Alamat lengkap *",
                                    ),
                                    controller: _alamatLengkap,
                                    onChanged: (value) {
                                      // print(value);
                                      if (value.length != 0) {
                                        setState(() {
                                          inputAlamatLengkapMsgError = null;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    )
                  : isSudahGabung == true
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              obscureText: _obscureTextPassword,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureTextPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextPassword =
                                          !_obscureTextPassword;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                                labelText: "Password *",
                                errorText: inputPasswordMsgError == null
                                    ? null
                                    : inputPasswordMsgError,
                                helperText: isPassedRequirePassword
                                    ? null
                                    : 'Terdiri dari 8 karakter atau lebih',
                                counterText: isPassedRequirePassword
                                    ? null
                                    : '${countPassword} characters',
                              ),
                              controller: _password,
                              onChanged: (value) {
                                // print(value);
                                if (value.length != 0) {
                                  setState(() {
                                    inputPasswordMsgError = null;
                                  });
                                }

                                setState(() {
                                  countPassword = value.length;
                                });

                                if (countPassword >= 8) {
                                  setState(() {
                                    isPassedRequirePassword = true;
                                  });
                                } else {
                                  setState(() {
                                    isPassedRequirePassword = false;
                                  });
                                }
                              },
                            ),
                          ],
                        )
                      : SizedBox(),
            ],
          ),
        ),
        Step(
          title: Text('Confirm'),
          isActive: _currentStep >= 2,
          state: StepState.complete,
          content: Column(
            children: [
              rolePengguna == 1
                  ? const Text("Kamu sebagai Pembeli dengan,")
                  : isSudahGabung == false
                      ? Text(tipePenjual == 1
                          ? "Kamu sebagai Penjual Keliling dengan,"
                          : "Kamu sebagai Penjual Tetap dengan,")
                      : Text("Kamu sebagai Penjual dengan,"),
              isSudahGabung == false
                  ? Column(
                      children: [
                        const SizedBox(height: 20.0),
                        TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: rolePengguna == 1
                                ? "Nama anda"
                                : "Nama penjual",
                          ),
                          controller:
                              TextEditingController(text: _namaPengguna.text),
                        ),
                      ],
                    )
                  : const SizedBox(),
              rolePengguna == 2 && isSudahGabung == false
                  ? Column(
                      children: [
                        const SizedBox(height: 20.0),
                        TextField(
                          enabled:
                              false, // Mengatur TextField menjadi non-interaktif
                          decoration: const InputDecoration(
                            labelText: "Nama dagangan anda",
                          ),
                          // Masukkan teks default jika diperlukan
                          controller:
                              TextEditingController(text: _namaDagangan.text),
                        )
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 20.0),
              TextField(
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Email anda',
                ),
                controller: TextEditingController(text: _email.text),
              ),
              const SizedBox(height: 20.0),
              TextField(
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Password anda',
                ),
                controller: TextEditingController(text: _password.text),
              ),
              rolePengguna == 2 &&
                      tipePenjual == 2 &&
                      isFinishCekIzinLokasi == true
                  ? Column(
                      children: [
                        const SizedBox(height: 20.0),
                        TextField(
                          minLines: 1, // Tinggi minimum satu baris
                          maxLines: 7, // Untuk tumbuh secara dinamis
                          enabled:
                              false, // Mengatur TextField menjadi non-interaktif
                          decoration: const InputDecoration(
                            labelText: "Alamat anda",
                          ),
                          // Masukkan teks default jika diperlukan
                          controller: TextEditingController(
                              text:
                                  '$subLocality, $locality, $administrativeArea, $postalCode'),
                        ),
                        const SizedBox(height: 20.0),
                        TextField(
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Alamat lengkap anda',
                            ),
                            controller: TextEditingController(
                                text: _alamatLengkap.text))
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ];

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
  }

  GeolocatorServices geolocatorServices = GeolocatorServices();
  GeocodingService geocodingService = GeocodingService();

  double? latitude, longitude;
  String? subLocality, locality, administrativeArea, postalCode, country;
  Future<void> handleGetLocation() async {
    final handleGetLastKnownPosition =
        await geolocatorServices.handleGetLastKnownPosition();

    if (handleGetLastKnownPosition != null) {
      latitude = handleGetLastKnownPosition.latitude;
      longitude = handleGetLastKnownPosition.longitude;
    }

    if (handleGetLastKnownPosition == null) {
      final getLocation = await locationService.getLocation();

      latitude = getLocation.latitude!;
      longitude = getLocation.longitude!;
    }

    final getPlace = await geocodingService.getPlace(latitude, longitude);

    setState(() {
      subLocality = getPlace['subLocality'];
      locality = getPlace['locality'];
      administrativeArea = getPlace['administrativeArea'];
      postalCode = getPlace['postalCode'];
      country = getPlace['country'];
    });
  }

  Future<void> _showModalBottomSheet(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Sudah isi dengan benar?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Jika anda merasa salah mengisi form, silahkan diperbaiki terlebih dahulu.',
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
                        Navigator.pop(context);
                        await _authentikasiPengguna();
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  // FUNGSI UNTUK BOTTOM MODAL

  String? titleAlert, bodyAlert, btnTextAlert;

  bool isSudahGabungReverse = false;
  String jenisPenggunaReverse = "";
  Future<void> cekApakahSudahGabungReverse() async {
    if (rolePengguna == 1) {
      jenisPenggunaReverse = 'penjual';
    } else {
      jenisPenggunaReverse = 'pembeli';
    }
    final cekApakahSudahGabung = await pocketbaseService.cekApakahSudahGabung(
        jenisPenggunaReverse, _email.text);

    if (cekApakahSudahGabung!.totalItems > 0) {
      setState(() {
        isSudahGabungReverse = true;
      });
    }
  }

  Future<void> showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Dialog tidak bisa ditutup dengan mengetuk di luar dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleAlert!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(bodyAlert!),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(btnTextAlert!),
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String? identifier;
  Future<void> handleTambahPenggunaPembeli() async {
    await pocketbaseService.tambahPenggunaPembeli(
        _email.text, _password.text, _namaPengguna.text);
  }

  Future<void> handleAuthWithPasswordPenggunaPembeli() async {
    final authWithPasswordPenggunaPembeli = await pocketbaseService
        .authWithPasswordPenggunaPembeli(_email.text, _password.text);

    if (authWithPasswordPenggunaPembeli!['data'] == null) {
      setState(() {
        titleAlert = 'Password salah.';
        bodyAlert = 'Password yang anda kirim salah.';
        btnTextAlert = 'Tutup';
      });

      await showAlertDialog(context);
    }
  }

  Future<void> handleTambahPenggunaPenjual() async {
    var alamatTetap = {};
    if (tipePenjual == 2) {
      alamatTetap = {
        "latitude": latitude,
        "longitude": longitude,
        "alamat_lengkap": _alamatLengkap.text
      };
    }

    await pocketbaseService.tambahPenggunaPenjual(
        _email.text,
        _password.text,
        _namaDagangan.text,
        _namaPengguna.text,
        tipePenjual,
        alamatTetap,
        subLocality);
  }

  Future<void> handleAuthWithPasswordPenggunaPenjual() async {
    final authWithPasswordPenggunaPenjual = await pocketbaseService
        .authWithPasswordPenggunaPenjual(_email.text, _password.text);

    if (authWithPasswordPenggunaPenjual!['data'] == null) {
      setState(() {
        titleAlert = 'Password salah.';
        bodyAlert = 'Password yang anda kirim salah.';
        btnTextAlert = 'Tutup';
      });

      await showAlertDialog(context);
    }
  }

  Future<void> handleSetNonActivePenggunaAnonim() async {
    try {
      identifier = await UniqueIdentifier.serial;

      final cekPenggunaAnonim =
          await pocketbaseService.cekPenggunaAnonim(identifier);

      var toString = jsonEncode(cekPenggunaAnonim);
      var toMap = jsonDecode(toString);
      var idPenggunaAnonim = toMap['items'][0]['id'];

      final cekAuth = await pocketbaseService.cekAuth();

      await pocketbaseService.setStatusActivePenggunaAnonim(
          idPenggunaAnonim, cekAuth);
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;
  }

  Future<void> _authentikasiPengguna() async {
    print("Sedang _authentikasiPengguna");

    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
      indicator: const CircularProgressIndicator(),
      dismissOnTap: false,
    );

    await cekApakahSudahGabungReverse();

    if (isSudahGabungReverse == false) {
      if (rolePengguna == 1) {
        // Jika Kamu adalah ? "Pembeli"

        if (isSudahGabung == false) {
          await handleTambahPenggunaPembeli();
        }

        await handleAuthWithPasswordPenggunaPembeli();
      } else {
        // Jika Kamu adalah ? "Penjual"
        if (isSudahGabung == false) {
          await handleTambahPenggunaPenjual();
        }
        await handleAuthWithPasswordPenggunaPenjual();
      }

      final cekAuth = await pocketbaseService.cekAuth();
      if (cekAuth!) {
        await handleSetNonActivePenggunaAnonim();
      }
    }

    if (isSudahGabungReverse == true) {
      setState(() {
        titleAlert = 'Email sudah terdaftar';
        bodyAlert =
            'Email ${_email.text} sudah terdaftar sebagai ${jenisPenggunaReverse}.';
        btnTextAlert = 'Ganti email dulu';
      });

      showAlertDialog(context);
    } else {
      final cekAuth = await pocketbaseService.cekAuth();
      if (cekAuth!) {
        final getAuthStoreData = await pocketbaseService.getAuthStoreData();
        print("getAuthStoreData , ");
        print(getAuthStoreData);

        await sharedPreferencesService.setLocalDataString(
            "authStoreData", getAuthStoreData);

        final getLocalAuthStoreData =
            await sharedPreferencesService.getLocalDataString('authStoreData');

        var toString = jsonEncode(getLocalAuthStoreData);
        var toMap = jsonDecode(toString);

        var modelAuthStore = toMap['model'];
        var collectionName = modelAuthStore['collectionName'];
        var idPengguna = modelAuthStore['id'];
        if (collectionName == "pengguna_penjual") {
          await pocketbaseService.setLogoutPenggunaPenjual(idPengguna, false);
        } else if (collectionName == "pengguna_pembeli") {
          await pocketbaseService.setLogoutPenggunaPembeli(idPengguna, false);
        }

        context.pushReplacementNamed(Routes.bottomNavigasiPage);
      }
    }

    await EasyLoading.dismiss();
  }
  // END FUNGSI BOTTOM MODAL

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stepper(
          steps: stepList(),
          type: StepperType.horizontal,
          elevation: 0,
          currentStep: _currentStep,
          onStepContinue: () async {
            print('_currentStep | onStepContinue = ${_currentStep}');

            if (_currentStep == 1) {
              // Tahap "Confirm"

              _showModalBottomSheet(context);
            }

            if (_currentStep == 0) {
              // Masih di tahap "Account"

              if (_email.text.length == 0) {
                setState(() {
                  inputEmailMsgError = "Mohon diisi terlebih dahulu.";
                });
              }

              if (isSudahGabung! == false) {
                if (_namaPengguna.text.length == 0) {
                  setState(() {
                    inputNamaPenggunaMsgError = "Mohon diisi terlebih dahulu.";
                  });
                }
              }

              if (_password.text.length == 0) {
                setState(() {
                  inputPasswordMsgError = "Mohon diisi terlebih dahulu.";
                });
              }

              if (rolePengguna == 1) {
                if (inputNamaPenggunaMsgError == null &&
                    inputEmailMsgError == null &&
                    inputPasswordMsgError == null &&
                    isPassedRequirePassword == true) {
                  if (_currentStep < (stepList().length - 1)) {
                    print("Memasuki tahap confirm ${_email.text}");

                    setState(() {
                      _currentStep += 1;
                    });
                  }
                }
              }

              if (rolePengguna == 2) {
                if (isSudahGabung! == false) {
                  if (_namaDagangan.text.length == 0) {
                    setState(() {
                      inputNamaDaganganMsgError =
                          "Mohon diisi terlebih dahulu.";
                    });
                  }

                  if (tipePenjual == 2) {
                    if (_alamatLengkap.text.length == 0 &&
                        isFinishCekIzinLokasi) {
                      setState(() {
                        inputAlamatLengkapMsgError =
                            "Mohon diisi terlebih dahulu.";
                      });
                    }
                  }
                }

                if (inputEmailMsgError == null &&
                    inputNamaPenggunaMsgError == null &&
                    inputNamaDaganganMsgError == null &&
                    inputPasswordMsgError == null &&
                    inputAlamatLengkapMsgError == null &&
                    isPassedRequirePassword == true) {
                  if (_currentStep < (stepList().length - 1)) {
                    print("Memasuki tahap confirm ${_email.text}");

                    setState(() {
                      _currentStep += 1;
                    });
                  }
                }
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              print('_currentStep | onStepCancel = ${_currentStep}');

              setState(() {
                _currentStep -= 1;
              });
            }
          },
        ),
      ),
    );
  }
}
