part of 'data_pembeli_realtime_bloc.dart';

@immutable
sealed class DataPembeliRealtimeState {}

final class DataPembeliRealtimeInitial extends DataPembeliRealtimeState {}

class DataPembeliRealtimeStateLoading extends DataPembeliRealtimeState {}

class DataPembeliRealtimeStateSubLocalityNull
    extends DataPembeliRealtimeState {}

class DataPembeliRealtimeStateResultListsNull
    extends DataPembeliRealtimeState {}

// class DataPembeliRealtimeStateChange extends DataPembeliRealtimeState {
//   DataPembeliRealtimeStateChange({required List<PenjualItems> items})
//       : super(items: items);
// }

class DataPembeliRealtimeStateJumlahCalonPembeli
    extends DataPembeliRealtimeState {
  final int? banyakCalonPembeli;

  DataPembeliRealtimeStateJumlahCalonPembeli([this.banyakCalonPembeli]);
}

class DataPembeliRealtimeStateError extends DataPembeliRealtimeState {
  final String? message;

  DataPembeliRealtimeStateError([this.message]);
}
