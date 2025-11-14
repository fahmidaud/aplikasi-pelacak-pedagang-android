import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../../routes/router.dart';

import '../../../../../bloc/bloc.dart';
import '../../../../../services/launch_url.dart';
import '../../../../../services/pocketbase.dart';
import '../../../../../services/shared_preferences.dart';
import '../../../../../services/timestamp.dart';

class SedangDibeliWidget extends StatefulWidget {
  const SedangDibeliWidget({super.key});

  @override
  State<SedangDibeliWidget> createState() => _SedangDibeliWidgetState();
}

class _SedangDibeliWidgetState extends State<SedangDibeliWidget> {
  LaunchURLService launchURLService = LaunchURLService();

  TimestampService timestampService = TimestampService();
  PocketbaseService pocketbaseService = PocketbaseService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilFungsiSebelumLoadHalaman();
  }

  Future<void> antriPanggilFungsiSebelumLoadHalaman() async {
    await siapakahSaya();
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  var collectionName, idSaya;
  Future<void> siapakahSaya() async {
    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var modelAuthStore = toMap['model'];
    idSaya = modelAuthStore['id'];
    setState(() {
      collectionName = modelAuthStore['collectionName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    print('sedang_dibeli.dart sdg DIRENDER');

    Future<void> handleBatalkanPesanan(idPesanan) async {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Yakin mau batalin?',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Tidak'),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Ya');

                await pocketbaseService.batalkanPesanan(idPesanan);
              },
              child: const Text('Ya'),
            ),
          ],
        ),
      );
    }

    Future<void> handleKirimPesan(itemPesanan) async {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: const CircularProgressIndicator(),
        dismissOnTap: false,
      );

      var idPembeli, idPenjual;
      if (collectionName == 'pengguna_pembeli') {
        idPembeli = idSaya;
        idPenjual = itemPesanan.idPenjual;
      } else {
        idPenjual = idSaya;
        idPembeli = itemPesanan.idPembeli;
      }

      final cekApakahSudahPernahChat = await pocketbaseService
          .cekApakahSudahPernahChat(idPenjual, idPembeli);

      if (cekApakahSudahPernahChat!['data']['items'].length == 0) {
        await EasyLoading.dismiss();

        if (collectionName == 'pengguna_pembeli') {
          context.goNamed(
            Routes.chatDetailsPage,
            queryParameters: {
              "id_penjual": idPenjual,
              "nama_dagang": itemPesanan.expand.idPenjual.namaDagang,
              "nama_penjual": itemPesanan.expand.idPenjual.namaPenjual,
              "token_fcm_penjual": itemPesanan.expand.idPenjual.tokenFcm,
            },
          );
        } else {
          context.goNamed(
            Routes.chatDetailsPage,
            queryParameters: {
              "id_pembeli": idPembeli,
              "nama_pembeli": itemPesanan.expand.idPembeli.nama,
              "token_fcm_pembeli": itemPesanan.expand.idPembeli.tokenFcm,
            },
          );
        }
      } else {
        await EasyLoading.dismiss();

        var itemsChatRoom = cekApakahSudahPernahChat['data']['items'];

        if (collectionName == 'pengguna_pembeli') {
          context.goNamed(
            Routes.chatDetailsPage,
            queryParameters: {
              "id_chat_room": itemsChatRoom[0]['id'],
              "nama_dagang": itemPesanan.expand.idPenjual.namaDagang,
              "nama_penjual": itemPesanan.expand.idPenjual.namaPenjual,
              "token_fcm_penjual": itemPesanan.expand.idPenjual.tokenFcm,
            },
          );
        } else {
          context.goNamed(
            Routes.chatDetailsPage,
            queryParameters: {
              "id_chat_room": itemsChatRoom[0]['id'],
              "nama_pembeli": itemPesanan.expand.idPembeli.nama,
              "token_fcm_pembeli": itemPesanan.expand.idPembeli.tokenFcm,
            },
          );
        }
      }
    }

    Future<void> showInfoAlamatPembeli(
        BuildContext context, itemPesanan) async {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(26.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Info alamat pembeli",
                  style: TextStyle(
                    fontSize:
                        22, // Sesuaikan dengan ukuran font yang Anda inginkan
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 11,
                ),
                const Text(
                  "Nama",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "${itemPesanan.expand.idPembeli.nama}",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                const SizedBox(
                  height: 11,
                ),
                const Text(
                  "Alamat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  "${itemPesanan.alamatTujuan.alamatLengkap}",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  "${itemPesanan.alamatTujuan.subLocality}, ${itemPesanan.alamatTujuan.locality}, ${itemPesanan.alamatTujuan.administrativeArea}, ${itemPesanan.alamatTujuan.postalCode}.",
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Future<void> handleTerimaPesanan(idPesanan) async {
      int getTimestamp = timestampService.getTimestamp();

      final terimaPesanan =
          await pocketbaseService.terimaPesanan(idPesanan, getTimestamp);

      if (terimaPesanan!['status'] == 'sukses') {
        await EasyLoading.showSuccess('Berhasil terima pesanan!');
      } else {
        await EasyLoading.showError("Gagal terima pesanan!");
      }
    }

    Future<void> handleOpenRuteGoogleMap(latitude, longitude) async {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Arahkan via Google Map'),
          content: const Text(
              'Kamu akan diarahkan ke lokasi pembeli melalui Google Map via aplikasi maupun website.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Tidak'),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Ya');

                await launchURLService.launchURL(
                    "https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude");
              },
              child: const Text('Ya'),
            ),
          ],
        ),
      );
    }

    Future<void> handleSelesaikanPesanan(idPesanan) async {
      final selesaikanPesanan =
          await pocketbaseService.selesaikanPesanan(idPesanan);

      if (selesaikanPesanan!['status'] == 'sukses') {
        await EasyLoading.showSuccess('Berhasil selesaikan pesanan!');
      } else {
        await EasyLoading.showError("Gagal selesaikan pesanan!");
      }
    }

    Future<void> handlePesananTelahSelesai(idPesanan) async {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(
            collectionName == 'pengguna_penjual'
                ? 'Pembeli sudah membeli dagangan anda?'
                : 'Anda sudah membeli dagangannya?',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Belum'),
              child: const Text('Belum'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Sudah');

                await handleSelesaikanPesanan(idPesanan);
              },
              child: const Text('Ya'),
            ),
          ],
        ),
      );
    }

    void showAlertPedagangSedangProsesPesanan() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Penjual sedang proses pesanan anda',
            style: TextStyle(fontSize: 18),
          ),
          content: const Text(
              'Penjual sedang proses pesanan anda, anda baru bisa batalkan pesanan setelah 1 jam setelah pesanan diterima.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Tutup');
              },
              child: const Text('Ya'),
            ),
          ],
        ),
      );
    }

    Future<void> showMenuBottomModal(BuildContext context, itemPesanan) async {
      int? berapaMenitLagiSejakDiTerimaPesanan;
      if (itemPesanan.isTerima == true) {
        int selisihWaktuTimestamp = timestampService.selisihWaktuTimestamp(
            int.parse(itemPesanan.timestampTerimaPemesanan));

        if (selisihWaktuTimestamp < 60) {
          berapaMenitLagiSejakDiTerimaPesanan = 60 - selisihWaktuTimestamp;
        } else {
          berapaMenitLagiSejakDiTerimaPesanan = selisihWaktuTimestamp;
        }
      }

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                collectionName == 'pengguna_penjual'
                    ? itemPesanan.isTerima == true
                        ? ListTile(
                            leading: const Icon(Icons.directions_run),
                            title: const Text('Datangi pembeli'),
                            onTap: () async {
                              Navigator.pop(context);
                              await handleOpenRuteGoogleMap(
                                  itemPesanan.alamatTujuan.latitude,
                                  itemPesanan.alamatTujuan.longitude);
                            },
                          )
                        : ListTile(
                            leading: const Icon(Icons.grading),
                            title: const Text('Terima pesanan'),
                            onTap: () async {
                              Navigator.pop(context);
                              await handleTerimaPesanan(itemPesanan.id);
                            },
                          )
                    : itemPesanan.isTerima == true
                        ? ListTile(
                            leading: const Icon(Icons.location_searching),
                            title: const Text('Lacak penjual'),
                            onTap: () {
                              Navigator.pop(context);

                              context.goNamed(
                                Routes.lacakPenjualPage,
                                queryParameters: {
                                  "id_penjual": itemPesanan.idPenjual,
                                },
                              );
                            },
                          )
                        : const SizedBox(),
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Kirim pesan'),
                  onTap: () async {
                    Navigator.pop(context);
                    await handleKirimPesan(itemPesanan);
                  },
                ),
                collectionName == 'pengguna_penjual'
                    ? ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Info alamat pembeli'),
                        onTap: () async {
                          Navigator.pop(context);
                          await showInfoAlamatPembeli(context, itemPesanan);
                        },
                      )
                    : const SizedBox(),
                itemPesanan.isTerima == true
                    ? ListTile(
                        leading: const Icon(Icons.fact_check),
                        title: new Text(collectionName == 'pengguna_pembeli'
                            ? 'Pesanan telah diterima'
                            : 'Pesanan telah diselesaikan'),
                        onTap: () async {
                          Navigator.pop(context);
                          await handlePesananTelahSelesai(itemPesanan.id);
                        },
                      )
                    : const SizedBox(),
                collectionName == 'pengguna_penjual'
                    ? ListTile(
                        leading: const Icon(Icons.remove_shopping_cart),
                        title: const Text('Batalkan pesanan'),
                        onTap: () async {
                          Navigator.pop(context);
                          await handleBatalkanPesanan(itemPesanan.id);
                        },
                      )
                    : itemPesanan.isTerima == true
                        ? berapaMenitLagiSejakDiTerimaPesanan! > 60
                            ? ListTile(
                                leading: const Icon(Icons.remove_shopping_cart),
                                title: const Text('Batalkan pesanan'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await handleBatalkanPesanan(itemPesanan.id);
                                },
                              )
                            : ListTile(
                                leading: const Icon(Icons.remove_shopping_cart),
                                title: new Text(
                                    'Batalkan pesanan (${berapaMenitLagiSejakDiTerimaPesanan} menit lagi)'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  showAlertPedagangSedangProsesPesanan();
                                },
                              )
                        : ListTile(
                            leading: const Icon(Icons.remove_shopping_cart),
                            title: const Text('Batalkan pesanan'),
                            onTap: () async {
                              Navigator.pop(context);
                              await handleBatalkanPesanan(itemPesanan.id);
                            },
                          )
              ],
            );
          });
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocBuilder<PesananRealtimeByIdPenggunaBloc,
            PesananRealtimeByIdPenggunaState>(
          builder: (context, state) {
            if (state is PesananRealtimeByIdPenggunaStateLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is PesananRealtimeByIdPenggunaStateSukses) {
              return Column(
                children: state.items!.map((item) {
                  if (item.isSukses == false && item.isBatal == false) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(collectionName == 'pengguna_pembeli'
                                ? item.expand.idPenjual.namaDagang[0]
                                : item.expand.idPembeli.nama[0])),
                        title: Text(
                          collectionName == 'pengguna_pembeli'
                              ? item.expand.idPenjual.namaDagang
                              : item.expand.idPembeli.nama,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timelapse, size: 14),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    item.isTerima == false
                                        ? 'Menunggu konfirmasi'
                                        : 'Diproses',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.date_range, size: 14),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    'Dibeli ${timestampService.ubahTimestampChat(int.parse(item.timestampAwalPemesanan))}',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showMenuBottomModal(context, item);
                          },
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }).toList(),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }
}
