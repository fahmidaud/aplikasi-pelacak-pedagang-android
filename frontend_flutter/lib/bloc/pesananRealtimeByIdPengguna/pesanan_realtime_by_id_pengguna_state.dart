part of 'pesanan_realtime_by_id_pengguna_bloc.dart';

@immutable
sealed class PesananRealtimeByIdPenggunaState {
  List<PesananItems>? items;

  PesananRealtimeByIdPenggunaState({this.items});
}

final class PesananRealtimeByIdPenggunaInitial
    extends PesananRealtimeByIdPenggunaState {}

class PesananRealtimeByIdPenggunaStateLoading
    extends PesananRealtimeByIdPenggunaState {}

class PesananRealtimeByIdPenggunaStateSukses
    extends PesananRealtimeByIdPenggunaState {
  PesananRealtimeByIdPenggunaStateSukses({required List<PesananItems> items})
      : super(items: items);
}

class PesananRealtimeByIdPenggunaStateError
    extends PesananRealtimeByIdPenggunaState {
  // BestPracticeCrudStateError({required List<BestPracticeCrud> recordItems})
  //     : super(recordItems: recordItems);

  final String? message;

  PesananRealtimeByIdPenggunaStateError([this.message]);
}
