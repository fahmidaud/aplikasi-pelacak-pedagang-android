part of 'lacak_posisi_penjual_realtime_bloc.dart';

@immutable
sealed class LacakPosisiPenjualRealtimeState {}

final class LacakPosisiPenjualRealtimeInitial
    extends LacakPosisiPenjualRealtimeState {}

class LacakPosisiPenjualRealtimeStateLoading
    extends LacakPosisiPenjualRealtimeState {}

class LacakPosisiPenjualRealtimeStateSukses
    extends LacakPosisiPenjualRealtimeState {
  final bool isLogOut, isOnline;
  final double latitude, longitude;

  LacakPosisiPenjualRealtimeStateSukses(
      this.isLogOut, this.isOnline, this.latitude, this.longitude);
}

class LacakPosisiPenjualRealtimeStateError
    extends LacakPosisiPenjualRealtimeState {
  final String? message;

  LacakPosisiPenjualRealtimeStateError([this.message]);
}
