import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../../bloc/bloc.dart';
import '../../services/firebase_messaging.dart';
import '../../services/geocoding.dart';
// import '../../services/geolocator.dart';
import '../../services/http_request.dart';
import '../../services/location.dart';
import '../../services/permission_handler.dart';
import '../../services/pocketbase.dart';
import '../../services/shared_preferences.dart';
import '../../services/socket_client.dart';

import 'chat/chat.dart';
import 'dibeli/dibeli.dart';
import 'home/home.dart';
import 'profile/profile.dart';

class BottomNavigasiPage extends StatefulWidget {
  const BottomNavigasiPage({super.key});

  @override
  State<BottomNavigasiPage> createState() => _BottomNavigasiPageState();
}

class _BottomNavigasiPageState extends State<BottomNavigasiPage> {
  int currentPageIndex = 0;

  bool isModeJelajah = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilSebelumHalamanLoad();
  }

  PocketbaseService pocketbaseService = PocketbaseService();

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  LocationService locationService = LocationService();

  String? identifier;

  bool isServiceLocationAndroidEnabled = false;
  PermissionStatus? permissionLocationStatus;

  bool isPenggunaAnonim = false,
      isPenggunaPembeli = false,
      isPenggunaPenjual = false;
  String? idPengguna, collectionName, tipePenjual;
  Future<void> antriPanggilSebelumHalamanLoad() async {
    await instalisasiThemeModeApp();

    await initUniqueIdentifierState();

    await handleGetTokenFirebase();

    await cekLokasiAndroid();
    await cekLokasiAPP();

    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    bool isGabung = cariLocalDataStringAuthStore!;

    if (isGabung == false) {
      isPenggunaAnonim = true;

      final cekPenggunaAnonim =
          await pocketbaseService.cekPenggunaAnonim(identifier);

      var toString = jsonEncode(cekPenggunaAnonim);
      var toMap = jsonDecode(toString);

      if (toMap['items'].length == 0) {
        await pocketbaseService.tambahPenggunaAnonim(identifier);
      } else {
        var idPenggunaAnonim = toMap['items'][0]['id'];
        await pocketbaseService.setStatusActivePenggunaAnonim(
            idPenggunaAnonim, false);
      }
    } else {
      final getLocalAuthStoreData =
          await sharedPreferencesService.getLocalDataString('authStoreData');

      var toString = jsonEncode(getLocalAuthStoreData);
      var toMap = jsonDecode(toString);

      var modelAuthStore = toMap['model'];
      idPengguna = modelAuthStore['id'];
      collectionName = modelAuthStore['collectionName'];

      if (collectionName == "pengguna_pembeli") {
        isPenggunaAnonim = false;
        isPenggunaPembeli = true;
        isPenggunaPenjual = false;
      } else {
        isPenggunaAnonim = false;
        isPenggunaPembeli = false;
        isPenggunaPenjual = true;

        tipePenjual = modelAuthStore['tipe_penjual'][0];
      }

      context
          .read<ChatRoomsRealtimeBloc>()
          .add(ChatRoomsRealtimeEventGetByIdSaya());
    }

    if (isServiceLocationAndroidEnabled != true ||
        permissionLocationStatus != PermissionStatus.granted) {
      if (isPenggunaAnonim == true) {
        final cekPenggunaAnonim =
            await pocketbaseService.cekPenggunaAnonim(identifier);

        var toString = jsonEncode(cekPenggunaAnonim);
        var toMap = jsonDecode(toString);

        if (toMap['items'].length != 0) {
          await pocketbaseService
              .setNullPenggunaAnonim(toMap['items'][0]['id']);
        }
      }
    }

    if (isServiceLocationAndroidEnabled == true &&
        permissionLocationStatus == PermissionStatus.granted) {
      final cariLocalDataStringAuthStore =
          await sharedPreferencesService.cariLocalDataString('authStoreData');

      if (cariLocalDataStringAuthStore!) {
        final getLocalAuthStoreData =
            await sharedPreferencesService.getLocalDataString('authStoreData');

        var toString = jsonEncode(getLocalAuthStoreData);
        var toMap = jsonDecode(toString);

        var modelAuthStore = toMap['model'];

        if (collectionName == 'pengguna_penjual') {
          if (modelAuthStore['tipe_penjual'][0] == "Tetap") {
            idPengguna = modelAuthStore['id'];
          } else if (modelAuthStore['tipe_penjual'][0] == "Keliling") {
            listenLocation();
          }
        } else if (collectionName == "pengguna_pembeli") {
          listenLocation();
        }
      } else {
        listenLocation();
      }
    }

    connectToServer();
  }

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

  Future<void> cekLokasiAndroid() async {
    await checkServiceLocation();
    await requestServiceLocation();

    print(
        'cekLokasiAndroid() / isServiceLocationAndroidEnabled = $isServiceLocationAndroidEnabled');
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

    if (permissionLocationStatus == PermissionStatus.deniedForever) {
      print(
          'permissionLocationStatus = deniedForever(LOKASI APLIKASI SUDAH DISET JANGAN IZINKAN OLEH USER), MAKA SEDANG MEMINTA IZIN BUKA SETTINGAN IZIN APLIKASI SECARA MANUAL..');

      showPermissionDeniedForeverDialog(context);
    }
  }

  Future<void> cekLokasiAPP() async {
    await checkPermissionsLocation();
    await requestPermissionLocation();

    print(
        'cekLokasiAPP() / permissionLocationStatus = $permissionLocationStatus');
  }

  Future<void> instalisasiThemeModeApp() async {
    final cariLocalThemeMode =
        await sharedPreferencesService.cariLocalDataString('themeMode');

    if (cariLocalThemeMode!) {
      final getLocalThemeMode =
          await sharedPreferencesService.getLocalDataString('themeMode');

      var toString = jsonEncode(getLocalThemeMode);
      var toMap = jsonDecode(toString);

      var themeYangTersimpan = toMap['theme'];

      if (themeYangTersimpan == 'light') {
        context.read<ThemeToggleBloc>().add(ThemeToggleEventSetLight());
      } else {
        context.read<ThemeToggleBloc>().add(ThemeToggleEventSetDark());
      }
    }
  }

  Future<void> initUniqueIdentifierState() async {
    try {
      identifier = await UniqueIdentifier.serial;
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;
  }

  FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService();
  Future<void> handleGetTokenFirebase() async {
    final getTokenFirebase = await firebaseMessagingService.getTokenFirebase();
    print('handleGetToken | getToken dibottomNav = $getTokenFirebase');

    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    if (cariLocalDataStringAuthStore!) {
      final getLocalAuthStoreData =
          await sharedPreferencesService.getLocalDataString('authStoreData');

      var toString = jsonEncode(getLocalAuthStoreData);
      var toMap = jsonDecode(toString);

      var modelAuthStore = toMap['model'];
      var collectionName = modelAuthStore['collectionName'];
      var idPengguna = modelAuthStore['id'];

      await pocketbaseService.updateTokenFcmByIdPengguna(
          collectionName, idPengguna, getTokenFirebase);
    }
  }

  StreamSubscription<LocationData>? _locationSubscription;

  GeocodingService geocodingService = GeocodingService();
  final Location _location = Location();
  LocationData? _locationData;
  String? _error;

  String? subLocality;
  Future<void> listenLocation() async {
    print('Mulai _listenLocation..');

    _locationSubscription =
        _location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        setState(() {
          _error = err.code;
        });
      }
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((currentLocation) async {
      print('Hasil Lokasi REALTIME = $currentLocation');

      _locationData = currentLocation;

      double? latitude = _locationData?.latitude;
      double? longitude = _locationData?.longitude;

      final getPlace = await geocodingService.getPlace(latitude, longitude);
      print(getPlace);

      print('subLocality = $subLocality');
      if (subLocality == null) {
        subLocality = getPlace['subLocality'];

        await handleUpdateSubLocality();
      } else {
        if (subLocality != getPlace['subLocality']) {
          await handleUpdateSubLocality();
        }
      }

      final cariLocalDataStringAuthStore =
          await sharedPreferencesService.cariLocalDataString('authStoreData');

      if (cariLocalDataStringAuthStore!) {
        final getLocalAuthStoreData =
            await sharedPreferencesService.getLocalDataString('authStoreData');

        var toString = jsonEncode(getLocalAuthStoreData);
        var toMap = jsonDecode(toString);

        var modelAuthStore = toMap['model'];

        var idPengguna = modelAuthStore['id'];
        if (collectionName == "pengguna_penjual") {
          if (tipePenjual == "Keliling") {
            var alamatKeliling = {"latitude": latitude, "longitude": longitude};
            await pocketbaseService.updateAlamatKeliling(
                idPengguna, alamatKeliling);

            await handleUpdateLokasiSayaLokal(latitude, longitude);
          }
        } else {
          // untuk pengguna pembeli
          await handleUpdateLokasiSayaLokal(latitude, longitude);
        }
      } else {
        // untuk pengguna anonim
        await handleUpdateLokasiSayaLokal(latitude, longitude);
      }

      context.read<LokasikuRealtimeBloc>().add(LokasikuRealtimeEventSet(
          isModeJelajah: false,
          latitude: latitude!,
          longitude: longitude!,
          forceOffModeJelajah: false));
    });
  }

  Future<void> handleSetLokasiRealtimeBloc(latitude, longitude) async {
    context.read<LokasikuRealtimeBloc>().add(LokasikuRealtimeEventSet(
        isModeJelajah: false,
        latitude: latitude,
        longitude: longitude,
        forceOffModeJelajah: false));
  }

  Future<void> _stopListen() async {
    await _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  Future<void> handleUpdateLokasiSayaLokal(latitude, longitude) async {
    // update lokasi saya(bukan untuk penjual tetap), UNTUK KEBUTUHAN SAAT HITUNG JARAK
    final cariLocallokasiSayaTerkini =
        await sharedPreferencesService.cariLocalDataString('lokasiSayaTerkini');

    var obj = {"latitude": latitude, "longitude": longitude};
    if (cariLocallokasiSayaTerkini!) {
      await sharedPreferencesService.removeLocalDataString('lokasiSayaTerkini');
      await sharedPreferencesService.setLocalDataString(
          'lokasiSayaTerkini', obj);
    } else {
      await sharedPreferencesService.setLocalDataString(
          'lokasiSayaTerkini', obj);
    }
  }

  Future<void> handleUpdateSubLocality() async {
    final cariLocalSubLocality =
        await sharedPreferencesService.cariLocalDataString('subLocality');

    var obj = {"sub_locality": subLocality};
    if (cariLocalSubLocality!) {
      await sharedPreferencesService.removeLocalDataString('subLocality');
      await sharedPreferencesService.setLocalDataString('subLocality', obj);
    } else {
      await sharedPreferencesService.setLocalDataString('subLocality', obj);
    }

    context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
        isDragMapJelajah: false,
        subLocality: subLocality!,
        isModeJelajah: false));

    if (isPenggunaAnonim == true) {
      final cekPenggunaAnonim =
          await pocketbaseService.cekPenggunaAnonim(identifier);

      var toString = jsonEncode(cekPenggunaAnonim);
      var toMap = jsonDecode(toString);

      final _updateSubLocality = await pocketbaseService.updateSubLocality(
          'anonim', toMap['items'][0]['id'], subLocality);
    } else {
      final getLocalAuthStoreData =
          await sharedPreferencesService.getLocalDataString('authStoreData');

      var toString = jsonEncode(getLocalAuthStoreData);
      var toMap = jsonDecode(toString);

      var modelAuthStore = toMap['model'];

      var idPengguna = modelAuthStore['id'];
      if (collectionName == "pengguna_pembeli") {
        final _updateSubLocality = await pocketbaseService.updateSubLocality(
            'pembeli', idPengguna, subLocality);
      } else if (collectionName == "pengguna_penjual") {
        final _updateSubLocality = await pocketbaseService.updateSubLocality(
            'penjual', idPengguna, subLocality);
      }
    }
  }

  SocketClientService socketClientService = SocketClientService();
  void connectToServer() async {
    await socketClientService.initConnectSocket();

    await socketClientService.onConnectSocket();
    await socketClientService.onDisconnectSocket();

    await socketClientService.sendDataToServerSocket(isPenggunaAnonim,
        identifier, isPenggunaPembeli, isPenggunaPenjual, idPengguna);
  }

  Timer? _timer;
  String? promosiKeDesa;
  Future<void> handleShareNotifDaganganInterval() async {
    _timer = Timer.periodic(
      Duration(minutes: 4), //Duration(seconds: 4)
      (timer) {
        handleKirimNotifikasiKePembeli(promosiKeDesa);
      },
    );
  }

  HttpRequestService httpRequestService = HttpRequestService();

  String? namaDagangBloc, textPromosiBloc;
  Future<void> handleKirimNotifikasiKePembeli(subLocalityLokal) async {
    final getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan =
        await pocketbaseService
            .getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan(
                subLocalityLokal);

    var status =
        getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan![
            'status'];
    var data =
        getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan[
            'data'];

    if (status == 'sukses') {
      var items = data['items'];
      for (var i = 0; i < items.length; i++) {
        var titleNotifTarget = 'Promosi ~ ${namaDagangBloc}';

        await httpRequestService.kirimNotifikasi(
            items[i]['token_fcm'], titleNotifTarget, textPromosiBloc);
      }
    }
  }

  Future<void> stopShareNotifDaganganInterval() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  DateTime? _lastPressedTime;

  @override
  void dispose() {
    print("Bottom_nav DI DESPOSE");

    _locationSubscription?.cancel();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (collectionName == "pengguna_penjual") {
          final isExit = await _showModalBottomSheet(context);
          print('isExit  = $isExit');

          return isExit;
        } else {
          DateTime now = DateTime.now();
          if (_lastPressedTime == null ||
              now.difference(_lastPressedTime!) > Duration(seconds: 2)) {
            _lastPressedTime = now;
            final message = "Tekan sekali lagi untuk keluar.";
            Fluttertoast.showToast(msg: message);
            return false;
          }
          return true;
        }
      },
      child: Scaffold(
        bottomNavigationBar:
            BlocConsumer<StatusModeJelajahBloc, StatusModeJelajahState>(
          listener: (context, state) async {
            if (state is StatusModeJelajahStateShare) {
              setState(() {
                isModeJelajah = state.isModeJelajah;
              });
            }

            if (state is StatusModeJelajahStateShareStatusNotifPromosi) {
              if (state.isShareNotif) {
                setState(() {
                  namaDagangBloc = state.namaDagang;
                  textPromosiBloc = state.textPromosi;
                  promosiKeDesa = state.subLocality;
                });
                await handleShareNotifDaganganInterval();
              } else {
                await stopShareNotifDaganganInterval();
              }
            }
          },
          builder: (context, state) {
            return collectionName == 'pengguna_penjual' &&
                    tipePenjual == 'Tetap'
                ? NavigationBar(
                    onDestinationSelected: (int index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    selectedIndex: currentPageIndex,
                    destinations: <Widget>[
                      NavigationDestination(
                        selectedIcon: isModeJelajah
                            ? const Icon(Icons.explore)
                            : const Icon(Icons.location_on),
                        icon: isModeJelajah
                            ? const Icon(Icons.explore_outlined)
                            : const Icon(Icons.location_on_outlined),
                        label: isModeJelajah ? 'Jelajah' : 'Sekitar',
                      ),
                      const NavigationDestination(
                        selectedIcon: Icon(Icons.chat_bubble),
                        icon: Icon(Icons.chat_bubble_outline_rounded),
                        label: 'Chat',
                      ),
                      const NavigationDestination(
                        selectedIcon: Icon(Icons.account_circle),
                        icon: Icon(Icons.account_circle_outlined),
                        label: 'Profile',
                      ),
                    ],
                  )
                : NavigationBar(
                    onDestinationSelected: (int index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    selectedIndex: currentPageIndex,
                    destinations: <Widget>[
                      NavigationDestination(
                        selectedIcon: isModeJelajah
                            ? const Icon(Icons.explore)
                            : const Icon(Icons.location_on),
                        icon: isModeJelajah
                            ? const Icon(Icons.explore_outlined)
                            : const Icon(Icons.location_on_outlined),
                        label: isModeJelajah ? 'Jelajah' : 'Sekitar',
                      ),
                      const NavigationDestination(
                        selectedIcon: Icon(Icons.chat_bubble),
                        icon: Icon(Icons.chat_bubble_outline_rounded),
                        label: 'Chat',
                      ),
                      NavigationDestination(
                        selectedIcon: collectionName == 'pengguna_penjual'
                            ? const Icon(Icons.fact_check)
                            : const Icon(Icons.shopping_cart),
                        icon: collectionName == 'pengguna_penjual'
                            ? const Icon(Icons.fact_check_outlined)
                            : const Icon(Icons.shopping_cart_outlined),
                        label: collectionName == 'pengguna_penjual'
                            ? 'Pesanan'
                            : 'Dibeli',
                      ),
                      const NavigationDestination(
                        // cocok untuk profile = account_circle, person
                        selectedIcon: Icon(Icons.account_circle),
                        icon: Icon(Icons.account_circle_outlined),
                        label: 'Profile',
                      ),
                    ],
                  );
          },
        ),
        body: collectionName == 'pengguna_penjual' && tipePenjual == 'Tetap'
            ? <Widget>[
                const HomePage(),
                const ChatPage(),
                const ProfilePage(),
              ][currentPageIndex]
            : <Widget>[
                const HomePage(),
                const ChatPage(),
                const DibeliPage(),
                const ProfilePage(),
              ][currentPageIndex],
      ),
    );
  }
}

Future<bool> _showModalBottomSheet(BuildContext context) async {
  Completer<bool> completer = Completer<bool>();

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
              'Yakin ingin tutup aplikasi?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Jika anda tutup aplikasi ini maka calon pembeli tidak dapat melihat dagangan anda.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    completer.complete(true); // Mengembalikan true
                    Navigator.pop(context); // Tutup modal bottom sheet
                  },
                  child: const Text('Yakin'),
                ),
                ElevatedButton(
                  onPressed: () {
                    completer.complete(false); // Mengembalikan false
                    Navigator.pop(context); // Tutup modal bottom sheet
                  },
                  child: const Text('Tidak'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  return completer.future;
}
