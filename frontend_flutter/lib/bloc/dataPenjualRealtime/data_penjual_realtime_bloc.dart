import 'dart:convert';

import 'package:bloc/bloc.dart';
// import 'package:meta/meta.dart';

import '../../services/calculate_distance.dart';
import '../../services/location.dart';
import '../../services/pocketbase.dart';
import '../../services/shared_preferences.dart';
import '../../models/penjual_result_list.dart';
import '../../models/penjual_items.dart';

part 'data_penjual_realtime_event.dart';
part 'data_penjual_realtime_state.dart';

class DataPenjualRealtimeBloc
    extends Bloc<DataPenjualRealtimeEvent, DataPenjualRealtimeState> {
  DataPenjualRealtimeBloc() : super(DataPenjualRealtimeInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();

    bool? isModeJelajah;
    String? subLocalityJelajah;
    on<DataPenjualRealtimeEventInitial>((event, emit) async {
      // final getSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
      //     await pocketbaseService
      //         .getSemuaPenggunaPenjualBerdasarkanSubLocaltiy('Sumberjaya');

      // print("getSemuaPenggunaPenjualBerdasarkanSubLocaltiy ,");
      // print(getSemuaPenggunaPenjualBerdasarkanSubLocaltiy);

      // var data = getSemuaPenggunaPenjualBerdasarkanSubLocaltiy!['data'];
      // if (data['totalItems'] == 0 &&
      //     getSemuaPenggunaPenjualBerdasarkanSubLocaltiy!['data']['status'] ==
      //         'sukses') {
      //   emit(DataPenjualRealtimeStateResultListsNull());
      // } else {
      //   // String toString =
      //   //     jsonEncode(getSemuaPenggunaPenjualBerdasarkanSubLocaltiy);

      //   // emit(DataPenjualRealtimeStateChange(
      //   //     resultList: penjualResultListFromJson(toString)));

      //   var items = data['items'];
      //   var array = [];
      //   for (var i = 0; i < data['totalItems']; i++) {
      //     if (items[i]['is_online'] == true) {
      //       array.add(items[i]);
      //     }
      //   }

      //   String toString = jsonEncode(array);
      //   print("Hasil di rapihin , DataPenjualRealtimeStateChange");
      //   print(toString);

      //   emit(DataPenjualRealtimeStateChange(
      //       items: penjualItemsFromJson(toString)));
      // }

      isModeJelajah = event.isModeJelajah;

      emit(DataPenjualRealtimeStateLoading());

      final cariLocalSubLocality =
          await sharedPreferencesService.cariLocalDataString('subLocality');
      if (cariLocalSubLocality!) {
        final getLocalSubLocality =
            await sharedPreferencesService.getLocalDataString('subLocality');
        print(
            'getLocalSubLocality di data_penjual_realtime_bloc = ${getLocalSubLocality!['sub_locality']}');

        var getSemuaPenggunaPenjualBerdasarkanSubLocaltiy;
        if (isModeJelajah!) {
          subLocalityJelajah = event.subLocalityJelajah;

          getSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
              await pocketbaseService
                  .getSemuaPenggunaPenjualBerdasarkanSubLocaltiy(
                      subLocalityJelajah);
        } else {
          getSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
              await pocketbaseService
                  .getSemuaPenggunaPenjualBerdasarkanSubLocaltiy(
                      getLocalSubLocality['sub_locality']);
        }

        print(
            "getSemuaPenggunaPenjualBerdasarkanSubLocaltiy , ${getSemuaPenggunaPenjualBerdasarkanSubLocaltiy}");
        // print(getSemuaPenggunaPenjualBerdasarkanSubLocaltiy);

        var dataSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
            getSemuaPenggunaPenjualBerdasarkanSubLocaltiy!['data'];
        if (dataSemuaPenggunaPenjualBerdasarkanSubLocaltiy['totalItems'] == 0 &&
            getSemuaPenggunaPenjualBerdasarkanSubLocaltiy['data']['status'] ==
                'sukses') {
          emit(DataPenjualRealtimeStateResultListsNull());
        } else {
          var itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
              dataSemuaPenggunaPenjualBerdasarkanSubLocaltiy['items'];
          print('itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy , ');
          print(itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy);
          var array = [];
          // for (var i = 0; i < data['totalItems']; i++) {
          //   if (items[i]['is_online'] == true) {
          //     array.add(items[i]);
          //   }
          // }

          // String toString = jsonEncode(array);
          // print("Hasil di rapihin , DataPenjualRealtimeStateChange");
          // print(toString);

          // emit(DataPenjualRealtimeStateChange(
          //     items: penjualItemsFromJson(toString)));

          LocationService locationService = LocationService();

          final serviceLocationAndroid = await locationService.checkService();
          // print(
          //     'serviceLocationAndroid = $serviceLocationAndroid');

          final permissionLocationApp =
              await locationService.checkPermissions();
          // print(
          //     'permissionLocationApp = $permissionLocationApp');

          bool isDapatHitungJarak = false;
          if (serviceLocationAndroid == true &&
              permissionLocationApp == PermissionStatus.granted) {
            print('Jarak mulai dihitung');

            isDapatHitungJarak = true;
          }

          final cariLocalDataStringAuthStore = await sharedPreferencesService
              .cariLocalDataString('authStoreData');
          // print(
          //     'cariLocalDataString "authStoreData" = $cariLocalDataStringAuthStore');

          if (cariLocalDataStringAuthStore!) {
            // JIKA SUDAH LOGIN
            final getLocalAuthStoreData = await sharedPreferencesService
                .getLocalDataString('authStoreData');
            print("getLocalAuthStoreData , ");
            print(getLocalAuthStoreData);

            var toString = jsonEncode(getLocalAuthStoreData);
            var toMap = jsonDecode(toString);

            var modelAuthStore = toMap['model'];
            var id = modelAuthStore['id'];
            var collectionName = modelAuthStore['collectionName'];

            // data['totalItems']
            for (var i = 0;
                i < itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy.length;
                i++) {
              if (collectionName == 'pengguna_penjual') {
                var tipePenjual = modelAuthStore['tipe_penjual'];
                if (itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]['id'] !=
                    id) {
                  double? jaraknya;
                  if (isDapatHitungJarak) {
                    double? latitudeSaya, longitudeSaya;
                    if (tipePenjual[0] == "Tetap") {
                      print(
                          "Kamu sebagai penjual TETAP, memakai DATA LOKAL authStoreData, ");
                      var alamatTetap = modelAuthStore['alamat_tetap'];
                      latitudeSaya = alamatTetap['latitude'];
                      longitudeSaya = alamatTetap['longitude'];
                      print(
                          'dengan LATITUDE $latitudeSaya , longitude $longitudeSaya ');
                    } else {
                      print(
                          "Kamu sebagai penjual KELILING, memakai DATA LOKAL ... , ");
                      // final getLocation = await locationService.getLocation();
                      // print("getLocation ${getLocation}");

                      // double latitude = getLocation.latitude!;
                      // double longitude = getLocation.longitude!;
                      // print('Koordinat saya $latitude,$longitude');

                      final cariLocallokasiSayaTerkini =
                          await sharedPreferencesService
                              .cariLocalDataString('lokasiSayaTerkini');
                      if (cariLocallokasiSayaTerkini!) {
                        final getLokasiSayaTerkini =
                            await sharedPreferencesService
                                .getLocalDataString('lokasiSayaTerkini');
                        latitudeSaya = getLokasiSayaTerkini!['latitude'];
                        longitudeSaya = getLokasiSayaTerkini['longitude'];
                        print(
                            'dengan LATITUDE $latitudeSaya , longitude $longitudeSaya ');
                      }
                    }

                    double? latitudePenjualLain, longitudePenjualLain;
                    if (itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['tipe_penjual'][0] ==
                        "Tetap") {
                      latitudePenjualLain =
                          itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                              ['alamat_tetap']['latitude'];
                      longitudePenjualLain =
                          itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                              ['alamat_tetap']['longitude'];
                    } else {
                      latitudePenjualLain =
                          itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                              ['alamat_keliling']['latitude'];
                      longitudePenjualLain =
                          itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                              ['alamat_keliling']['longitude'];
                    }

                    // double latitudeToko = items[i]['alamat_tetap']['latitude'];
                    // double longitudeToko =
                    //     items[i]['alamat_tetap']['longitude'];
                    print(
                        'Koordinat Toko Tetap $latitudePenjualLain,$longitudePenjualLain');

                    CalculateDistance calculateDistance = CalculateDistance();

                    jaraknya = calculateDistance.distance(
                        latitudeSaya!,
                        longitudeSaya!,
                        latitudePenjualLain!,
                        longitudePenjualLain!);
                    print('jaraknya = $jaraknya');
                  }

                  var obj = {
                    "id": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['id'],
                    "is_log_out":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['is_log_out'],
                    "created":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['created'],
                    "updated":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['updated'],
                    "collectionId":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['collectionId'],
                    "collectionName":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['collectionName'],
                    "expand": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['expand'],
                    "alamat_keliling":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_keliling'],
                    "alamat_tetap":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_tetap'],
                    "email": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['email'],
                    "emailVisibility":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['emailVisibility'],
                    "id_socket":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['id_socket'],
                    "is_online":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['is_online'],
                    "nama_dagang":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['nama_dagang'],
                    "nama_penjual":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['nama_penjual'],
                    "online_details":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['online_details'],
                    "sub_locality":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['sub_locality'],
                    "tipe_penjual":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['tipe_penjual'],
                    "username":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['username'],
                    "verified":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['verified'],
                    "jaraknya": jaraknya,
                    "is_marker_clicked": false,
                    "token_fcm":
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['token_fcm'],
                  };

                  // array.add(items[i]);
                  array.add(obj);
                }
              } else {
                double? jaraknya;
                if (isDapatHitungJarak) {
                  // final getLocation = await locationService.getLocation();
                  // print("getLocation ${getLocation}");

                  // double latitude = getLocation.latitude!;
                  // double longitude = getLocation.longitude!;

                  double? latitudeSaya, longitudeSaya;

                  final cariLocallokasiSayaTerkini =
                      await sharedPreferencesService
                          .cariLocalDataString('lokasiSayaTerkini');
                  if (cariLocallokasiSayaTerkini!) {
                    final getLokasiSayaTerkini = await sharedPreferencesService
                        .getLocalDataString('lokasiSayaTerkini');
                    latitudeSaya = getLokasiSayaTerkini!['latitude'];
                    longitudeSaya = getLokasiSayaTerkini['longitude'];
                    print(
                        'dengan LATITUDE $latitudeSaya , longitude $longitudeSaya ');
                  }
                  print('Koordinat saya $latitudeSaya,$longitudeSaya');

                  double? latitudeToko, longitudeToko;
                  if (itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['tipe_penjual'][0] ==
                      "Tetap") {
                    latitudeToko =
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_tetap']['latitude'];
                    longitudeToko =
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_tetap']['longitude'];
                  } else {
                    latitudeToko =
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_keliling']['latitude'];
                    longitudeToko =
                        itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                            ['alamat_keliling']['longitude'];
                  }
                  // double latitudeToko = items[i]['alamat_tetap']['latitude'];
                  // double longitudeToko = items[i]['alamat_tetap']['longitude'];
                  print('Koordinat Toko Tetap $latitudeToko,$longitudeToko');

                  CalculateDistance calculateDistance = CalculateDistance();

                  jaraknya = calculateDistance.distance(latitudeSaya!,
                      longitudeSaya!, latitudeToko!, longitudeToko!);
                  print('jaraknya = $jaraknya');
                }

                var obj = {
                  "id": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['id'],
                  "is_log_out":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['is_log_out'],
                  "created": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['created'],
                  "updated": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['updated'],
                  "collectionId":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['collectionId'],
                  "collectionName":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['collectionName'],
                  "expand": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['expand'],
                  "alamat_keliling":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_keliling'],
                  "alamat_tetap":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_tetap'],
                  "email": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['email'],
                  "emailVisibility":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['emailVisibility'],
                  "id_socket":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['id_socket'],
                  "is_online":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['is_online'],
                  "nama_dagang":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['nama_dagang'],
                  "nama_penjual":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['nama_penjual'],
                  "online_details":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['online_details'],
                  "sub_locality":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['sub_locality'],
                  "tipe_penjual":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['tipe_penjual'],
                  "username": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['username'],
                  "verified": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                      ['verified'],
                  "jaraknya": jaraknya,
                  "is_marker_clicked": false,
                  "token_fcm":
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['token_fcm'],
                };

                // array.add(items[i]);
                array.add(obj);
              }
            }

            String toStringItem = jsonEncode(array);
            print(
                "Hasil di rapihin , DataPenjualRealtimeStateChange & cariLocalDataStringAuthStore = ${cariLocalDataStringAuthStore}");
            print(toStringItem);

            List toMapItemSortingJarak = jsonDecode(toStringItem);
            toMapItemSortingJarak
                .sort((a, b) => a["jaraknya"].compareTo(b["jaraknya"]));
            print('toMapItemSortingJarak sesudah di sort ');
            print(toMapItemSortingJarak);

            String toStringItemSortingJarak = jsonEncode(toMapItemSortingJarak);

            emit(DataPenjualRealtimeStateChange(
                items: penjualItemsFromJson(toStringItemSortingJarak)));
          } else {
            // JIKA BELUM LOGIN (ANONIM)
            for (var i = 0;
                i < itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy.length;
                i++) {
              double? jaraknya;
              if (isDapatHitungJarak) {
                // final getLocation = await locationService.getLocation();
                // print("getLocation ${getLocation}");

                // double latitude = getLocation.latitude!;
                // double longitude = getLocation.longitude!;

                double? latitudeSaya, longitudeSaya;

                final cariLocallokasiSayaTerkini =
                    await sharedPreferencesService
                        .cariLocalDataString('lokasiSayaTerkini');
                print(
                    'Line 432 | cariLocallokasiSayaTerkini = ${cariLocallokasiSayaTerkini}');
                if (cariLocallokasiSayaTerkini!) {
                  final getLokasiSayaTerkini = await sharedPreferencesService
                      .getLocalDataString('lokasiSayaTerkini');
                  latitudeSaya = getLokasiSayaTerkini!['latitude'];
                  longitudeSaya = getLokasiSayaTerkini['longitude'];
                  print(
                      'dengan LATITUDE $latitudeSaya , longitude $longitudeSaya ');
                }

                print('Koordinat saya $latitudeSaya,$longitudeSaya');

                double? latitudeToko, longitudeToko;
                if (itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['tipe_penjual'][0] ==
                    "Tetap") {
                  latitudeToko =
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_tetap']['latitude'];
                  longitudeToko =
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_tetap']['longitude'];
                } else {
                  latitudeToko =
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_keliling']['latitude'];
                  longitudeToko =
                      itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                          ['alamat_keliling']['longitude'];
                }
                // double latitudeToko = items[i]['alamat_tetap']['latitude'];
                // double longitudeToko = items[i]['alamat_tetap']['longitude'];
                print('Koordinat Toko Tetap $latitudeToko,$longitudeToko');

                CalculateDistance calculateDistance = CalculateDistance();

                jaraknya = calculateDistance.distance(latitudeSaya!,
                    longitudeSaya!, latitudeToko!, longitudeToko!);
                print('jaraknya = $jaraknya');
              }

              var obj = {
                "id": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]['id'],
                "is_log_out": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['is_log_out'],
                "created": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['created'],
                "updated": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['updated'],
                "collectionId":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['collectionId'],
                "collectionName":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['collectionName'],
                "expand": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['expand'],
                "alamat_keliling":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['alamat_keliling'],
                "alamat_tetap":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['alamat_tetap'],
                "email": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['email'],
                "emailVisibility":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['emailVisibility'],
                "id_socket": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['id_socket'],
                "is_online": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['is_online'],
                "nama_dagang":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['nama_dagang'],
                "nama_penjual":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['nama_penjual'],
                "online_details":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['online_details'],
                "sub_locality":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['sub_locality'],
                "tipe_penjual":
                    itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                        ['tipe_penjual'],
                "username": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['username'],
                "verified": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['verified'],
                "jaraknya": jaraknya,
                "is_marker_clicked": false,
                "token_fcm": itemsSemuaPenggunaPenjualBerdasarkanSubLocaltiy[i]
                    ['token_fcm'],
              };

              // array.add(items[i]);
              array.add(obj);
            }

            String toStringItem = jsonEncode(array);
            print("Hasil di rapihin , DataPenjualRealtimeStateChange");
            print(toStringItem);

            // emit(DataPenjualRealtimeStateChange(
            //     items: penjualItemsFromJson(toStringItem)));

            List toMapItemSortingJarak = jsonDecode(toStringItem);
            toMapItemSortingJarak
                .sort((a, b) => a["jaraknya"].compareTo(b["jaraknya"]));
            print('toMapItemSortingJarak sesudah di sort ');
            print(toMapItemSortingJarak);

            String toStringItemSortingJarak = jsonEncode(toMapItemSortingJarak);

            emit(DataPenjualRealtimeStateChange(
                items: penjualItemsFromJson(toStringItemSortingJarak)));
          }
        }
      } else {
        print('cariLocalSubLocality tidak ditemukan');
        emit(DataPenjualRealtimeStateSubLocalityNull());
      }
    });

    on<DataPenjualRealtimeEventManualSubLocality>((event, emit) async {
      final cariLocalSubLocality =
          await sharedPreferencesService.cariLocalDataString('subLocality');
      if (cariLocalSubLocality!) {
        final getLocalSubLocality =
            await sharedPreferencesService.getLocalDataString('subLocality');
        print(
            'getLocalSubLocality di DataPenjualRealtimeEventManualSubLocality = ${getLocalSubLocality!['sub_locality']}');

        final getSemuaPenggunaPenjualBerdasarkanSubLocaltiy =
            await pocketbaseService
                .getSemuaPenggunaPenjualBerdasarkanSubLocaltiy(
                    getLocalSubLocality['sub_locality']);

        print("getSemuaPenggunaPenjualBerdasarkanSubLocaltiy ,");
        print(getSemuaPenggunaPenjualBerdasarkanSubLocaltiy);

        var data = getSemuaPenggunaPenjualBerdasarkanSubLocaltiy!['data'];
        if (data['totalItems'] == 0 &&
            getSemuaPenggunaPenjualBerdasarkanSubLocaltiy['data']['status'] ==
                'sukses') {
          emit(DataPenjualRealtimeStateResultListsNull());
        } else {
          // String toString =
          //     jsonEncode(getSemuaPenggunaPenjualBerdasarkanSubLocaltiy);

          // emit(DataPenjualRealtimeStateChange(
          //     resultList: penjualResultListFromJson(toString)));

          var items = data['items'];
          var array = [];
          for (var i = 0; i < data['totalItems']; i++) {
            if (items[i]['id'] == true) {
              array.add(items[i]);
            }
          }

          String toString = jsonEncode(array);
          print("Hasil di rapihin , DataPenjualRealtimeStateChange");
          print(toString);

          emit(DataPenjualRealtimeStateChange(
              items: penjualItemsFromJson(toString)));
        }
      } else {
        print('cariLocalSubLocality tidak ditemukan');
        emit(DataPenjualRealtimeStateSubLocalityNull());
      }
    });

    String recordItemsNewest = "";
    on<DataPenjualRealtimeEventMarkerClicked>((event, emit) async {
      String idPenggunaPenjual = event.id;
      print('Marker diklik (id = ${idPenggunaPenjual})');

      String oldItemsJSONString = penjualItemsToJson(state.items!);

      var oldtemsJSONMap = jsonDecode(oldItemsJSONString);
      print('oldtemsJSONMap , ');
      print(oldtemsJSONMap);

      var arrayNew;

      arrayNew = oldtemsJSONMap;
      arrayNew.forEach((item) {
        if (item['id'] == idPenggunaPenjual) {
          // item['id'] = objJsonMap['record']['id'];
          // item['created'] = item['record']['created'];
          // item['updated'] = item['record']['updated'];
          // item['collectionId'] = item['record']['collectionId'];
          // item['collectionName'] = item['record']['collectionName'];
          // item['expand'] = item['record']['expand'];
          // item['alamat_keliling'] = item['record']['alamat_keliling'];
          // item['alamat_tetap'] = item['record']['alamat_tetap'];
          // item['email'] = item['record']['email'];
          // item['emailVisibility'] = item['record']['emailVisibility'];
          // item['id_socket'] = item['record']['id_socket'];
          // item['is_online'] = item['record']['is_online'];
          // item['nama_dagang'] = item['record']['nama_dagang'];
          // item['nama_penjual'] = item['record']['nama_penjual'];
          // item['online_details'] = item['record']['online_details'];
          // item['sub_locality'] = item['record']['sub_locality'];
          // item['tipe_penjual'] = item['record']['tipe_penjual'];
          // item['username'] = item['record']['username'];
          // item['verified'] = item['record']['verified'];
          // item['jaraknya'] = item['record']['jaraknya'];
          item['is_marker_clicked'] = true;
        } else {
          item['is_marker_clicked'] = false;
        }
      });

      recordItemsNewest = jsonEncode(arrayNew);
      // print('Hasil di update setelah klik marker , ');
      // print(recordItemsNewest);

      emit(DataPenjualRealtimeStateChange(
          items: penjualItemsFromJson(recordItemsNewest)));
    });

    on<DataPenjualRealtimeEventMarkerNotClicked>((event, emit) async {
      String oldItemsJSONString = penjualItemsToJson(state.items!);

      var oldtemsJSONMap = jsonDecode(oldItemsJSONString);
      // print('oldtemsJSONMap , ');
      // print(oldtemsJSONMap);

      var arrayNew;

      arrayNew = oldtemsJSONMap;
      arrayNew.forEach((item) {
        item['is_marker_clicked'] = false;
      });

      recordItemsNewest = jsonEncode(arrayNew);
      // print('Hasil di update setelah klik marker , ');
      // print(recordItemsNewest);

      emit(DataPenjualRealtimeStateChange(
          items: penjualItemsFromJson(recordItemsNewest)));
    });

    pb.collection('pengguna_penjual').subscribe('*', (e) async {
      LocationService locationService = LocationService();

      final serviceLocationAndroid = await locationService.checkService();
      // print(
      //     'serviceLocationAndroid = $serviceLocationAndroid');

      final permissionLocationApp = await locationService.checkPermissions();
      // print(
      //     'permissionLocationApp = $permissionLocationApp');

      bool isDapatHitungJarak = false;
      if (serviceLocationAndroid == true &&
          permissionLocationApp == PermissionStatus.granted) {
        print('Jarak mulai dihitung');

        isDapatHitungJarak = true;
      }

      // print('pengguna_penjual realtime , ');
      // print(e.record);

      var objList = e;

      // Ubah list ke JSON string
      var objJsonString = jsonEncode(objList);
      print("objJsonString");
      print(objJsonString);

      // Decode ke Map
      var objJsonMap = jsonDecode(objJsonString);
      print("objJsonMap");
      print(objJsonMap);

      String oldItemsJSONString = penjualItemsToJson(state.items!);

      var oldtemsJSONMap = jsonDecode(oldItemsJSONString);
      print('oldtemsJSONMap , ');
      print(oldtemsJSONMap);

      var arrayNew;
      if (objJsonMap['action'] == 'update') {
        print("update realtime pengguna_penjual");

        arrayNew = oldtemsJSONMap;

        String? subLocalityYangDipakai;
        if (isModeJelajah!) {
          subLocalityYangDipakai = subLocalityJelajah;
        } else {
          final getLocalSubLocality =
              await sharedPreferencesService.getLocalDataString('subLocality');
          subLocalityYangDipakai = getLocalSubLocality!['sub_locality'];
        }

        // final getLocalSubLocality =
        //     await sharedPreferencesService.getLocalDataString('subLocality');

        if (objJsonMap['record']['sub_locality'] != subLocalityYangDipakai) {
          arrayNew
              .removeWhere((item) => item['id'] == objJsonMap['record']['id']);

          String toStringItem = jsonEncode(arrayNew);
          // print("Hasil di rapihin , DataPenjualRealtimeStateChange");
          // print(toStringItem);

          List toMapItemSortingJarak = jsonDecode(toStringItem);
          toMapItemSortingJarak
              .sort((a, b) => a["jaraknya"].compareTo(b["jaraknya"]));
          // print('toMapItemSortingJarak sesudah di sort ');
          // print(toMapItemSortingJarak);

          String toStringItemSortingJarak = jsonEncode(toMapItemSortingJarak);

          emit(DataPenjualRealtimeStateChange(
              items: penjualItemsFromJson(toStringItemSortingJarak)));

          if (arrayNew.length == 0) {
            emit(DataPenjualRealtimeStateResultListsNull());
          } else {
            emit(DataPenjualRealtimeStateChange(
                items: penjualItemsFromJson(toStringItemSortingJarak)));
          }
        } else {
          bool isSudahUpdateDataLama = false;

          // Update data lama
          await arrayNew.forEach((item) async {
            if (item['id'] == objJsonMap['record']['id']) {
              isSudahUpdateDataLama = true;

              double? jaraknya;
              if (isDapatHitungJarak) {
                final getLocation = await locationService.getLocation();
                print("getLocation ${getLocation}");

                double latitude = getLocation.latitude!;
                double longitude = getLocation.longitude!;
                print('Koordinat saya $latitude,$longitude');

                double latitudeToko, longitudeToko;
                if (objJsonMap['record']['tipe_penjual'][0] == "Tetap") {
                  latitudeToko =
                      objJsonMap['record']['alamat_tetap']['latitude'];
                  longitudeToko =
                      objJsonMap['record']['alamat_tetap']['longitude'];
                } else {
                  latitudeToko =
                      objJsonMap['record']['alamat_keliling']['latitude'];
                  longitudeToko =
                      objJsonMap['record']['alamat_keliling']['longitude'];
                }
                // double latitudeToko =
                //     objJsonMap['record']['alamat_tetap']['latitude'];
                // double longitudeToko =
                //     objJsonMap['record']['alamat_tetap']['longitude'];
                print('Koordinat Toko Tetap $latitudeToko,$longitudeToko');

                CalculateDistance calculateDistance = CalculateDistance();

                jaraknya = calculateDistance.distance(
                    latitude, longitude, latitudeToko, longitudeToko);
                print('jaraknya = $jaraknya');
              }

              // item['id'] = objJsonMap['record']['id'];
              item['is_log_out'] = objJsonMap['record']['is_log_out'];
              item['created'] = objJsonMap['record']['created'];
              item['updated'] = objJsonMap['record']['updated'];
              item['collectionId'] = objJsonMap['record']['collectionId'];
              item['collectionName'] = objJsonMap['record']['collectionName'];
              item['expand'] = objJsonMap['record']['expand'];
              item['alamat_keliling'] = objJsonMap['record']['alamat_keliling'];
              item['alamat_tetap'] = objJsonMap['record']['alamat_tetap'];
              item['email'] = objJsonMap['record']['email'];
              item['emailVisibility'] = objJsonMap['record']['emailVisibility'];
              item['id_socket'] = objJsonMap['record']['id_socket'];
              item['is_online'] = objJsonMap['record']['is_online'];
              item['nama_dagang'] = objJsonMap['record']['nama_dagang'];
              item['nama_penjual'] = objJsonMap['record']['nama_penjual'];
              item['online_details'] = objJsonMap['record']['online_details'];
              item['sub_locality'] = objJsonMap['record']['sub_locality'];
              item['tipe_penjual'] = objJsonMap['record']['tipe_penjual'];
              item['username'] = objJsonMap['record']['username'];
              item['verified'] = objJsonMap['record']['verified'];
              item['jaraknya'] = jaraknya;
              item['is_marker_clicked'] = item['is_marker_clicked'];
              item['token_fcm'] = objJsonMap['record']['token_fcm'];

              // recordItemsNewest = jsonEncode(arrayNew);
              // print('recordItemsNewest , ');
              // print(recordItemsNewest);

              // print("arrayNew.length");
              // print(arrayNew.length);

              // if (arrayNew.length == 0) {
              //   emit(DataPenjualRealtimeStateResultListsNull());
              // } else {
              //   emit(DataPenjualRealtimeStateChange(
              //       items: penjualItemsFromJson(recordItemsNewest)));
              // }

              String toStringItem = jsonEncode(arrayNew);
              print("Hasil di rapihin , DataPenjualRealtimeStateChange");
              print(toStringItem);

              List toMapItemSortingJarak = jsonDecode(toStringItem);
              toMapItemSortingJarak
                  .sort((a, b) => a["jaraknya"].compareTo(b["jaraknya"]));
              print('toMapItemSortingJarak sesudah di sort ');
              print(toMapItemSortingJarak);

              String toStringItemSortingJarak =
                  jsonEncode(toMapItemSortingJarak);

              emit(DataPenjualRealtimeStateChange(
                  items: penjualItemsFromJson(toStringItemSortingJarak)));

              if (arrayNew.length == 0) {
                emit(DataPenjualRealtimeStateResultListsNull());
              } else {
                emit(DataPenjualRealtimeStateChange(
                    items: penjualItemsFromJson(toStringItemSortingJarak)));
              }
            }
          });

          if (isSudahUpdateDataLama == false) {
            // MENGHANDLE JIKA PENJUAL ADA YANG LOGIN KETIKA PEMBELI MEMAKAI APP
            final getLocalAuthStoreData = await sharedPreferencesService
                .getLocalDataString('authStoreData');
            print("getLocalAuthStoreData , ");
            print(getLocalAuthStoreData);

            var toString = jsonEncode(getLocalAuthStoreData);
            var toMap = jsonDecode(toString);

            var modelAuthStore = toMap['model'];
            var idSaya = modelAuthStore['id'];

            if (objJsonMap['record']['id'] != idSaya) {
              double? jaraknya;
              if (isDapatHitungJarak) {
                final getLocation = await locationService.getLocation();
                print("getLocation ${getLocation}");

                double latitude = getLocation.latitude!;
                double longitude = getLocation.longitude!;
                print('Koordinat saya $latitude,$longitude');

                double latitudeToko, longitudeToko;
                if (objJsonMap['record']['tipe_penjual'][0] == "Tetap") {
                  latitudeToko =
                      objJsonMap['record']['alamat_tetap']['latitude'];
                  longitudeToko =
                      objJsonMap['record']['alamat_tetap']['longitude'];
                } else {
                  latitudeToko =
                      objJsonMap['record']['alamat_keliling']['latitude'];
                  longitudeToko =
                      objJsonMap['record']['alamat_keliling']['longitude'];
                }
                print('Koordinat Toko Tetap $latitudeToko,$longitudeToko');

                CalculateDistance calculateDistance = CalculateDistance();

                jaraknya = calculateDistance.distance(
                    latitude, longitude, latitudeToko, longitudeToko);
                print('jaraknya = $jaraknya');
              }

              var obj = {
                "id": objJsonMap['record']['id'],
                "is_log_out": objJsonMap['record']['is_log_out'],
                "created": objJsonMap['record']['created'],
                "updated": objJsonMap['record']['updated'],
                "collectionId": objJsonMap['record']['collectionId'],
                "collectionName": objJsonMap['record']['collectionName'],
                "expand": objJsonMap['record']['expand'],
                "alamat_keliling": objJsonMap['record']['alamat_keliling'],
                "alamat_tetap": objJsonMap['record']['alamat_tetap'],
                "email": objJsonMap['record']['email'],
                "emailVisibility": objJsonMap['record']['emailVisibility'],
                "id_socket": objJsonMap['record']['id_socket'],
                "is_online": objJsonMap['record']['is_online'],
                "nama_dagang": objJsonMap['record']['nama_dagang'],
                "nama_penjual": objJsonMap['record']['nama_penjual'],
                "online_details": objJsonMap['record']['online_details'],
                "sub_locality": objJsonMap['record']['sub_locality'],
                "tipe_penjual": objJsonMap['record']['tipe_penjual'],
                "username": objJsonMap['record']['username'],
                "verified": objJsonMap['record']['verified'],
                "jaraknya": jaraknya,
                "is_marker_clicked": false,
                "token_fcm": objJsonMap['record']['token_fcm'],
              };

              arrayNew.add(obj);

              String toStringItem = jsonEncode(arrayNew);
              print("Hasil di rapihin , DataPenjualRealtimeStateChange");
              print(toStringItem);

              List toMapItemSortingJarak = jsonDecode(toStringItem);
              toMapItemSortingJarak
                  .sort((a, b) => a["jaraknya"].compareTo(b["jaraknya"]));
              print('toMapItemSortingJarak sesudah di sort ');
              print(toMapItemSortingJarak);

              String toStringItemSortingJarak =
                  jsonEncode(toMapItemSortingJarak);

              if (arrayNew.length == 0) {
                emit(DataPenjualRealtimeStateResultListsNull());
              } else {
                emit(DataPenjualRealtimeStateChange(
                    items: penjualItemsFromJson(toStringItemSortingJarak)));
              }
            }
          }
        }
      } else if (objJsonMap['action'] == 'create') {
        print("create realtime pengguna_penjual");

        // arrayNew = oldRecordItemsJSONMap;
        // arrayNew.forEach((item) {
        //   if (item['id'] == objJsonMap['record']['id']) {
        //     item['id'] = objJsonMap['record']['id'];
        //     item['created'] = objJsonMap['record']['created'];
        //     item['updated'] = objJsonMap['record']['updated'];
        //     item['collectionId'] = objJsonMap['record']['collectionId'];
        //     item['collectionName'] = objJsonMap['record']['collectionName'];
        //     item['expand'] = objJsonMap['record']['expand'];
        //     item['desc'] = objJsonMap['record']['desc'];
        //     item['judul'] = objJsonMap['record']['judul'];
        //   }
        // });

        // recordItemsNewest = jsonEncode(arrayNew);
      }

      // print("arrayNew.length");
      // print(arrayNew.length);

      // if (arrayNew.length == 0) {
      //   emit(DataPenjualRealtimeStateResultListsNull());
      // } else {
      //   emit(DataPenjualRealtimeStateChange(
      //       items: penjualItemsFromJson(recordItemsNewest)));
      // }
    });
  }
}
