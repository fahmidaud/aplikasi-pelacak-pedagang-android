part of 'chat_rooms_realtime_bloc.dart';

@immutable
sealed class ChatRoomsRealtimeState {
  List<ChatRooms>? items;

  ChatRoomsRealtimeState({this.items});
}

final class ChatRoomsRealtimeInitial extends ChatRoomsRealtimeState {}

class ChatRoomsRealtimeStateLoading extends ChatRoomsRealtimeState {}

class ChatRoomsRealtimeStateSukses extends ChatRoomsRealtimeState {
  ChatRoomsRealtimeStateSukses({required List<ChatRooms> items})
      : super(items: items);
}

class ChatRoomsRealtimeStateError extends ChatRoomsRealtimeState {
  // BestPracticeCrudStateError({required List<BestPracticeCrud> recordItems})
  //     : super(recordItems: recordItems);

  final String? message;

  ChatRoomsRealtimeStateError([this.message]);
}
