import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../services/pocketbase.dart';
import '../../services/shared_preferences.dart';

part 'data_pembeli_realtime_event.dart';
part 'data_pembeli_realtime_state.dart';

class DataPembeliRealtimeBloc
    extends Bloc<DataPembeliRealtimeEvent, DataPembeliRealtimeState> {
  DataPembeliRealtimeBloc() : super(DataPembeliRealtimeInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();

    on<DataPembeliRealtimeEventInitial>((event, emit) async {
      bool isModeJelajah = event.isModeJelajah;

      final cariLocalSubLocality =
          await sharedPreferencesService.cariLocalDataString('subLocality');
      if (cariLocalSubLocality!) {
        var getSemuaPenggunaPembeliBerdasarkanSubLocaltiy;
        if (isModeJelajah) {
          String subLocalityJelajah = event.subLocalityJelajah;

          getSemuaPenggunaPembeliBerdasarkanSubLocaltiy =
              await pocketbaseService
                  .getSemuaPenggunaPembeliBerdasarkanSubLocaltiy(
                      subLocalityJelajah);
        } else {
          final getLocalSubLocality =
              await sharedPreferencesService.getLocalDataString('subLocality');
          print(
              'getLocalSubLocality di data_pembeli_realtime_bloc = ${getLocalSubLocality!['sub_locality']}');

          getSemuaPenggunaPembeliBerdasarkanSubLocaltiy =
              await pocketbaseService
                  .getSemuaPenggunaPembeliBerdasarkanSubLocaltiy(
                      getLocalSubLocality['sub_locality']);
        }

        // print("getSemuaPenggunaPembeliBerdasarkanSubLocaltiy ,");
        // print(getSemuaPenggunaPembeliBerdasarkanSubLocaltiy);

        var data = getSemuaPenggunaPembeliBerdasarkanSubLocaltiy!['data'];
        if (data['totalItems'] == 0 && data['status'] == 'sukses') {
          emit(DataPembeliRealtimeStateResultListsNull());
        } else {
          // var items = data['items'];
          // print('items , ');
          // print(items);
          // var array = [];

          // final cariLocalDataStringAuthStore = await sharedPreferencesService
          //     .cariLocalDataString('authStoreData');
          // // print(
          // //     'cariLocalDataString "authStoreData" = $cariLocalDataStringAuthStore');

          // for (var i = 0; i < data['totalItems']; i++) {
          //   array.add(items[i]);
          // }
          // print("Pembeli item , ");
          // print(array);

          // // emit(DataPenjualRealtimeStateChange(
          // //     items: penjualItemsFromJson(toStringItem)));

          var totalItems = data['totalItems'];

          emit(DataPembeliRealtimeStateJumlahCalonPembeli(totalItems));
        }
      } else {
        print('cariLocalSubLocality tidak ditemukan');
        emit(DataPembeliRealtimeStateSubLocalityNull());
      }
    });
  }
}
