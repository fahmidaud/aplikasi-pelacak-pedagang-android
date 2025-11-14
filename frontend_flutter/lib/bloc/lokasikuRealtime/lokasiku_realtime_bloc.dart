import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'lokasiku_realtime_event.dart';
part 'lokasiku_realtime_state.dart';

class LokasikuRealtimeBloc
    extends Bloc<LokasikuRealtimeEvent, LokasikuRealtimeState> {
  LokasikuRealtimeBloc() : super(LokasikuRealtimeInitial()) {
    on<LokasikuRealtimeEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<LokasikuRealtimeEventSet>((event, emit) {
      bool isModeJelajah = event.isModeJelajah;
      double latitudenya = event.latitude;
      double longitudenya = event.longitude;
      bool forceOffModeJelajah = event.forceOffModeJelajah;
      print('Latitude di bloc $latitudenya');
      print('longitude di bloc $longitudenya');

      emit(LokasikuRealtimeStateShare(
          isModeJelajah, latitudenya, longitudenya, forceOffModeJelajah));
    });
  }
}
