import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../../bloc/bloc.dart';
import '../../../../services/http_request.dart';
import '../../../../services/timestamp.dart';
import '../../../../services/launch_url.dart';
import '../../../../services/pocketbase.dart';
import '../../../../services/shared_preferences.dart';

class ChatDetailsPage extends StatefulWidget {
  const ChatDetailsPage(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<ChatDetailsPage> createState() => _ChatDetailsPageState();
}

class _ChatDetailsPageState extends State<ChatDetailsPage> {
  ScrollController _scrollController = ScrollController();

  PocketbaseService pocketbaseService = PocketbaseService();
  TimestampService timestampService = TimestampService();
  LaunchURLService launchURLService = LaunchURLService();
  HttpRequestService httpRequestService = HttpRequestService();

  final TextEditingController messageTextField =
      TextEditingController(text: "");

  bool isPertamaKaliChat = false;

  String? idPenjual, namaDagang, namaPenjual, tokenFCMPenjual;
  String? idPembeli, namaPembeli, tokenFCMPembeli;

  String id = "";

  String? idChatRoom;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController = ScrollController();

    antriPanggilFungsiSebelumLoadHalaman();
  }

  Future<void> antriPanggilFungsiSebelumLoadHalaman() async {
    await siapakahSaya();
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  var collectionName, idSaya, namaSaya;
  Future<void> siapakahSaya() async {
    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var modelAuthStore = toMap['model'];
    collectionName = modelAuthStore['collectionName'];
    idSaya = modelAuthStore['id'];

    if (collectionName == 'pengguna_pembeli') {
      setState(() {
        namaSaya = modelAuthStore['nama'];
      });
    } else {
      setState(() {
        namaSaya = modelAuthStore['nama_dagang'];
      });
    }
  }

  Future<void> aktifkanRealtimeChatRoomDetails() async {
    pb.collection('chat_rooms_details').subscribe('*', (e) {
      var record = e.record;
      var toString = jsonEncode(record);
      var toMap = jsonDecode(toString);

      if (toMap['id_chat_room'] == idChatRoom) {
        context
            .read<ChatRoomDetailsRealtimeBloc>()
            .add(ChatRoomDetailsRealtimeEventHandleUpdateChatLokal(toString));
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // Ambil parameter "id" dari route
    final route = ModalRoute.of(context);
    if (route != null) {
      final settings = route.settings;
      final arguments = settings.arguments as Map<String, dynamic>;

      if (arguments.containsKey("id_chat_room")) {
        idChatRoom = arguments["id_chat_room"];

        context
            .read<ChatRoomDetailsRealtimeBloc>()
            .add(ChatRoomDetailsRealtimeEventGetByIdChatRoom(idChatRoom!));

        await aktifkanRealtimeChatRoomDetails();
      }

      if (idChatRoom == null) {
        isPertamaKaliChat = true;
      }

      if (arguments.containsKey("id_penjual")) {
        idPenjual = arguments["id_penjual"];
      }

      if (arguments.containsKey("nama_dagang")) {
        namaDagang = arguments["nama_dagang"];
      }

      if (arguments.containsKey("nama_penjual")) {
        namaPenjual = arguments["nama_penjual"];
      }

      if (arguments.containsKey("token_fcm_penjual")) {
        tokenFCMPenjual = arguments["token_fcm_penjual"];
      }

      if (arguments.containsKey("id_pembeli")) {
        idPembeli = arguments["id_pembeli"];
      }

      if (arguments.containsKey("nama_pembeli")) {
        namaPembeli = arguments["nama_pembeli"];
      }

      if (arguments.containsKey("token_fcm_pembeli")) {
        tokenFCMPembeli = arguments["token_fcm_pembeli"];
      }
    }
  }

  @override
  void dispose() {
    print("Halaman chat detail diDESPOSE");

    // String? idPenjual, namaDagang, namaPenjual, tokenFCMPenjual;
    // String? idPembeli, namaPembeli, tokenFCMPembeli;

    // String id = "";

    // String? idChatRoom;
    // idChatRoom =

    pb.collection('chat_rooms_details').unsubscribe('*');

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> _parseMessageLinks(String message) {
      final words = message.split(' ');
      final List<InlineSpan> spans = [];

      for (var word in words) {
        if (word.startsWith('http://') || word.startsWith('https://')) {
          spans.add(
            TextSpan(
              text: word,
              style: const TextStyle(
                color: Colors.blue,
                // decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  // Tindakan saat tautan diklik
                  await launchURLService.launchURL("${word}");
                },
            ),
          );
          spans.add(const TextSpan(text: ' '));
        } else {
          spans.add(TextSpan(text: word + ' '));
        }
      }

      return spans;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                    child: Text(namaPembeli == null
                        ? "${namaDagang![0]}"
                        : "${namaPembeli![0]}")),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        namaPembeli == null
                            ? "${namaDagang}"
                            : "${namaPembeli}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      namaPembeli == null
                          ? Text(
                              "${namaPenjual}",
                              style: const TextStyle(fontSize: 13),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(7, 1, 7, 70),
            child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const BouncingScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                children: [
                  BlocConsumer<ChatRoomDetailsRealtimeBloc,
                      ChatRoomDetailsRealtimeState>(
                    listener: (context, state) async {
                      if (state is ChatRoomDetailsRealtimeStateSukses) {
                        int jumlahPesan = state.items!.length;

                        var senderIdPesanTerakhir =
                            state.items![jumlahPesan - 1].messages.senderId;

                        if (senderIdPesanTerakhir != idSaya) {
                          await pocketbaseService
                              .updateChatBaruTelahDibacaSaatPenerimaPosisiAktif(
                                  collectionName, idChatRoom);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatRoomDetailsRealtimeStateLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is ChatRoomDetailsRealtimeStateChatKosong) {
                        return const Center(
                          child: Text(
                            "Belum ada riwayat pesan.",
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      if (state is ChatRoomDetailsRealtimeStateSukses) {
                        return Column(
                          children: state.items!.map((item) {
                            return Container(
                              padding: const EdgeInsets.only(
                                  left: 0, right: 0, top: 0, bottom: 10),
                              child: Align(
                                alignment: (item.messages.senderId == idSaya
                                    ? Alignment.topRight
                                    : Alignment.topLeft),
                                child: Column(
                                  crossAxisAlignment:
                                      (item.messages.senderId == idSaya
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start),
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor:
                                          item.messages.message.length > 30
                                              ? 0.89
                                              : null,
                                      child: Card(
                                        clipBehavior: Clip.hardEdge,
                                        child: InkWell(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: RichText(
                                              text: TextSpan(
                                                text: '',
                                                children: _parseMessageLinks(
                                                    item.messages.message),
                                                style:
                                                    DefaultTextStyle.of(context)
                                                        .style,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      child: Text(
                                        // item.messages.timestamp.toString(),
                                        timestampService.ubahTimestampChat(
                                            int.parse(item.timestamp)),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ]),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
              // height: 60,
              width: double.infinity,
              // color: Colors.white,
              color: Theme.of(context).colorScheme.background,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      minLines: 1, // Tinggi minimum satu baris
                      maxLines: 7, // Untuk tumbuh secara dinamis
                      decoration: const InputDecoration(
                          hintText: "Ketik pesan...",
                          // hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      controller: messageTextField,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      if (messageTextField.text.length != 0) {
                        await EasyLoading.show(
                          status: 'loading...',
                          maskType: EasyLoadingMaskType.black,
                          indicator: const CircularProgressIndicator(),
                          dismissOnTap: false,
                        );

                        int getTimestamp = timestampService.getTimestamp();

                        bool isHarusPanggilBlocChatRoom = false;
                        if (idChatRoom == null) {
                          var idPenjualUntukCreateRoom,
                              idPembeliUntukCreateRoom;
                          var senderIdUntukCreateRoom = idSaya;

                          if (collectionName == 'pengguna_pembeli') {
                            idPenjualUntukCreateRoom = idPenjual;
                            idPembeliUntukCreateRoom = idSaya;
                          } else {
                            idPenjualUntukCreateRoom = idSaya;
                            idPembeliUntukCreateRoom = idPembeli;
                          }
                          final createChatRoom =
                              await pocketbaseService.createChatRoom(
                            idPenjualUntukCreateRoom,
                            idPembeliUntukCreateRoom,
                            messageTextField.text,
                            senderIdUntukCreateRoom,
                            getTimestamp,
                            collectionName,
                          );

                          if (createChatRoom!['status'] == 'sukses') {
                            // idChatRoom = createChatRoom['data']['id'];
                            setState(() {
                              idChatRoom = createChatRoom['data']['id'];
                              isHarusPanggilBlocChatRoom = true;
                            });

                            // print(
                            //     'SDG ChatRoomDetailsRealtimeEventGetByIdChatRoom PERTAMA KALINYA dg IDCHATROOM = ${createChatRoom['data']['id']}');

                            // context.read<ChatRoomDetailsRealtimeBloc>().add(
                            //     ChatRoomDetailsRealtimeEventGetByIdChatRoom(
                            //         createChatRoom['data']['id']));

                            // await aktifkanRealtimeChatRoomDetails();
                          } else {
                            print("Gagal createChatRoom");
                          }
                        } else {
                          final updateChatRoomLastMessage =
                              await pocketbaseService.updateChatRoomLastMessage(
                                  collectionName,
                                  idChatRoom,
                                  messageTextField.text,
                                  idSaya,
                                  getTimestamp);
                        }

                        final createMessageChatRoomDetails =
                            await pocketbaseService
                                .createMessageChatRoomDetails(
                                    idChatRoom,
                                    messageTextField.text,
                                    idSaya,
                                    getTimestamp);

                        var tokenFCMTarget, titleNotifTarget;
                        if (collectionName == 'pengguna_pembeli') {
                          tokenFCMTarget = tokenFCMPenjual;
                        } else {
                          tokenFCMTarget = tokenFCMPembeli;
                        }
                        titleNotifTarget = 'Chat ~ ${namaSaya}';

                        await httpRequestService.kirimNotifikasi(tokenFCMTarget,
                            titleNotifTarget, messageTextField.text);

                        print(
                            'kirimNotifikasi CHAT, dg tokenFCMTarget = ${tokenFCMTarget} ');

                        if (isHarusPanggilBlocChatRoom) {
                          print(
                              'SDG ChatRoomDetailsRealtimeEventGetByIdChatRoom PERTAMA KALINYA dg IDCHATROOM = ${idChatRoom}');

                          context.read<ChatRoomDetailsRealtimeBloc>().add(
                              ChatRoomDetailsRealtimeEventGetByIdChatRoom(
                                  idChatRoom!));

                          await aktifkanRealtimeChatRoomDetails();

                          setState(() {
                            isHarusPanggilBlocChatRoom = false;
                          });
                        }

                        setState(() {
                          messageTextField.text = "";
                        });
                        await EasyLoading.dismiss();
                      }
                    },
                    child: const Icon(Icons.send),
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right:
                7, // Adjust this value to position the FloatingActionButton as desired.
            child: FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                );
              },
              child: Icon(Icons.arrow_downward),
              mini: true,
            ),
          ),
        ],
      ),
    );
  }
}
