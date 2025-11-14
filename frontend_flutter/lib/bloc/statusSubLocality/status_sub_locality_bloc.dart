import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'status_sub_locality_event.dart';
part 'status_sub_locality_state.dart';

class StatusSubLocalityBloc
    extends Bloc<StatusSubLocalityEvent, StatusSubLocalityState> {
  StatusSubLocalityBloc() : super(StatusSubLocalityInitial()) {
    on<StatusSubLocalityEventSet>((event, emit) {
      bool _isDragMapJelajah = event.isDragMapJelajah;
      String _subLocality = event.subLocality;
      print('_subLocality ${_subLocality} TELAH DITERIMA DI BLOC');

      bool _isModeJelajah = event.isModeJelajah;

      emit(StatusSubLocalityStateShare(
          _isDragMapJelajah, _subLocality, _isModeJelajah));
      // emit(StatusSubLocalityStateShare(
      //     subLocality: _subLocality, isModeJelajah: _isModeJelajah));
    });
  }
}
