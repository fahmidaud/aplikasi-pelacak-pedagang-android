import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'status_mode_jelajah_event.dart';
part 'status_mode_jelajah_state.dart';

class StatusModeJelajahBloc
    extends Bloc<StatusModeJelajahEvent, StatusModeJelajahState> {
  StatusModeJelajahBloc() : super(StatusModeJelajahInitial()) {
    on<StatusModeJelajahEventSet>((event, emit) {
      print("StatusModeJelajahEventSet BLOC SDG DIJALANKAN");

      bool isModeJelajah = event.isModeJelajah;
      // bool isShareNotifMode = event.isShareNotifMode;
      // bool isShareNotif = event.isShareNotif;

      emit(StatusModeJelajahStateShare(isModeJelajah));
    });

    on<StatusModeJelajahEventShareNotifMode>((event, emit) {
      print("StatusModeJelajahEventShareNotifMode BLOC SDG DIJALANKAN");

      bool isShareNotif = event.isShareNotif;
      String namaDagang = event.namaDagang;
      String textPromosi = event.textPromosi;
      String subLocality = event.subLocality;

      emit(StatusModeJelajahStateShareStatusNotifPromosi(
          isShareNotif, namaDagang, textPromosi, subLocality));
    });
  }
}
