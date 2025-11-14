import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/chat_room_details.dart';
import '../../services/pocketbase.dart';

part 'chat_room_details_realtime_event.dart';
part 'chat_room_details_realtime_state.dart';

class ChatRoomDetailsRealtimeBloc
    extends Bloc<ChatRoomDetailsRealtimeEvent, ChatRoomDetailsRealtimeState> {
  ChatRoomDetailsRealtimeBloc() : super(ChatRoomDetailsRealtimeInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();

    on<ChatRoomDetailsRealtimeEventGetByIdChatRoom>((event, emit) async {
      emit(ChatRoomDetailsRealtimeStateLoading());
      var idChatRoom = event.idChatRoom;

      final getChatRoomDetailsByIdChatRoom =
          await pocketbaseService.getChatRoomDetailsByIdChatRoom(idChatRoom);
      print(
          'getChatRoomDetailsByIdChatRoom di BLOC = ${getChatRoomDetailsByIdChatRoom}');
      // print(getChatRoomDetailsByIdChatRoom);

      if (getChatRoomDetailsByIdChatRoom!['status'] == 'sukses') {
        var data = getChatRoomDetailsByIdChatRoom['data'];

        print('data dari getChatRoomDetailsByIdChatRoom = ${data}');
        // print(data);
        if (data['items'].length == 0) {
          emit(ChatRoomDetailsRealtimeStateChatKosong());
        } else {
          String itemsToString = jsonEncode(data['items']);

          emit(ChatRoomDetailsRealtimeStateSukses(
              items: chatRoomsDetailsFromJson(itemsToString)));
        }
      }
    });

    String recordItemsNewest = "";
    on<ChatRoomDetailsRealtimeEventHandleUpdateChatLokal>((event, emit) {
      // emit(ChatRoomDetailsRealtimeStateLoading());
      var itemChatRoomDetails = event.item;
      var itemChatRoomDetailsToMap = jsonDecode(itemChatRoomDetails);

      String oldItemsJSONString = chatRoomsDetailsToJson(state.items!);
      // print('oldItemsJSONString chat_rooms ,');
      // print(oldItemsJSONString);

      var oldItemsJSONMap = jsonDecode(oldItemsJSONString);

      var arrayNew = oldItemsJSONMap;
      arrayNew.add(itemChatRoomDetailsToMap);
      recordItemsNewest = jsonEncode(arrayNew);

      emit(ChatRoomDetailsRealtimeStateSukses(
          items: chatRoomsDetailsFromJson(recordItemsNewest)));
    });
  }
}
