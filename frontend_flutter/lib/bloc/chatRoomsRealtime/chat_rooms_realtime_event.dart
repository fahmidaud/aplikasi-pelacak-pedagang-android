part of 'chat_rooms_realtime_bloc.dart';

@immutable
sealed class ChatRoomsRealtimeEvent {}

class ChatRoomsRealtimeEventGetByIdSaya extends ChatRoomsRealtimeEvent {}

// class ChatRoomsRealtimeEventUbahDataLama extends ChatRoomsRealtimeEvent {
//   final String objRealtime;

//   ChatRoomsRealtimeEventUbahDataLama(this.objRealtime);
// }
