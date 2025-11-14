import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../bloc/bloc.dart';
import '../../../routes/router.dart';
import '../../../services/internet_connection_checker_plus.dart';
import '../../../services/pocketbase.dart';
import '../../../services/shared_preferences.dart';
import 'child/batal/batal_dibeli.dart';
import 'child/berhasil/berhasil_dibeli.dart';
import 'child/sedang/sedang_dibeli.dart';

class DibeliPage extends StatefulWidget {
  const DibeliPage({super.key});

  @override
  State<DibeliPage> createState() => _DibeliPageState();
}

class _DibeliPageState extends State<DibeliPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  bool isRender = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    antriPanggilFungsiSebelumLoadHalaman();
  }

  Future<void> antriPanggilFungsiSebelumLoadHalaman() async {
    final _cekAuth = await cekAuth();

    if (_cekAuth! == false) {
      Future.delayed(Duration.zero, () {
        context.pushReplacementNamed(Routes.gabungPage);
      });
    } else {
      await cekKoneksi(false);
      await siapakahSaya();

      context
          .read<PesananRealtimeByIdPenggunaBloc>()
          .add(PesananRealtimeByIdPenggunaEventGet(collectionName, idSaya));

      aktifkanRealtimePesanan();
    }
  }

  PocketbaseService pocketbaseService = PocketbaseService();

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  Future<bool?> cekAuth() async {
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    return cariLocalDataStringAuthStore;
  }

  InternetConnectionCheckerPlusService internetConnectionCheckerPlusService =
      InternetConnectionCheckerPlusService();

  bool isHasInternetAccess = false, isCekKoneksiManual = false;
  Future<bool?> cekKoneksi(bool isManual) async {
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

  var collectionName, idSaya;
  Future<void> siapakahSaya() async {
    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var modelAuthStore = toMap['model'];
    collectionName = modelAuthStore['collectionName'];
    idSaya = modelAuthStore['id'];
  }

  void aktifkanRealtimePesanan() {
    pb.collection('pesanan').subscribe('*', (e) {
      var eventRealtime = e;
      var eventRealtimeToString = jsonEncode(eventRealtime);
      var eventRealtimeToMap = jsonDecode(eventRealtimeToString);
      var recordRealtime = eventRealtimeToMap['record'];

      if (collectionName == 'pengguna_pembeli' &&
          recordRealtime['id_pembeli'] == idSaya) {
        context.read<PesananRealtimeByIdPenggunaBloc>().add(
            PesananRealtimeByIdPenggunaEventHandleUpdateDataLokal(
                eventRealtimeToString));
      }

      if (collectionName == 'pengguna_penjual' &&
          recordRealtime['id_penjual'] == idSaya) {
        context.read<PesananRealtimeByIdPenggunaBloc>().add(
            PesananRealtimeByIdPenggunaEventHandleUpdateDataLokal(
                eventRealtimeToString));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    pb.collection('pesanan').unsubscribe('*');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isRender && isHasInternetAccess
          ? AppBar(
              title: Text(
                  collectionName == 'pengguna_penjual' ? "Pesanan" : "Dibeli"),
              bottom: TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(
                    text: "Sedang",
                  ),
                  Tab(
                    text: "Berhasil",
                  ),
                  Tab(
                    text: "Batal",
                  ),
                ],
              ),
            )
          : AppBar(),
      body: isRender && isHasInternetAccess
          ? TabBarView(
              controller: _tabController,
              children: const <Widget>[
                SedangDibeliWidget(),
                BerhasilDibeliWidget(),
                BatalDibeliWidget(),
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
                                cekKoneksi(true);
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
    );
  }
}
