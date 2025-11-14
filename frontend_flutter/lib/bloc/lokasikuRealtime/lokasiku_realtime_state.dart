part of 'lokasiku_realtime_bloc.dart';

@immutable
sealed class LokasikuRealtimeState {}

final class LokasikuRealtimeInitial extends LokasikuRealtimeState {}

class LokasikuRealtimeStateShare extends LokasikuRealtimeState {
  // BestPracticeCrudStateError({required List<BestPracticeCrud> recordItems})
  //     : super(recordItems: recordItems);

  final bool isModeJelajah;
  final double latitude, longitude;
  final bool forceOffModeJelajah;
  // final bool isModeJelajah;

  // LokasikuRealtimeStateShare(this.latitude, this.longitude, this.isModeJelajah);
  LokasikuRealtimeStateShare(this.isModeJelajah, this.latitude, this.longitude,
      this.forceOffModeJelajah);
}
