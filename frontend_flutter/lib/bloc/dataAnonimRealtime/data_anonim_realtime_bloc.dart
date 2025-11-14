import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../services/pocketbase.dart';
import '../../services/shared_preferences.dart';

part 'data_anonim_realtime_event.dart';
part 'data_anonim_realtime_state.dart';

class DataAnonimRealtimeBloc
    extends Bloc<DataAnonimRealtimeEvent, DataAnonimRealtimeState> {
  DataAnonimRealtimeBloc() : super(DataAnonimRealtimeInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();

    on<DataAnonimRealtimeEventInitial>((event, emit) async {
      bool isModeJelajah = event.isModeJelajah;

      final cariLocalSubLocality =
          await sharedPreferencesService.cariLocalDataString('subLocality');
      if (cariLocalSubLocality!) {
        var getSemuaPenggunaAnonimBerdasarkanSubLocaltiy;
        if (isModeJelajah) {
          String subLocalityJelajah = event.subLocalityJelajah;

          getSemuaPenggunaAnonimBerdasarkanSubLocaltiy = await pocketbaseService
              .getSemuaPenggunaAnonimBerdasarkanSubLocaltiy(subLocalityJelajah);
        } else {
          final getLocalSubLocality =
              await sharedPreferencesService.getLocalDataString('subLocality');
          print(
              'getLocalSubLocality di data_anonim_realtime_bloc = ${getLocalSubLocality!['sub_locality']}');

          getSemuaPenggunaAnonimBerdasarkanSubLocaltiy = await pocketbaseService
              .getSemuaPenggunaAnonimBerdasarkanSubLocaltiy(
                  getLocalSubLocality['sub_locality']);
        }

        // print("getSemuaPenggunaPembeliBerdasarkanSubLocaltiy ,");
        // print(getSemuaPenggunaPembeliBerdasarkanSubLocaltiy);

        var data = getSemuaPenggunaAnonimBerdasarkanSubLocaltiy!['data'];
        if (data['totalItems'] == 0 && data['status'] == 'sukses') {
          emit(DataAnonimRealtimeStateResultListsNull());
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

          emit(DataAnonimRealtimeStateJumlahCalonPembeli(totalItems));
        }
      } else {
        print('cariLocalSubLocality tidak ditemukan');
        emit(DataAnonimRealtimeStateSubLocalityNull());
      }
    });
  }
}
