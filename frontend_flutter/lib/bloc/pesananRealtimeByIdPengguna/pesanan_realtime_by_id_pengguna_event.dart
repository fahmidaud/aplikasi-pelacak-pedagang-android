part of 'pesanan_realtime_by_id_pengguna_bloc.dart';

@immutable
sealed class PesananRealtimeByIdPenggunaEvent {}

class PesananRealtimeByIdPenggunaEventGet
    extends PesananRealtimeByIdPenggunaEvent {
  final String collectionName, idPengguna;

  PesananRealtimeByIdPenggunaEventGet(this.collectionName, this.idPengguna);
}

class PesananRealtimeByIdPenggunaEventHandleUpdateDataLokal
    extends PesananRealtimeByIdPenggunaEvent {
  final String eventRealtimeString;

  PesananRealtimeByIdPenggunaEventHandleUpdateDataLokal(
      this.eventRealtimeString);
}
