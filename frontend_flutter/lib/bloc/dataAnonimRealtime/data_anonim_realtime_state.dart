part of 'data_anonim_realtime_bloc.dart';

@immutable
sealed class DataAnonimRealtimeState {}

final class DataAnonimRealtimeInitial extends DataAnonimRealtimeState {}

class DataAnonimRealtimeStateLoading extends DataAnonimRealtimeState {}

class DataAnonimRealtimeStateSubLocalityNull extends DataAnonimRealtimeState {}

class DataAnonimRealtimeStateResultListsNull extends DataAnonimRealtimeState {}

// class DataPembeliRealtimeStateChange extends DataPembeliRealtimeState {
//   DataPembeliRealtimeStateChange({required List<PenjualItems> items})
//       : super(items: items);
// }

class DataAnonimRealtimeStateJumlahCalonPembeli
    extends DataAnonimRealtimeState {
  final int? banyakCalonPembeli;

  DataAnonimRealtimeStateJumlahCalonPembeli([this.banyakCalonPembeli]);
}

class DataAnonimRealtimeStateError extends DataAnonimRealtimeState {
  final String? message;

  DataAnonimRealtimeStateError([this.message]);
}
