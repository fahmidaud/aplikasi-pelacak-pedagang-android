part of 'lacak_posisi_penjual_realtime_bloc.dart';

@immutable
sealed class LacakPosisiPenjualRealtimeEvent {}

class LacakPosisiPenjualRealtimeEventGetLacakLokasiPenjual
    extends LacakPosisiPenjualRealtimeEvent {
  final String idPenjual;

  LacakPosisiPenjualRealtimeEventGetLacakLokasiPenjual(this.idPenjual);
}

class LacakPosisiPenjualRealtimeEventPerbaruiLacakLokasiPenjual
    extends LacakPosisiPenjualRealtimeEvent {
  final String recordPenjualRealtime;

  LacakPosisiPenjualRealtimeEventPerbaruiLacakLokasiPenjual(
      this.recordPenjualRealtime);
}
