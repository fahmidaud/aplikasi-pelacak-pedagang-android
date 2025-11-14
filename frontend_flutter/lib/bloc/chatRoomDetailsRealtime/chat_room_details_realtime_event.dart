part of 'chat_room_details_realtime_bloc.dart';

@immutable
sealed class ChatRoomDetailsRealtimeEvent {}

class ChatRoomDetailsRealtimeEventGetByIdChatRoom
    extends ChatRoomDetailsRealtimeEvent {
  final String idChatRoom;

  ChatRoomDetailsRealtimeEventGetByIdChatRoom(this.idChatRoom);
}

class ChatRoomDetailsRealtimeEventHandleUpdateChatLokal
    extends ChatRoomDetailsRealtimeEvent {
  final String item;

  ChatRoomDetailsRealtimeEventHandleUpdateChatLokal(this.item);
}
