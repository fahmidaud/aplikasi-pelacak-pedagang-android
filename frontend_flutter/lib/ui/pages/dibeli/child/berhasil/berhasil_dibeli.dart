import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../../bloc/bloc.dart';
import '../../../../../services/pocketbase.dart';
import '../../../../../services/shared_preferences.dart';
import '../../../../../services/timestamp.dart';

class BerhasilDibeliWidget extends StatefulWidget {
  const BerhasilDibeliWidget({super.key});

  @override
  State<BerhasilDibeliWidget> createState() => _BerhasilDibeliWidgetState();
}

class _BerhasilDibeliWidgetState extends State<BerhasilDibeliWidget> {
  TimestampService timestampService = TimestampService();

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

  void showBottomDialogYakinHapus(idPesanan) {
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
                'Yakin ingin hapus?',
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
                      Navigator.pop(context);
                      await handleDeletePesanan(idPesanan);
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

  PocketbaseService pocketbaseService = PocketbaseService();
  Future<void> handleDeletePesanan(idPesanan) async {
    await EasyLoading.show(
      status: 'Sedang menghapus pesanan..',
      maskType: EasyLoadingMaskType.black,
      indicator: const CircularProgressIndicator(),
      dismissOnTap: false,
    );

    final deletePesanan = await pocketbaseService.deletePesanan(idPesanan);

    await EasyLoading.dismiss();

    if (deletePesanan!['status'] == 'sukses') {
      await EasyLoading.showSuccess('Berhasil hapus pesanan!');
    } else {
      await EasyLoading.showError("Gagal hapus pesanan!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BlocConsumer<PesananRealtimeByIdPenggunaBloc,
            PesananRealtimeByIdPenggunaState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PesananRealtimeByIdPenggunaStateLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is PesananRealtimeByIdPenggunaStateSukses) {
              return Column(
                children: state.items!.map((item) {
                  if (item.isSukses == true) {
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
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () {
                            showBottomDialogYakinHapus(item.id);
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
