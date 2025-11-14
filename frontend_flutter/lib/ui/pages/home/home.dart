import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../bloc/bloc.dart';
import '../../../services/geocoding.dart';
import '../../../services/geolocator.dart';
import '../../../services/http_request.dart';
import '../../../services/internet_connection_checker_plus.dart';
import '../../../services/location.dart';
import '../../../services/pocketbase.dart';
import '../../../services/shared_preferences.dart';

import 'child/maps.dart';
import 'child/panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FToast? fToast;

  final _panelController = PanelController();

  InternetConnectionCheckerPlusService internetConnectionCheckerPlusService =
      InternetConnectionCheckerPlusService();
  HttpRequestService httpRequestService = HttpRequestService();

  final TextEditingController textPromosi = TextEditingController(text: "");

  bool isRender = false;

  bool isModeJelajahBloc = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fToast = FToast();
    fToast?.init(context);

    antriPanggilSebelumHalamanLoad();
  }

  Future<void> antriPanggilSebelumHalamanLoad() async {
    await cekKoneksiSebelumLoadHalaman(false);

    await checkServiceLocation();
    await checkPermissionsLocation();

    await siapakahSaya();

    await setMapMarkerDanSubLokasiPenjualTetap();

    await cekStatusPromosiDaganganLokal();

    context
        .read<DataPenjualRealtimeBloc>()
        .add(DataPenjualRealtimeEventInitial(false, ""));
  }

  bool isHasInternetAccess = false, isCekKoneksiManual = false;
  Future<void> cekKoneksiSebelumLoadHalaman(bool isManual) async {
    if (isManual) {
      setState(() {
        isCekKoneksiManual = true;
      });
    }

    final hasInternetAccess =
        await internetConnectionCheckerPlusService.cekKoneksiInternet();

    setState(() {
      isHasInternetAccess = hasInternetAccess!;

      if (isRender == false) {
        isRender = true;
      }

      if (isManual) {
        isCekKoneksiManual = false;
      }
    });
  }

  LocationService locationService = LocationService();

  bool isServiceLocationAndroidEnabled = false;
  Future<void> checkServiceLocation() async {
    final serviceLocationEnabledResult = await locationService.checkService();
    print('Hasil serviceLocationEnabledResult = $serviceLocationEnabledResult');
    // serviceLocationEnabledResult berupa true(Lokasi Android NYALA) atau false

    setState(() {
      isServiceLocationAndroidEnabled = serviceLocationEnabledResult!;
    });
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

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  String? collectionName, idPengguna, tipePenjual, namaDagang;
  Future<void> siapakahSaya() async {
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');
    print(
        'cariLocalDataString "authStoreData" = $cariLocalDataStringAuthStore');

    if (cariLocalDataStringAuthStore!) {
      final getLocalAuthStoreData =
          await sharedPreferencesService.getLocalDataString('authStoreData');
      print("getLocalAuthStoreData , ");
      print(getLocalAuthStoreData);

      var toString = jsonEncode(getLocalAuthStoreData);
      var toMap = jsonDecode(toString);

      var modelAuthStore = toMap['model'];
      collectionName = modelAuthStore['collectionName'];
      idPengguna = modelAuthStore['id'];
      if (collectionName == 'pengguna_penjual') {
        tipePenjual = modelAuthStore['tipe_penjual'][0];
        namaDagang = modelAuthStore['nama_dagang'];
      }
    }
  }

  Future<void> setMapMarkerDanSubLokasiPenjualTetap() async {
    if (isServiceLocationAndroidEnabled == true &&
        permissionLocationStatus == PermissionStatus.granted) {
      if (collectionName != null && idPengguna != null) {
        if (collectionName == 'pengguna_penjual') {
          if (tipePenjual == "Tetap") {
            setMarkerPenjualTetap(idPengguna);
          }
        }
      }
    }
  }

  PocketbaseService pocketbaseService = PocketbaseService();
  GeocodingService geocodingService = GeocodingService();
  Future<void> setMarkerPenjualTetap(idPengguna) async {
    final getPenggunaPenjual =
        await pocketbaseService.getPenggunaPenjual(idPengguna);
    print('getPenggunaPenjual ,');
    print(getPenggunaPenjual);

    var toString = jsonEncode(getPenggunaPenjual);
    var toMap = jsonDecode(toString);

    print(toMap['alamat_tetap']);

    double latitude = toMap['alamat_tetap']['latitude'];
    double longitude = toMap['alamat_tetap']['longitude'];

    final getPlace = await geocodingService.getPlace(latitude, longitude);

    context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
        isDragMapJelajah: false,
        subLocality: getPlace['subLocality'],
        isModeJelajah: false));

    Future.delayed(Duration(seconds: 4), () {
      context.read<LokasikuRealtimeBloc>().add(LokasikuRealtimeEventSet(
          isModeJelajah: false,
          latitude: latitude,
          longitude: longitude,
          forceOffModeJelajah: false));
    });
  }

  bool isKirimNotifSetiap4menit = false, statusSwitchSetiap4Menit = false;
  Future<void> cekStatusPromosiDaganganLokal() async {
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    if (cariLocalDataStringAuthStore!) {
      if (collectionName == 'pengguna_penjual') {
        final cariStatusPromosiDagangan = await sharedPreferencesService
            .cariLocalDataString('statusPromosiDagangan');

        if (cariStatusPromosiDagangan == true) {
          final getStatusPromosiDagangan = await sharedPreferencesService
              .getLocalDataString('statusPromosiDagangan');

          if (getStatusPromosiDagangan!['is_promosi'] == true) {
            setState(() {
              isKirimNotifSetiap4menit = true;
            });
          }
        } else {
          print('Tidak ada statusPromosiDagangan di sharedPreferencesService');
        }
      }
    }
  }

  double _maxHeightPanelOpen = 0;
  double _maxHeightPanelClosed = 95.0;

  static const double _fabHeightClosed = 180.0;
  double _fabHeight = _fabHeightClosed;

  static const double _fabHeightClosedShareIklanFAB = 260.0;
  double _fabHeightShareIklanFAB = _fabHeightClosedShareIklanFAB;

  bool isLoadingAkurasiLokasi = false;

  GeolocatorServices geolocatorServices = GeolocatorServices();

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    // _maxHeightPanelOpen = MediaQuery.of(context).size.height * .80;
    _maxHeightPanelOpen = MediaQuery.of(context).size.height;
    // _maxHeightPanelClosed = MediaQuery.of(context).size.height * .1;
    _maxHeightPanelClosed = MediaQuery.of(context).size.height * .2;

    LocationService locationService = LocationService();
    void handleAkurasiLokasi() async {
      setState(() {
        isLoadingAkurasiLokasi = true;
      });

      final handleGetLastKnownPosition =
          await geolocatorServices.handleGetLastKnownPosition();

      double latitude = handleGetLastKnownPosition!.latitude;
      double longitude = handleGetLastKnownPosition.longitude;

      final getPlace = await geocodingService.getPlace(latitude, longitude);

      context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
          isDragMapJelajah: false,
          subLocality: getPlace['subLocality'],
          isModeJelajah: false));

      context.read<LokasikuRealtimeBloc>().add(LokasikuRealtimeEventSet(
          isModeJelajah: false,
          latitude: latitude,
          longitude: longitude,
          forceOffModeJelajah: true));

      context
          .read<DataPenjualRealtimeBloc>()
          .add(DataPenjualRealtimeEventInitial(false, ""));

      pb.collection('pengguna_pembeli').unsubscribe('*');

      context
          .read<DataPembeliRealtimeBloc>()
          .add(DataPembeliRealtimeEventInitial(false, ""));

      pb.collection('pengguna_pembeli').subscribe('*', (e) {
        context
            .read<DataPembeliRealtimeBloc>()
            .add(DataPembeliRealtimeEventInitial(false, ""));
      });

      pb.collection('pengguna_anonim').unsubscribe('*');

      context
          .read<DataAnonimRealtimeBloc>()
          .add(DataAnonimRealtimeEventInitial(false, ""));

      pb.collection('pengguna_anonim').subscribe('*', (e) {
        context
            .read<DataAnonimRealtimeBloc>()
            .add(DataAnonimRealtimeEventInitial(false, ""));
      });

      setState(() {
        isLoadingAkurasiLokasi = false;
      });
    }

    Future<void> handleKirimNotifikasiKePembeli(subLocalityLokal) async {
      if (statusSwitchSetiap4Menit) {
        setState(() {
          isKirimNotifSetiap4menit = true;
        });
      }

      final getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan =
          await pocketbaseService
              .getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan(
                  subLocalityLokal);

      print(getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan);

      var status =
          getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan![
              'status'];
      var data =
          getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan[
              'data'];
      if (status == 'sukses') {
        var items = data['items'];
        print("items[i]['token_fcm'] , ");
        for (var i = 0; i < items.length; i++) {
          print(items[i]['token_fcm']);

          var titleNotifTarget = 'Promosi ~ ${namaDagang}';

          await httpRequestService.kirimNotifikasi(
              items[i]['token_fcm'], titleNotifTarget, textPromosi.text);
        }
      }
    }

    void showDialogShareNotifIklan() async {
      final cariLocalSubLocality =
          await sharedPreferencesService.cariLocalDataString('subLocality');

      if (cariLocalSubLocality!) {
        final getLocalSubLocality =
            await sharedPreferencesService.getLocalDataString('subLocality');

        String subLocalityLokal = getLocalSubLocality!['sub_locality'];
        print(subLocalityLokal);

        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SimpleDialog(
                title: Text(
                  'Promosi dagangan disekitar Desa ${subLocalityLokal}',
                  style: TextStyle(fontSize: 18),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 4),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Pesan promosi *",
                      ),
                      controller: textPromosi,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(9, 4, 0, 4),
                    child: SwitchListTile(
                      title: const Text('Setiap 4 menit'),
                      value: statusSwitchSetiap4Menit,
                      onChanged: (bool value) {
                        setState(() {
                          statusSwitchSetiap4Menit = !statusSwitchSetiap4Menit;
                        });
                      },
                      secondary: const Icon(Icons.timer),
                    ),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      TextButton(
                        child: const Text('Batal'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Kirim'),
                        onPressed: () async {
                          if (textPromosi.text.length != 0) {
                            await handleKirimNotifikasiKePembeli(
                                subLocalityLokal);

                            if (statusSwitchSetiap4Menit) {
                              var obj = {"is_promosi": true};

                              await sharedPreferencesService.setLocalDataString(
                                  'statusPromosiDagangan', obj);
                              // }

                              context.read<StatusModeJelajahBloc>().add(
                                  StatusModeJelajahEventShareNotifMode(
                                      true,
                                      namaDagang!,
                                      textPromosi.text,
                                      subLocalityLokal));

                              context.read<StatusModeJelajahBloc>().add(
                                  StatusModeJelajahEventSet(isModeJelajahBloc));

                              showCustomToast();
                            } else {
                              setState(() {
                                textPromosi.text = "";
                              });
                            }

                            Navigator.pop(context, 'Kirim');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            });
          },
        );
      }
    }

    Future<void> _showModalStopShareIklanBottomSheet(
        BuildContext context) async {
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
                  'Stop promosi dagangan?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
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
                        context.read<StatusModeJelajahBloc>().add(
                            StatusModeJelajahEventShareNotifMode(
                                false, "", "", ""));

                        context
                            .read<StatusModeJelajahBloc>()
                            .add(StatusModeJelajahEventSet(isModeJelajahBloc));

                        setState(() {
                          isKirimNotifSetiap4menit = false;
                          textPromosi.text = "";
                        });

                        fToast?.removeCustomToast();

                        final cariStatusPromosiDagangan =
                            await sharedPreferencesService
                                .cariLocalDataString('statusPromosiDagangan');

                        if (cariStatusPromosiDagangan!) {
                          await sharedPreferencesService
                              .removeLocalDataString('statusPromosiDagangan');
                        }

                        print('Pengiriman notifikasi telah dihentikan.');
                        Navigator.pop(context);
                      },
                      child: Text('Ya'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );

      // return completer.future;
    }

    return Scaffold(
      body: SafeArea(
        child: isRender && isHasInternetAccess
            ? Stack(
                alignment: Alignment.topCenter,
                children: [
                  SlidingUpPanel(
                    controller: _panelController,
                    maxHeight: _maxHeightPanelOpen,
                    minHeight: _maxHeightPanelClosed,
                    parallaxEnabled: true,
                    parallaxOffset: .5,
                    body: MapsWidget(),
                    panelBuilder: (controller) => PanelWidget(
                      controller: controller,
                      panelController: _panelController,
                    ),
                    onPanelSlide: (position) => setState(() {
                      final panelMaxScrollExtent =
                          _maxHeightPanelOpen - _maxHeightPanelClosed;

                      _fabHeight =
                          position * panelMaxScrollExtent + _fabHeightClosed;

                      _fabHeightShareIklanFAB =
                          position * panelMaxScrollExtent +
                              _fabHeightClosedShareIklanFAB;
                    }),
                  ),
                  Positioned(
                    bottom: _fabHeight,
                    right: 16,
                    child: BlocConsumer<StatusModeJelajahBloc,
                        StatusModeJelajahState>(
                      listener: (context, state) {
                        if (state is StatusModeJelajahStateShare) {
                          setState(() {
                            isModeJelajahBloc = state.isModeJelajah;
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is StatusModeJelajahStateShare) {
                          return FloatingActionButton(
                            onPressed: state is StatusModeJelajahStateShare
                                ? state.isModeJelajah
                                    ? handleAkurasiLokasi
                                    : null
                                : null,
                            child: isLoadingAkurasiLokasi
                                ? const CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : state is StatusModeJelajahStateShare
                                    ? state.isModeJelajah
                                        ? const Icon(Icons.location_searching)
                                        : const Icon(Icons.my_location)
                                    : const SizedBox(),
                          );
                        }

                        return const SizedBox();
                      },
                    ),
                  ),
                  collectionName != null
                      ? collectionName == 'pengguna_penjual'
                          ? isKirimNotifSetiap4menit == false
                              ? Positioned(
                                  bottom: _fabHeightShareIklanFAB,
                                  right: 16,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      showDialogShareNotifIklan();
                                    },
                                    child: isKirimNotifSetiap4menit == false
                                        ? const Icon(Icons.spatial_audio_off)
                                        : const Icon(Icons.voice_over_off),
                                  ),
                                )
                              : Positioned(
                                  bottom: _fabHeightShareIklanFAB,
                                  right: 16,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      _showModalStopShareIklanBottomSheet(
                                          context);
                                    },
                                    child: const Icon(Icons.voice_over_off),
                                  ),
                                )
                          : const SizedBox()
                      : const SizedBox(),
                ],
              )
            : isRender && !isHasInternetAccess
                ? Container(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Oops, Koneksi internet anda tidak tersedia..",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        isCekKoneksiManual
                            ? const TextButton(
                                onPressed: null,
                                child: Text('Tunggu..'),
                              )
                            : OutlinedButton(
                                onPressed: () {
                                  cekKoneksiSebelumLoadHalaman(true);
                                },
                                child: const Text('Cek lagi'),
                              )
                      ],
                    ),
                  )
                : !isRender
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const SizedBox(),
      ),
    );
  }

  showCustomToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        // color: Theme.of(context).colorScheme.background,
        color: Colors.grey[200], // Warna latar belakang abu-abu muda
      ),
      child: const Center(
        child: Text(
          "Promosi dagangan anda sedang berlangsung!",
          // style: TextStyle(color: Colors.white),
          style: TextStyle(color: Colors.black),
        ),
      ),
    );

    fToast?.showToast(
      child: toast,
      toastDuration: Duration(days: 1),
      gravity: ToastGravity.TOP,
      // positionedToastBuilder: (context, child) {
      //   return Positioned(
      //     child: child,
      //     bottom: 70.0,
      //     // left: 16.0,
      //   );
      // }
    );
  }
}
