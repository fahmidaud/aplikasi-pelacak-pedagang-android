part of 'chat_room_details_realtime_bloc.dart';

@immutable
sealed class ChatRoomDetailsRealtimeState {
  List<ChatRoomsDetails>? items;

  ChatRoomDetailsRealtimeState({this.items});
}

final class ChatRoomDetailsRealtimeInitial
    extends ChatRoomDetailsRealtimeState {}

class ChatRoomDetailsRealtimeStateLoading
    extends ChatRoomDetailsRealtimeState {}

class ChatRoomDetailsRealtimeStateChatKosong
    extends ChatRoomDetailsRealtimeState {}

class ChatRoomDetailsRealtimeStateSukses extends ChatRoomDetailsRealtimeState {
  ChatRoomDetailsRealtimeStateSukses({required List<ChatRoomsDetails> items})
      : super(items: items);
}

class ChatRoomDetailsRealtimeStateError extends ChatRoomDetailsRealtimeState {
  // BestPracticeCrudStateError({required List<BestPracticeCrud> recordItems})
  //     : super(recordItems: recordItems);

  final String? message;

  ChatRoomDetailsRealtimeStateError([this.message]);
}
