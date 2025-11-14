import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../bloc/bloc.dart';
import '../../../../routes/router.dart';
import '../../../../services/geocoding.dart';
import '../../../../services/http_request.dart';
import '../../../../services/launch_url.dart';
import '../../../../services/pocketbase.dart';
import '../../../../services/shared_preferences.dart';
import '../../../../services/timestamp.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  const PanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  LaunchURLService launchURLService = LaunchURLService();

  bool isLoadingKirimPesan = false;

  final TextEditingController alamatLengkapBeliBang =
      TextEditingController(text: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilFungsiSebelumLoadHalaman();
  }

  bool isSudahGabung = false;
  Future<void> antriPanggilFungsiSebelumLoadHalaman() async {
    final _cekAuth = await cekAuth();

    if (_cekAuth! == true) {
      setState(() {
        isSudahGabung = true;
      });

      await getPenggunaLocal();
      await getPenggunaPembeli();
    }
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  Future<bool?> cekAuth() async {
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    return cariLocalDataStringAuthStore;
  }

  String collectionName = "";
  String? idPenggunaPembeli, namaSaya;
  Future<void> getPenggunaLocal() async {
    final getLocalAuthStoreData =
        await sharedPreferencesService.getLocalDataString('authStoreData');

    var toString = jsonEncode(getLocalAuthStoreData);
    var toMap = jsonDecode(toString);

    var modelAuthStore = toMap['model'];
    setState(() {
      collectionName = modelAuthStore['collectionName'];
    });

    if (collectionName == 'pengguna_pembeli') {
      setState(() {
        idPenggunaPembeli = modelAuthStore['id'];
        namaSaya = modelAuthStore['nama'];
      });
    }
  }

  PocketbaseService pocketbaseService = PocketbaseService();
  Future<void> getPenggunaPembeli() async {
    if (collectionName == 'pengguna_penjual') {
      context
          .read<DataPembeliRealtimeBloc>()
          .add(DataPembeliRealtimeEventInitial(false, ""));

      pb.collection('pengguna_pembeli').subscribe('*', (e) {
        context
            .read<DataPembeliRealtimeBloc>()
            .add(DataPembeliRealtimeEventInitial(false, ""));
      });

      context
          .read<DataAnonimRealtimeBloc>()
          .add(DataAnonimRealtimeEventInitial(false, ""));

      pb.collection('pengguna_anonim').subscribe('*', (e) {
        context
            .read<DataAnonimRealtimeBloc>()
            .add(DataAnonimRealtimeEventInitial(false, ""));
      });
    }
  }

  bool isPaksaRefreshHalaman = false;

  bool isSedangModeJelajah = false;

  bool isTidakAdaPedagangDisekitar = false;
  int? banyaknyaCalonPembeliAnonim = 0,
      banyaknyaCalonPembeli = 0,
      banyaknyaCalonPembeliJumlah;
  String? banyaknyaPedagang, banyaknyaCalonPembeliTotal;

  @override
  Widget build(BuildContext context) {
    String? subLocality;

    Future<void> handleKirimPesan(itemDataPenjualTarget) async {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: const CircularProgressIndicator(),
        dismissOnTap: false,
      );

      final cekApakahSudahPernahChat =
          await pocketbaseService.cekApakahSudahPernahChat(
              itemDataPenjualTarget.id, idPenggunaPembeli);

      if (cekApakahSudahPernahChat!['data']['items'].length == 0) {
        await EasyLoading.dismiss();

        context
            .read<ChatRoomDetailsRealtimeBloc>()
            .add(ChatRoomDetailsRealtimeEventGetByIdChatRoom('null'));

        context.goNamed(
          Routes.chatDetailsPage,
          queryParameters: {
            "id_penjual": itemDataPenjualTarget.id,
            "nama_dagang": itemDataPenjualTarget.namaDagang,
            "nama_penjual": itemDataPenjualTarget.namaPenjual,
            "token_fcm_penjual": itemDataPenjualTarget.tokenFcm,
          },
        );

        print('queryParameters .length == 0 = ${{
          "id_penjual": itemDataPenjualTarget.id,
          "nama_dagang": itemDataPenjualTarget.namaDagang,
          "nama_penjual": itemDataPenjualTarget.namaPenjual,
          "token_fcm_penjual": itemDataPenjualTarget.tokenFcm,
        }}');
      } else {
        await EasyLoading.dismiss();

        var itemsChatRoom = cekApakahSudahPernahChat['data']['items'];

        context.goNamed(
          Routes.chatDetailsPage,
          queryParameters: {
            "id_chat_room": itemsChatRoom[0]['id'],
            "nama_dagang": itemDataPenjualTarget.namaDagang,
            "nama_penjual": itemDataPenjualTarget.namaPenjual,
            "token_fcm_penjual": itemDataPenjualTarget.tokenFcm,
          },
        );

        print('queryParameters else = ${{
          "id_chat_room": itemsChatRoom[0]['id'],
          "nama_dagang": itemDataPenjualTarget.namaDagang,
          "nama_penjual": itemDataPenjualTarget.namaPenjual,
          "token_fcm_penjual": itemDataPenjualTarget.tokenFcm,
        }}');
      }
    }

    double? latitudeLokalSaya, longitudeLokalSaya;
    Future<void> updateVariableLokasiLokalSaya() async {
      final cariLocallokasiSayaTerkini = await sharedPreferencesService
          .cariLocalDataString('lokasiSayaTerkini');
      if (cariLocallokasiSayaTerkini!) {
        final getLokasiSayaTerkini = await sharedPreferencesService
            .getLocalDataString('lokasiSayaTerkini');
        latitudeLokalSaya = getLokasiSayaTerkini!['latitude'];
        longitudeLokalSaya = getLokasiSayaTerkini['longitude'];
      }
    }

    GeocodingService geocodingService = GeocodingService();
    TimestampService timestampService = TimestampService();
    String? subLocalityBeliBang,
        localityBeliBang,
        administrativeAreaBeliBang,
        postalCodeBeliBang;
    Future<void> handleTambahPesanan(idPenjual) async {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: const CircularProgressIndicator(),
        dismissOnTap: false,
      );

      await updateVariableLokasiLokalSaya();
      final getPlace = await geocodingService.getPlace(
          latitudeLokalSaya, longitudeLokalSaya);
      setState(() {
        subLocalityBeliBang = getPlace['subLocality'];
        localityBeliBang = getPlace['locality'];
        administrativeAreaBeliBang = getPlace['administrativeArea'];
        postalCodeBeliBang = getPlace['postalCode'];
      });

      var objAlamatTujuan = {
        "latitude": latitudeLokalSaya,
        "longitude": longitudeLokalSaya,
        "sub_locality": subLocalityBeliBang,
        "locality": localityBeliBang,
        "administrative_area": administrativeAreaBeliBang,
        "postal_code": postalCodeBeliBang,
        "alamat_lengkap": alamatLengkapBeliBang.text
      };

      int getTimestamp = timestampService.getTimestamp();

      await pocketbaseService.tambahPesanan(
          idPenjual, idPenggunaPembeli, objAlamatTujuan, getTimestamp);

      await EasyLoading.dismiss();

      setState(() {
        alamatLengkapBeliBang.text = "";
      });

      await EasyLoading.showSuccess('Sukses beli!');
    }

    HttpRequestService httpRequestService = HttpRequestService();
    Future<void> handleBeliBang(idPenjual, tokenFCMTarget) async {
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
        indicator: CircularProgressIndicator(),
        dismissOnTap: false,
      );

      final cekPesanan =
          await pocketbaseService.cekPesanan(idPenjual, idPenggunaPembeli);
      if (cekPesanan!['status'] == 'sukses') {
        bool isShowModal = false;
        if (cekPesanan['data']['items'].length == 0) {
          isShowModal = true;
        } else {
          var item = cekPesanan['data']['items'];
          for (var i = 0; i < item.length; i++) {
            if (item[i]['is_terima'] == false &&
                item[i]['is_sukses'] == false &&
                item[i]['is_batal'] == false) {
              // MASIH BELUM DIPROSES
              isShowModal = false;
              break;
            } else if (item[i]['is_terima'] == true &&
                item[i]['is_sukses'] == false &&
                item[i]['is_batal'] == false) {
              // MASIH DIPROSES
              isShowModal = false;
              break;
            } else {
              if (item[i]['is_terima'] == false &&
                  item[i]['is_sukses'] == false &&
                  item[i]['is_batal'] == true) {
                // BELUM DIPROSES, TAPI DIBATALKAN OLEH PEMBELI
                isShowModal = true;
                // break;
              } else if (item[i]['is_terima'] == true &&
                  item[i]['is_sukses'] == true &&
                  item[i]['is_batal'] == false) {
                // PESANAN SUKSES
                isShowModal = true;
                // break;
              } else if (item[i]['is_terima'] == true &&
                  item[i]['is_sukses'] == false &&
                  item[i]['is_batal'] == true) {
                // PESANAN GAGAL
                isShowModal = true;
                // break;
              }
            }
          }
        }

        if (isShowModal == false) {
          await EasyLoading.dismiss();

          await EasyLoading.showInfo('Ada pesanan yang sedang diproses.');
        } else {
          await updateVariableLokasiLokalSaya();
          final getPlace = await geocodingService.getPlace(
              latitudeLokalSaya, longitudeLokalSaya);
          setState(() {
            subLocalityBeliBang = getPlace['subLocality'];
            localityBeliBang = getPlace['locality'];
            administrativeAreaBeliBang = getPlace['administrativeArea'];
            postalCodeBeliBang = getPlace['postalCode'];
          });

          await EasyLoading.dismiss();

          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  title: Text(
                    'Periksa & isi alamat lengkap',
                    style: TextStyle(fontSize: 18),
                  ),
                  children: <Widget>[
                    SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .yellow, // Ganti dengan warna yang Anda inginkan
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Saat anda klik 'Beli sekarang', pastikan anda tetap di tempat hingga penjual tiba di lokasi anda!",
                          style: TextStyle(
                            color: Colors
                                .black, // Ganti warna teks sesuai kebutuhan
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
                      child: Text(
                          "Anda berada di ${subLocalityBeliBang}, ${localityBeliBang}, ${administrativeAreaBeliBang}, ${postalCodeBeliBang}."),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Alamat lengkap anda * ",
                        ),
                        controller: alamatLengkapBeliBang,
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        TextButton(
                          child: Text('Batal'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              alamatLengkapBeliBang.text = "";
                            });
                          },
                        ),
                        TextButton(
                          child: Text('Beli sekarang'),
                          onPressed: () async {
                            Navigator.pop(context, 'Beli sekarang');

                            if (alamatLengkapBeliBang.text.length != 0) {
                              await handleTambahPesanan(idPenjual);

                              var titleNotifTarget = 'Ada yang beli..';
                              var bodyNotifTarget =
                                  '${namaSaya} ingin membeli dagangan anda!';

                              await httpRequestService.kirimNotifikasi(
                                  tokenFCMTarget,
                                  titleNotifTarget,
                                  bodyNotifTarget);

                              print(
                                  "SDG kirimNotifikasi dg title = ${titleNotifTarget}. body = ${bodyNotifTarget} dg tokenFCMTarget = ${tokenFCMTarget}");
                            } else {
                              setState(() {
                                alamatLengkapBeliBang.text = "";
                              });
                              await EasyLoading.showInfo(
                                  "Alamat lengkap harus diisi!");
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
    }

    Future<void> handleOpenRuteGoogleMap(latitude, longitude) async {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Arahkan via Google Map'),
          content: const Text(
              'Kamu akan diarahkan ke lokasi penjual melalui Google Map via aplikasi maupun website.'),
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

    Future<void> showInfoAlamatPenjualTetap(
        BuildContext context, itemDataPenjualTarget) async {
      String? subLocality, locality, administrativeArea, postalCode;

      final getPlace = await geocodingService.getPlace(
          itemDataPenjualTarget.alamatTetap.latitude,
          itemDataPenjualTarget.alamatTetap.longitude);
      setState(() {
        subLocality = getPlace['subLocality'];
        locality = getPlace['locality'];
        administrativeArea = getPlace['administrativeArea'];
        postalCode = getPlace['postalCode'];
      });

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(26.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Info alamat penjual",
                    style: TextStyle(
                      fontSize:
                          21, // Sesuaikan dengan ukuran font yang Anda inginkan
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    "Nama dagangan",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${itemDataPenjualTarget.namaDagang}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  Text(
                    "Nama penjual",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${itemDataPenjualTarget.namaPenjual}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  Text(
                    "Alamat",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${itemDataPenjualTarget.alamatTetap.alamatLengkap}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${subLocality}, ${locality}, ${administrativeArea}, ${postalCode}.",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // ListTile(
                  //     // leading: new Icon(Icons.share),
                  //     // title: new Text('Share'),
                  //     // onTap: () {
                  //     //   Navigator.pop(context);
                  //     // },
                  //     ),
                ],
              ),
            );
          });
    }

    Future<void> _showModalBottomSheet(
        BuildContext context, itemDataPenjualTarget) async {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text('Kirim pesan'),
                  onTap: () async {
                    Navigator.pop(context);
                    await handleKirimPesan(itemDataPenjualTarget);
                  },
                ),
                itemDataPenjualTarget.isLogOut == false &&
                        itemDataPenjualTarget.isOnline == true
                    ? itemDataPenjualTarget.tipePenjual[0] == 'Tetap'
                        ? Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.directions_run),
                                title: const Text('Datangi penjual'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await handleOpenRuteGoogleMap(
                                      itemDataPenjualTarget
                                          .alamatTetap.latitude,
                                      itemDataPenjualTarget
                                          .alamatTetap.longitude);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Info alamat'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await showInfoAlamatPenjualTetap(
                                      context, itemDataPenjualTarget);
                                },
                              ),
                            ],
                          )
                        : isSedangModeJelajah == false
                            ? ListTile(
                                leading: const Icon(Icons.record_voice_over),
                                title: const Text('Beli bang'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await handleBeliBang(itemDataPenjualTarget.id,
                                      itemDataPenjualTarget.tokenFcm);
                                },
                              )
                            : const SizedBox()
                    : const SizedBox(),
              ],
            );
          });

      // return completer.future;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.background,
      child: ListView(
        controller: widget.controller,
        padding: EdgeInsets.zero,
        children: [
          buildDragHandler(),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: isPaksaRefreshHalaman == false
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              isPaksaRefreshHalaman == false
                  ? Container(
                      child: BlocConsumer<StatusSubLocalityBloc,
                          StatusSubLocalityState>(
                        listener: (context, state) {
                          if (state is StatusSubLocalityStateShare) {
                            if (state.isModeJelajah == true) {
                              setState(() {
                                isSedangModeJelajah = true;
                              });
                            } else {
                              setState(() {
                                isSedangModeJelajah = false;
                              });
                            }
                          }
                        },
                        builder: (context, state) {
                          if (state is StatusSubLocalityStateShare) {
                            if (state.isModeJelajah == true) {
                              return Text(
                                state.isDragMapJelajah == true
                                    ? 'Menjelajah ...'
                                    : 'Menjelajah ${state.subLocality}..',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else {
                              return Text(
                                'Disekitar ${state.subLocality}..',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                          }

                          return const Text(
                            '....',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 4),
              isPaksaRefreshHalaman == false
                  ? Text(
                      isSudahGabung
                          ? collectionName == "pengguna_penjual"
                              ? banyaknyaPedagang == null &&
                                      banyaknyaCalonPembeliTotal == null
                                  ? 'Calon pembeli sekitar ... Orang, serta ... pedagang.'
                                  : 'Calon pembeli sekitar ${banyaknyaCalonPembeliTotal} Orang, serta ${banyaknyaPedagang} pedagang.'
                              : banyaknyaPedagang == null
                                  ? 'Terdapat sekitar ... pedagang.'
                                  : int.parse(banyaknyaPedagang!) == 0
                                      ? 'Oopss.. pedagang tidak ditemukan..'
                                      : 'Terdapat sekitar ${banyaknyaPedagang} pedagang.'
                          : banyaknyaPedagang == null
                              ? 'Terdapat sekitar ... pedagang.'
                              : int.parse(banyaknyaPedagang!) == 0
                                  ? 'Oopss.. pedagang tidak ditemukan..'
                                  : 'Terdapat sekitar ${banyaknyaPedagang} pedagang.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 8),
              BlocConsumer<DataPembeliRealtimeBloc, DataPembeliRealtimeState>(
                listener: (context, state) {
                  if (state is DataPembeliRealtimeStateJumlahCalonPembeli) {
                    banyaknyaCalonPembeli = 0;
                    banyaknyaCalonPembeliJumlah = 0;

                    banyaknyaCalonPembeli = state.banyakCalonPembeli;
                    banyaknyaCalonPembeliJumlah =
                        banyaknyaCalonPembeliAnonim! + banyaknyaCalonPembeli!;
                    setState(() {
                      if (banyaknyaCalonPembeliJumlah! > 100) {
                        banyaknyaCalonPembeliTotal = "100+";
                      } else {
                        banyaknyaCalonPembeliTotal =
                            banyaknyaCalonPembeliJumlah.toString();
                      }
                    });
                  }
                },
                builder: (context, state) {
                  return const SizedBox();
                },
              ),
              BlocConsumer<DataAnonimRealtimeBloc, DataAnonimRealtimeState>(
                listener: (context, state) {
                  if (state is DataAnonimRealtimeStateJumlahCalonPembeli) {
                    banyaknyaCalonPembeliJumlah = 0;

                    int? banyaknyaCalonPembeliAnonim;
                    setState(() {
                      banyaknyaCalonPembeliAnonim = 0;
                    });

                    banyaknyaCalonPembeliAnonim = state.banyakCalonPembeli;
                    banyaknyaCalonPembeliJumlah =
                        banyaknyaCalonPembeli! + banyaknyaCalonPembeliAnonim!;

                    setState(() {
                      if (banyaknyaCalonPembeliJumlah! > 100) {
                        banyaknyaCalonPembeliTotal = "100+";
                      } else {
                        banyaknyaCalonPembeliTotal =
                            banyaknyaCalonPembeliJumlah.toString();
                      }
                    });
                  }
                },
                builder: (context, state) {
                  return const SizedBox();
                },
              ),
              BlocBuilder<DataPenjualRealtimeBloc, DataPenjualRealtimeState>(
                builder: (context, state) {
                  if (state is DataPenjualRealtimeStateChange) {
                    return Column(
                      children: state.items!.map((item) {
                        if (item.isMarkerClicked == true) {
                          return Card(
                            child: ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(child: Text(item.namaDagang[0])),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: item.isOnline
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                item.namaDagang,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          item.jaraknya != null
                                              ? '${double.parse(item.jaraknya.toStringAsFixed(2)).toString()} km dari lokasi anda'
                                              : 'Mohon untuk aktifkan dan izinkan lokasi.',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                          item.tipePenjual[0] == 'Tetap'
                                              ? Icons.store
                                              : Icons.directions_car,
                                          size: 16),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          'Penjual ${item.tipePenjual[0]}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: collectionName == 'pengguna_pembeli'
                                  ? IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () async {
                                        await _showModalBottomSheet(
                                            context, item);
                                      },
                                    )
                                  : const SizedBox(),
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
              BlocConsumer<DataPenjualRealtimeBloc, DataPenjualRealtimeState>(
                listener: (context, state) {
                  if (state is DataPenjualRealtimeStateSubLocalityNull) {
                    setState(() {
                      isPaksaRefreshHalaman = true;
                    });
                  }

                  if (state is DataPenjualRealtimeStateResultListsNull) {
                    setState(() {
                      isTidakAdaPedagangDisekitar = true;
                    });
                  }

                  if (state is DataPenjualRealtimeStateChange) {
                    setState(() {
                      isTidakAdaPedagangDisekitar = false;
                      // banyaknyaPedagang = state.items!.length;
                    });

                    int hitungJumlahPedagangYangTidakLogout = 0;
                    for (var i = 0; i < state.items!.length; i++) {
                      print(
                          "Hitung jumlah pedagang yang tidak logOut | dari ${state.items!.length}");

                      if (state.items![i].tipePenjual[0] == "Tetap") {
                        if (state.items![i].isLogOut != true) {
                          hitungJumlahPedagangYangTidakLogout++;
                        }
                      } else {
                        if (state.items![i].isLogOut != true &&
                            state.items![i].isOnline == true) {
                          hitungJumlahPedagangYangTidakLogout++;
                        }
                      }
                    }

                    setState(() {
                      if (hitungJumlahPedagangYangTidakLogout > 100) {
                        banyaknyaPedagang = "100+";
                      } else {
                        banyaknyaPedagang =
                            hitungJumlahPedagangYangTidakLogout.toString();
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DataPenjualRealtimeStateLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is DataPenjualRealtimeStateSubLocalityNull) {
                    return Column(
                      children: [
                        const Text(
                          "Mohon izinkan layanan Lokasi diponsel dan aplikasi.",
                          style: TextStyle(
                            fontSize: 14.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // cekKoneksi(true);
                            context.pushReplacementNamed(
                                Routes.bottomNavigasiPage);
                            setState(() {
                              isPaksaRefreshHalaman = false;
                            });
                          },
                          child: const Text('Cek lagi'),
                        )
                      ],
                    );
                  }

                  if (state is DataPenjualRealtimeStateChange) {
                    return Column(
                      children: state.items!.map((item) {
                        if (item.isLogOut == false) {
                          if (item.tipePenjual[0] == 'Tetap' &&
                              item.isMarkerClicked == false) {
                            return Card(
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                        child: Text(item.namaDagang[0])),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item.isOnline
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  item.namaDagang,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16),
                                        const SizedBox(width: 7),
                                        Flexible(
                                          child: Text(
                                            item.jaraknya != null
                                                ? '${double.parse(item.jaraknya.toStringAsFixed(2)).toString()} km dari lokasi anda'
                                                : 'Mohon untuk aktifkan dan izinkan lokasi.',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                            item.tipePenjual[0] == 'Tetap'
                                                ? Icons.store
                                                : Icons.directions_car,
                                            size: 16),
                                        const SizedBox(width: 7),
                                        Flexible(
                                          child: Text(
                                            'Penjual ${item.tipePenjual[0]} ',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: collectionName == 'pengguna_pembeli'
                                    ? IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () async {
                                          await _showModalBottomSheet(
                                              context, item);
                                        },
                                      )
                                    : const SizedBox(),
                              ),
                            );
                          } else {
                            if (item.isOnline == true &&
                                item.isMarkerClicked == false) {
                              return Card(
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                          child: Text(item.namaDagang[0])),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    item.namaDagang,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16),
                                          const SizedBox(width: 7),
                                          Flexible(
                                            child: Text(
                                              '${double.parse(item.jaraknya.toStringAsFixed(2)).toString()} km dari lokasi anda ',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                              item.tipePenjual[0] == 'Tetap'
                                                  ? Icons.store
                                                  : Icons.directions_car,
                                              size: 16),
                                          const SizedBox(width: 7),
                                          Flexible(
                                            child: Text(
                                              'Penjual ${item.tipePenjual[0]} ',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: collectionName == 'pengguna_pembeli'
                                      ? IconButton(
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () async {
                                            await _showModalBottomSheet(
                                                context, item);
                                          },
                                        )
                                      : const SizedBox(),
                                ),
                              );
                            }
                          }
                        }

                        return const SizedBox();
                      }).toList(),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildDragHandler() => GestureDetector(
        // child: Card(
        child: Container(
          // color: Colors.yellow,
          height: 15,
          child: Center(
            child: Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        // ),
        onTap: togglePanel,
      );

  void togglePanel() {
    if (widget.panelController.isPanelOpen) {
      widget.panelController.close();
    } else {
      widget.panelController.open();
    }
  }
}
