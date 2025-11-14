import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../bloc/bloc.dart';
import '../../../../services/pocketbase.dart';

class LacakPenjualPage extends StatefulWidget {
  const LacakPenjualPage(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<LacakPenjualPage> createState() => _LacakPenjualPageState();
}

class _LacakPenjualPageState extends State<LacakPenjualPage> {
  final MapController _mapController = MapController();

  String idPenjual = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil parameter "id" dari route
    final route = ModalRoute.of(context);
    if (route != null) {
      final settings = route.settings;
      final arguments = settings.arguments as Map<String, dynamic>;

      if (arguments.containsKey("id_penjual")) {
        idPenjual = arguments["id_penjual"];

        context.read<LacakPosisiPenjualRealtimeBloc>().add(
            LacakPosisiPenjualRealtimeEventGetLacakLokasiPenjual(idPenjual));

        aktifkanRealtimeLacakLokasiPenjual();
      }
    }
  }

  void aktifkanRealtimeLacakLokasiPenjual() {
    pb.collection('pengguna_penjual').subscribe(idPenjual, (e) {
      print('aktifkanRealtimeLacakLokasiPenjual , ');
      print(e.record);

      var toString = jsonEncode(e.record);
      context.read<LacakPosisiPenjualRealtimeBloc>().add(
          LacakPosisiPenjualRealtimeEventPerbaruiLacakLokasiPenjual(toString));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    pb.collection('pengguna_penjual').unsubscribe(idPenjual);

    super.dispose();
  }

  double _latitudeMapCurrent = 0;
  double _longitudeMapCurrent = 0;
  // maksimal zoom 18
  double _zoomMapCurrent = 3.0;

  double _latitudeSayaCurrent = 0;
  double _longitudeSayaCurrent = 0;

  @override
  Widget build(BuildContext context) {
    double _latitudeDefault = -0.23986689554732235;
    double _longitudeDefault = 117.74234774337216;
    double _zoomMapDefault = 3.2;

    _latitudeMapCurrent = _latitudeDefault;
    _longitudeMapCurrent = _longitudeDefault;
    _zoomMapCurrent = _zoomMapDefault;

    _latitudeSayaCurrent = _latitudeDefault;
    _longitudeSayaCurrent = _longitudeDefault;

    return Scaffold(
      appBar: AppBar(
        title: Text("Lacak penjual"),
      ),
      // body: BlocBuilder<LacakPosisiPenjualRealtimeBloc,
      //     LacakPosisiPenjualRealtimeState>(
      //   builder: (context, state) {
      //     if (state is LacakPosisiPenjualRealtimeStateSukses) {
      //       return Column(
      //         children: [
      //           Text(
      //               '${state.latitude.toString()} , ${state.longitude.toString()}')
      //         ],
      //       );
      //     }

      //     return SizedBox();
      //   },
      // ),

      body: BlocConsumer<LokasikuRealtimeBloc, LokasikuRealtimeState>(
        listener: (context, state) {
          if (state is LokasikuRealtimeStateShare) {
            print(
                'Menerima LokasikuRealtimeStateShare berupa latitude ${state.latitude}');

            double latitudenya = state.latitude;
            double longitudenya = state.longitude;
            print("latitude dari bloc $latitudenya");

            setState(() {
              _latitudeSayaCurrent = latitudenya;
              _longitudeSayaCurrent = longitudenya;

              _mapController.move(LatLng(latitudenya, longitudenya), 18);
            });
          }
        },
        builder: (context, state) {
          return Container(
            child: Center(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(_latitudeMapCurrent, _longitudeMapCurrent),
                  zoom: _zoomMapCurrent,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    rotate: true,
                    markers: [
                      Marker(
                        point: state is LokasikuRealtimeStateShare
                            ? LatLng(state.latitude, state.longitude)
                            : LatLng(
                                _latitudeSayaCurrent, _longitudeSayaCurrent),
                        width: 80,
                        height: 80,
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.person_pin_circle,
                            // color: isModeJelajah ? Colors.red : Colors.green,
                            color: Colors.deepPurple,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<LacakPosisiPenjualRealtimeBloc,
                      LacakPosisiPenjualRealtimeState>(
                    builder: (context, state) {
                      if (state is LacakPosisiPenjualRealtimeStateSukses) {
                        return MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(state.latitude, state.longitude),
                              width: 80,
                              height: 80,
                              builder: (ctx) => Container(
                                child: Icon(
                                  Icons.location_on,
                                  // color: isModeJelajah ? Colors.red : Colors.green,
                                  color: state.isLogOut == true ||
                                          state.isOnline == false
                                      ? Colors.red
                                      : Colors.green,
                                  size: 30.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
