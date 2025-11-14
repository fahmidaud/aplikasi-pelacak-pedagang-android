import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/pesanan_items.dart';
import '../../services/pocketbase.dart';

part 'pesanan_realtime_by_id_pengguna_event.dart';
part 'pesanan_realtime_by_id_pengguna_state.dart';

class PesananRealtimeByIdPenggunaBloc extends Bloc<
    PesananRealtimeByIdPenggunaEvent, PesananRealtimeByIdPenggunaState> {
  PesananRealtimeByIdPenggunaBloc()
      : super(PesananRealtimeByIdPenggunaInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();

    on<PesananRealtimeByIdPenggunaEventGet>((event, emit) async {
      emit(PesananRealtimeByIdPenggunaStateLoading());

      String collectionName = event.collectionName;
      String idPengguna = event.idPengguna;
      print(
          'getPesananByIdPengguna dengan collectionName = ${collectionName} & idPengguna = ${idPengguna}');

      final getPesananByIdPengguna = await pocketbaseService
          .getPesananByIdPengguna(collectionName, idPengguna);
      print('getPesananByIdPengguna di BLOC ,');
      print(getPesananByIdPengguna);

      var status = getPesananByIdPengguna!['status'];

      if (status == 'sukses') {
        var items = getPesananByIdPengguna['data']['items'];
        String itemsToString = jsonEncode(items);
        emit(PesananRealtimeByIdPenggunaStateSukses(
            items: pesananItemsFromJson(itemsToString)));
      }
    });

    String recordItemsNewest = "";
    on<PesananRealtimeByIdPenggunaEventHandleUpdateDataLokal>(
        (event, emit) async {
      String objRealtimeString = event.eventRealtimeString;
      var objRealtimeMap = jsonDecode(objRealtimeString);

      var actionTypeRealtime = objRealtimeMap['action'];
      var recordDataRealtime = objRealtimeMap['record'];

      String oldItemsJSONString = pesananItemsToJson(state.items!);
      var oldItemsJSONMap = jsonDecode(oldItemsJSONString);

      var arrayNew;
      if (actionTypeRealtime == 'create') {
        print("create");

        arrayNew = oldItemsJSONMap;
        arrayNew.add(recordDataRealtime);

        recordItemsNewest = jsonEncode(arrayNew);
      } else if (actionTypeRealtime == 'update') {
        print("update");

        arrayNew = oldItemsJSONMap;
        arrayNew.forEach((item) {
          if (item['id'] == recordDataRealtime['id']) {
            item['id'] = item['id'];
            item['created'] = recordDataRealtime['created'];
            item['updated'] = recordDataRealtime['updated'];
            item['collectionId'] = recordDataRealtime['collectionId'];
            item['collectionName'] = recordDataRealtime['collectionName'];
            item['expand'] = item['expand'];
            item['alamat_tujuan'] = recordDataRealtime['alamat_tujuan'];
            item['id_pembeli'] = recordDataRealtime['id_pembeli'];
            item['id_penjual'] = recordDataRealtime['id_penjual'];
            item['is_batal'] = recordDataRealtime['is_batal'];
            item['is_sukses'] = recordDataRealtime['is_sukses'];
            item['is_terima'] = recordDataRealtime['is_terima'];
            item['timestamp_awal_pemesanan'] =
                recordDataRealtime['timestamp_awal_pemesanan'];
            item['timestamp_terima_pemesanan'] =
                recordDataRealtime['timestamp_terima_pemesanan'];
          }
        });

        recordItemsNewest = jsonEncode(arrayNew);
      } else if (actionTypeRealtime == 'delete') {
        print(
            'Bloc Pesanan Realtime, Kondisi `DELETE` dg record = ${recordDataRealtime}');

        arrayNew = oldItemsJSONMap;
        arrayNew.removeWhere((item) => item['id'] == recordDataRealtime['id']);
        // print(arrayNew);

        recordItemsNewest = jsonEncode(arrayNew);
      }

      emit(PesananRealtimeByIdPenggunaStateSukses(
          items: pesananItemsFromJson(recordItemsNewest)));
    });
  }
}
