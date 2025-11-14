part of 'data_penjual_realtime_bloc.dart';

// @immutable
sealed class DataPenjualRealtimeState {
  // List<PenjualResultList>? resultList;

  // DataPenjualRealtimeState({this.resultList});

  List<PenjualItems>? items;

  DataPenjualRealtimeState({this.items});
}

final class DataPenjualRealtimeInitial extends DataPenjualRealtimeState {}

class DataPenjualRealtimeStateLoading extends DataPenjualRealtimeState {}

class DataPenjualRealtimeStateSubLocalityNull
    extends DataPenjualRealtimeState {}

class DataPenjualRealtimeStateResultListsNull
    extends DataPenjualRealtimeState {}

// class DataPenjualRealtimeStateChange extends DataPenjualRealtimeState {
//   DataPenjualRealtimeStateChange({required List<PenjualResultList> resultList})
//       : super(resultList: resultList);
// }
class DataPenjualRealtimeStateChange extends DataPenjualRealtimeState {
  DataPenjualRealtimeStateChange({required List<PenjualItems> items})
      : super(items: items);
}

class DataPenjualRealtimeStateError extends DataPenjualRealtimeState {
  // BestPracticeCrudStateError({required List<BestPracticeCrud> recordItems})
  //     : super(recordItems: recordItems);

  final String? message;

  DataPenjualRealtimeStateError([this.message]);
}

// class DataPenjualRealtimeStateSubLocalityUnknown
//     extends DataPenjualRealtimeState {}
