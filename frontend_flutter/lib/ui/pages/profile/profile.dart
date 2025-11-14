import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../bloc/bloc.dart';
import '../../../routes/router.dart';
import '../../../services/internet_connection_checker_plus.dart';
import '../../../services/pocketbase.dart';
import '../../../services/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isRender = false, _isDarkMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilFungsiSebelumLoadHalaman();
  }

  Future<void> antriPanggilFungsiSebelumLoadHalaman() async {
    final _cekAuth = await cekAuth();

    if (_cekAuth! == false) {
      Future.delayed(Duration.zero, () {
        context.pushReplacementNamed(Routes.gabungPage);
      });
    }

    await cekKoneksi(false);

    cekTheme();

    await getPengguna();
  }

  PocketbaseService pocketbaseService = PocketbaseService();

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  Future<bool?> cekAuth() async {
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    return cariLocalDataStringAuthStore;
  }

  ThemeData? themeData;
  void cekTheme() {
    themeData = Theme.of(context);

    setState(() {
      if (themeData!.brightness == Brightness.dark) {
        _isDarkMode = true;
      } else {
        _isDarkMode = false;
      }
    });
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

  String idPengguna = "",
      namaPengguna = "",
      email = "",
      namaDagangan = "",
      collectionName = "",
      tipePenjual = "";
  Future<void> getPengguna() async {
    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var modelAuthStore = toMap['model'];
    setState(() {
      collectionName = modelAuthStore['collectionName'];
    });

    idPengguna = modelAuthStore['id'];

    if (collectionName == "pengguna_pembeli") {
      final getPenggunaPembeli =
          await pocketbaseService.getPenggunaPembeli(idPengguna);

      var toString = jsonEncode(getPenggunaPembeli);
      var toMap = jsonDecode(toString);

      setState(() {
        namaPengguna = toMap['nama'].toString();
        email = toMap['email'];
      });
    } else if (collectionName == "pengguna_penjual") {
      final getPenggunaPenjual =
          await pocketbaseService.getPenggunaPenjual(idPengguna);

      var toString = jsonEncode(getPenggunaPenjual);
      var toMap = jsonDecode(toString);

      setState(() {
        tipePenjual = modelAuthStore['tipe_penjual'][0];
        namaDagangan = toMap['nama_dagang'].toString();
        namaPengguna = toMap['nama_penjual'].toString();
        email = toMap['email'];
      });
    }
  }

  var objThemeForSaveLokal = {};
  Future<void> handleSaveLokalThemeMode() async {
    final cariLocalThemeMode =
        await sharedPreferencesService.cariLocalDataString('themeMode');

    if (cariLocalThemeMode!) {
      await sharedPreferencesService.removeLocalDataString('themeMode');
      await sharedPreferencesService.setLocalDataString(
          'themeMode', objThemeForSaveLokal);
    } else {
      await sharedPreferencesService.setLocalDataString(
          'themeMode', objThemeForSaveLokal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: isRender && isHasInternetAccess
          ? Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            child: Text(
                              collectionName == "pengguna_pembeli"
                                  ? namaPengguna == ""
                                      ? ""
                                      : namaPengguna[0]
                                  : namaDagangan == ""
                                      ? ""
                                      : namaDagangan[0],
                              style: TextStyle(
                                fontSize:
                                    40, // Ukuran teks di dalam CircleAvatar
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            radius: 60,
                          ),
                          collectionName == "pengguna_penjual"
                              ? Column(
                                  children: [
                                    const SizedBox(height: 7),
                                    Text(
                                      namaDagangan ?? "${namaDagangan}",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const SizedBox(height: 7),
                          Text(
                            namaPengguna ?? "${namaPengguna}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            email ?? email,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 7),
                          collectionName == "pengguna_pembeli"
                              ? Text(
                                  "Anda sebagai pembeli.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              : const SizedBox(),
                          collectionName == "pengguna_penjual"
                              ? tipePenjual == "Tetap"
                                  ? const Text(
                                      "Toko anda sedang online.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : const Text(
                                      "Dagangan anda sedang online.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                              : const SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 0),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Mode gelap'),
                            value: _isDarkMode,
                            onChanged: (bool value) async {
                              themeData = Theme.of(context);

                              setState(() {
                                if (themeData!.brightness == Brightness.dark) {
                                  objThemeForSaveLokal = {"theme": 'light'};

                                  context
                                      .read<ThemeToggleBloc>()
                                      .add(ThemeToggleEventSetLight());

                                  _isDarkMode = false;
                                } else {
                                  objThemeForSaveLokal = {"theme": 'dark'};

                                  context
                                      .read<ThemeToggleBloc>()
                                      .add(ThemeToggleEventSetDark());

                                  _isDarkMode = true;
                                }
                              });

                              await handleSaveLokalThemeMode();
                            },
                            secondary: const Icon(Icons.dark_mode),
                          ),
                          const SizedBox(height: 14),
                          Card(
                            clipBehavior: Clip.hardEdge,
                            child: InkWell(
                              onTap: () {
                                if (collectionName == 'pengguna_penjual') {
                                  context.goNamed(
                                    Routes.ubahProfilePage,
                                    queryParameters: {
                                      "id_penjual": idPengguna,
                                      "tipe_penjual": tipePenjual,
                                      "nama_penjual": namaPengguna,
                                      "nama_dagangan": namaDagangan,
                                    },
                                  );
                                } else {
                                  context.goNamed(
                                    Routes.ubahProfilePage,
                                    queryParameters: {
                                      "id_pembeli": idPengguna,
                                      "nama_pembeli": namaPengguna,
                                    },
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.fromLTRB(13, 16, 10, 16),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.settings,
                                    ),
                                    SizedBox(width: 15.0),
                                    Text(
                                      'Ubah profile',
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    // height: 60,
                    width: double.infinity,
                    // color: Colors.white,
                    color: Theme.of(context).colorScheme.background,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          barrierDismissible:
                              false, // Biar ga hilang saat klik outside
                          builder: (BuildContext context) {
                            return WillPopScope(
                              onWillPop: () async {
                                return false; // Biar ga hilang saat klik back
                              },
                              child: AlertDialog(
                                title: const Text('Log out?'),
                                content: const Text(
                                    'Yakin ingin keluar dari akun anda?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Tidak'),
                                    child: const Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (collectionName ==
                                          "pengguna_penjual") {
                                        await pocketbaseService
                                            .setLogoutPenggunaPenjual(
                                                idPengguna, true);
                                      } else if (collectionName ==
                                          "pengguna_pembeli") {
                                        await pocketbaseService
                                            .setLogoutPenggunaPembeli(
                                                idPengguna, true);
                                      }

                                      await sharedPreferencesService
                                          .removeLocalDataString(
                                              'authStoreData');

                                      context.pushReplacementNamed(
                                          Routes.gabungPage);

                                      Navigator.pop(context, 'Ya');
                                    },
                                    child: const Text('Ya'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.red, // Warna border tombol
                          width: 2, // Ketebalan border tombol
                        ),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.red, // Warna teks tombol
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : isRender && !isHasInternetAccess
              ? Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: Text('Cek lagi'),
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
