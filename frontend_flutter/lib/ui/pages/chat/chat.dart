import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../bloc/bloc.dart';
import '../../../routes/router.dart';
import '../../../services/internet_connection_checker_plus.dart';
import '../../../services/pocketbase.dart';
import '../../../services/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isRender = false;

  PocketbaseService pocketbaseService = PocketbaseService();
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
    } else {
      await cekKoneksi(false);
      await siapakahSaya();

      context
          .read<ChatRoomsRealtimeBloc>()
          .add(ChatRoomsRealtimeEventGetByIdSaya());

      aktifkanRealtimeChatRoom();
    }
  }

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

  void aktifkanRealtimeChatRoom() {
    pb.collection('chat_rooms').subscribe('*', (e) {
      var record = e.record;
      var toString = jsonEncode(record);
      var toMap = jsonDecode(toString);

      if (collectionName == 'pengguna_penjual') {
        if (toMap['id_penjual'] == idSaya) {
          context
              .read<ChatRoomsRealtimeBloc>()
              .add(ChatRoomsRealtimeEventGetByIdSaya());
        }
      }

      if (collectionName == 'pengguna_pembeli') {
        if (toMap['id_pembeli'] == idSaya) {
          context
              .read<ChatRoomsRealtimeBloc>()
              .add(ChatRoomsRealtimeEventGetByIdSaya());
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print("halaman chat DIDISPOSE");

    pb.collection('chat_rooms').unsubscribe('*');
    // pocketbaseService.unsubscribeChatRooms();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> handleHapusChatRoom(collectionName, itemChatRoom) async {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: const CircularProgressIndicator(),
        dismissOnTap: false,
      );
      await pocketbaseService.updateHapusChatRoom(collectionName, itemChatRoom);
      await EasyLoading.dismiss();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: isRender && isHasInternetAccess
          ? ListView(
              children: [
                // Column(
                //   children: <Widget>[
                BlocBuilder<ChatRoomsRealtimeBloc, ChatRoomsRealtimeState>(
                  builder: (context, state) {
                    if (state is ChatRoomsRealtimeStateLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is ChatRoomsRealtimeStateSukses) {
                      if (state.items!.length == 0) {
                        return const Column(
                          children: [
                            Text("Opps riwayat chat kosong."),
                          ],
                        );
                      } else {
                        return Column(
                          children: state.items!.map((item) {
                            if (collectionName == 'pengguna_pembeli') {
                              if (item.isHapusChat.byPembeli) {
                                return const SizedBox
                                    .shrink(); // Ini akan melewatkan item tersebut
                              }
                            } else {
                              if (item.isHapusChat.byPenjual) {
                                return const SizedBox
                                    .shrink(); // Ini akan melewatkan item tersebut
                              }
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                  child: Text(
                                collectionName == "pengguna_penjual"
                                    ? item.expand.idPembeli.nama[0]
                                    : item.expand.idPenjual.namaDagang[0],
                              )),
                              title: Text(
                                collectionName == "pengguna_penjual"
                                    ? item.expand.idPembeli.nama
                                    : item.expand.idPenjual.namaDagang,
                                overflow: TextOverflow
                                    .ellipsis, // Menampilkan titik-titik jika terlalu panjang
                                maxLines: 1, // Maksimal 1 baris
                              ),
                              subtitle: Text(
                                item.lastMessage.message,
                                overflow: TextOverflow
                                    .ellipsis, // Menampilkan titik-titik jika terlalu panjang
                                maxLines: 1,
                              ),
                              trailing: Badge(
                                backgroundColor:
                                    collectionName == "pengguna_penjual"
                                        ? item.isRead.byPenjual
                                            ? Colors.transparent
                                            : Colors.green
                                        : item.isRead.byPembeli
                                            ? Colors.transparent
                                            : Colors.green,
                              ),
                              onTap: () async {
                                await EasyLoading.show(
                                  status: 'loading...',
                                  maskType: EasyLoadingMaskType.black,
                                  indicator: const CircularProgressIndicator(),
                                  dismissOnTap: false,
                                );

                                final hasInternetAccess =
                                    await internetConnectionCheckerPlusService
                                        .cekKoneksiInternet();

                                if (hasInternetAccess!) {
                                  await pocketbaseService
                                      .updateChatBaruTelahDibaca(
                                          collectionName, item);
                                  if (collectionName == "pengguna_pembeli") {
                                    context.goNamed(
                                      Routes.chatDetailsPage,
                                      queryParameters: {
                                        "id_chat_room": item.id,
                                        "nama_dagang":
                                            item.expand.idPenjual.namaDagang,
                                        "nama_penjual":
                                            item.expand.idPenjual.namaPenjual,
                                        "token_fcm_penjual":
                                            item.expand.idPenjual.tokenFcm,
                                      },
                                    );
                                  } else {
                                    context.goNamed(
                                      Routes.chatDetailsPage,
                                      queryParameters: {
                                        "id_chat_room": item.id,
                                        "nama_pembeli":
                                            item.expand.idPembeli.nama,
                                        "token_fcm_pembeli":
                                            item.expand.idPembeli.tokenFcm,
                                      },
                                    );
                                  }

                                  await EasyLoading.dismiss();
                                } else {
                                  await EasyLoading.dismiss();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Periksa koneksi internet anda.."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: const Text('Hapus chat'),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await handleHapusChatRoom(
                                                collectionName, item);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        );
                      }
                    }

                    return const SizedBox();
                  },
                ),
                const Divider(height: 0),
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
