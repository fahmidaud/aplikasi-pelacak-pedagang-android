import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/chat_rooms.dart';
import '../../services/pocketbase.dart';
import '../../services/shared_preferences.dart';

part 'chat_rooms_realtime_event.dart';
part 'chat_rooms_realtime_state.dart';

class ChatRoomsRealtimeBloc
    extends Bloc<ChatRoomsRealtimeEvent, ChatRoomsRealtimeState> {
  ChatRoomsRealtimeBloc() : super(ChatRoomsRealtimeInitial()) {
    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();

    PocketbaseService pocketbaseService = PocketbaseService();

    // ChatRoomsRealtimeBloc chatRoomsBloc = ChatRoomsRealtimeBloc();
    // PocketbaseService pocketbaseService = PocketbaseService(chatRoomsBloc);

    on<ChatRoomsRealtimeEventGetByIdSaya>((event, emit) async {
      emit(ChatRoomsRealtimeStateLoading());

      final cariLocalDataStringAuthStore =
          await sharedPreferencesService.cariLocalDataString('authStoreData');
      // print(
      //     'cariLocalDataString "authStoreData" = $cariLocalDataStringAuthStore');

      if (cariLocalDataStringAuthStore!) {
        // JIKA SUDAH LOGIN
        final getLocalAuthStoreData =
            await sharedPreferencesService.getLocalDataString('authStoreData');
        print("getLocalAuthStoreData , ");
        print(getLocalAuthStoreData);

        var toString = jsonEncode(getLocalAuthStoreData);
        var toMap = jsonDecode(toString);

        var modelAuthStore = toMap['model'];
        var id = modelAuthStore['id'];
        var collectionName = modelAuthStore['collectionName'];

        final getChatRoomsByIdSaya =
            await pocketbaseService.getChatRoomsByIdSaya(collectionName, id);
        print('getChatRoomsByIdSaya DI BLOC , ${getChatRoomsByIdSaya}');
        // print(getChatRoomsByIdSaya);

        String toStringItem =
            jsonEncode(getChatRoomsByIdSaya!['data']['items']);

        emit(ChatRoomsRealtimeStateSukses(
            items: chatRoomsFromJson(toStringItem)));
      }
    });

    // on<ChatRoomsRealtimeEventUbahDataLama>((event, emit) async {
    //   var objChatRoomTerbaru = event.objRealtime;
    //   print('objChatRoomTerbaru di bloc ,');
    //   print(objChatRoomTerbaru);
    // });

    // WORKS TAPI GAK BISA SORTING BERDASARKAN PESAN TERBARU
    // String recordItemsNewest = "";
    // pb.collection('chat_rooms').subscribe('*', (e) {
    //   print("Data Realtime chat_rooms  di bloc, ");
    //   print(e);
    //   print(e.record);

    //   String oldItemsJSONString = chatRoomsToJson(state.items!);
    //   // print('oldItemsJSONString chat_rooms ,');
    //   // print(oldItemsJSONString);

    //   var oldItemsJSONMap = jsonDecode(oldItemsJSONString);
    //   // print('oldItemsJSONMap chat_rooms ,');
    //   // print(oldItemsJSONMap);
    //   // print("oldItemsJSONMap.length , ");
    //   // print(oldItemsJSONMap.length);

    //   if (oldItemsJSONMap.length != 0) {
    //     var objRealtime = e;

    //     // Ubah list ke JSON string
    //     var objRealtimeString = jsonEncode(objRealtime);
    //     print("objRealtimeString");
    //     print(objRealtimeString);

    //     // Decode ke Map
    //     var objRealtimeMap = jsonDecode(objRealtimeString);
    //     print("objRealtimeMap");
    //     print(objRealtimeMap);

    //     var arrayNew;
    //     if (objRealtimeMap['action'] == 'create') {
    //       print("create");

    //       arrayNew = oldItemsJSONMap;
    //       arrayNew.add(objRealtimeMap['record']);

    //       recordItemsNewest = jsonEncode(arrayNew);
    //     } else if (objRealtimeMap['action'] == 'update') {
    //       print("update");
    //
    //       arrayNew = oldItemsJSONMap;
    //       arrayNew.forEach((item) {
    //         if (item['id'] == objRealtimeMap['record']['id']) {
    //           item['collectionId'] = objRealtimeMap['record']['collectionId'];
    //           item['collectionName'] =
    //               objRealtimeMap['record']['collectionName'];
    //           item['created'] = objRealtimeMap['record']['created'];
    //           // item['expand'] = objRealtimeMap['record']['expand'];
    //           item['expand'] = item['expand'];
    //           item['id'] = objRealtimeMap['record']['id'];
    //           item['id_pembeli'] = objRealtimeMap['record']['id_pembeli'];
    //           item['id_penjual'] = objRealtimeMap['record']['id_penjual'];
    //           item['is_hapus_chat'] = objRealtimeMap['record']['is_hapus_chat'];
    //           item['is_read'] = objRealtimeMap['record']['is_read'];
    //           item['last_message'] = objRealtimeMap['record']['last_message'];
    //           item['updated'] = objRealtimeMap['record']['updated'];
    //         }
    //       });

    //       recordItemsNewest = jsonEncode(arrayNew);
    //     }

    //     if (arrayNew.length != 0) {
    //       emit(ChatRoomsRealtimeStateSukses(
    //           items: chatRoomsFromJson(recordItemsNewest)));
    //     }
    //   }
    // });
  }
}
