import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../services/pocketbase.dart';

part 'lacak_posisi_penjual_realtime_event.dart';
part 'lacak_posisi_penjual_realtime_state.dart';

class LacakPosisiPenjualRealtimeBloc extends Bloc<
    LacakPosisiPenjualRealtimeEvent, LacakPosisiPenjualRealtimeState> {
  LacakPosisiPenjualRealtimeBloc()
      : super(LacakPosisiPenjualRealtimeInitial()) {
    PocketbaseService pocketbaseService = PocketbaseService();

    on<LacakPosisiPenjualRealtimeEventGetLacakLokasiPenjual>(
        (event, emit) async {
      emit(LacakPosisiPenjualRealtimeStateLoading());

      String idPenjual = event.idPenjual;

      final getPenggunaPenjual =
          await pocketbaseService.getPenggunaPenjual(idPenjual);
      print("getPenggunaPenjual = ${getPenggunaPenjual}");
      // print(getPenggunaPenjual);

      var toString = jsonEncode(getPenggunaPenjual);
      var toMap = jsonDecode(toString);

      bool isLogOut = toMap['is_log_out'];
      bool isOnline = toMap['is_online'];
      double latitude = toMap['alamat_keliling']['latitude'];
      double longitude = toMap['alamat_keliling']['longitude'];
      print('latitude = ${latitude} , longitude = ${longitude}');

      emit(LacakPosisiPenjualRealtimeStateSukses(
          isLogOut, isOnline, latitude, longitude));
    });

    on<LacakPosisiPenjualRealtimeEventPerbaruiLacakLokasiPenjual>(
        (event, emit) async {
      var recordPenjualRealtimeString = event.recordPenjualRealtime;
      var toMap = jsonDecode(recordPenjualRealtimeString);

      bool isLogOut = toMap['is_log_out'];
      bool isOnline = toMap['is_online'];
      double latitudeTerbaru = toMap['alamat_keliling']['latitude'];
      double longitudeTerbaru = toMap['alamat_keliling']['longitude'];

      emit(LacakPosisiPenjualRealtimeStateSukses(
          isLogOut, isOnline, latitudeTerbaru, longitudeTerbaru));
    });
  }
}
