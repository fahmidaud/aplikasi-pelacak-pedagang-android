part of 'lokasiku_realtime_bloc.dart';

@immutable
sealed class LokasikuRealtimeEvent {}

class LokasikuRealtimeEventSet extends LokasikuRealtimeEvent {
  final bool isModeJelajah;
  final double latitude, longitude;
  final bool forceOffModeJelajah;

  // LokasikuRealtimeEventSet(this.latitude, this.longitude, this.isModeJelajah);
  // LokasikuRealtimeEventSet(this.latitude, this.longitude);

  LokasikuRealtimeEventSet(
      {required this.isModeJelajah,
      required this.latitude,
      required this.longitude,
      required this.forceOffModeJelajah});
}
