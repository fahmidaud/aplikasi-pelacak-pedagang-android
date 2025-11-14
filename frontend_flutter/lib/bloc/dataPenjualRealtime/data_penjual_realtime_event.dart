part of 'data_penjual_realtime_bloc.dart';

// @immutable
sealed class DataPenjualRealtimeEvent {}

class DataPenjualRealtimeEventInitial extends DataPenjualRealtimeEvent {
  final bool isModeJelajah;
  final String subLocalityJelajah;

  DataPenjualRealtimeEventInitial(this.isModeJelajah, this.subLocalityJelajah);
}

class DataPenjualRealtimeEventManualSubLocality
    extends DataPenjualRealtimeEvent {}

class DataPenjualRealtimeEventMarkerClicked extends DataPenjualRealtimeEvent {
  final String id;

  DataPenjualRealtimeEventMarkerClicked(this.id);
}

class DataPenjualRealtimeEventMarkerNotClicked
    extends DataPenjualRealtimeEvent {}
