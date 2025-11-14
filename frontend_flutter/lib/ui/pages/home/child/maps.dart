import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../bloc/bloc.dart';
import '../../../../models/penjual_items.dart';
import '../../../../services/geocoding.dart';
import '../../../../services/pocketbase.dart';
import '../../../../services/shared_preferences.dart';
import 'marker_with_tooltip.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key});

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  final MapController _mapController = MapController();

  double _latitudeMapCurrent = 0;
  double _longitudeMapCurrent = 0;
  // maksimal zoom 18
  double _zoomMapCurrent = 3.0;

  double _latitudeSayaCurrent = 0;
  double _longitudeSayaCurrent = 0;

  bool isDragMap = false;
  bool isModeJelajah = false;
  double latitudeJelajah = 0, longitudeJelajah = 0;
  bool onDragMapJelajah = false;

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

    void handleOnPointerDown() {
      isDragMap = true;
    }

    void handleOnTap() {
      setState(() {
        isDragMap = false;
        onDragMapJelajah = false;
      });

      context
          .read<DataPenjualRealtimeBloc>()
          .add(DataPenjualRealtimeEventMarkerNotClicked());
    }

    void handlePosisiJelajah(MapPosition mapPosition) {
      if (onDragMapJelajah == false) {
        setState(() {
          onDragMapJelajah = true;
        });

        context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
            isDragMapJelajah: true, subLocality: "", isModeJelajah: true));
      }

      var posisi = mapPosition.center;
      setState(() {
        latitudeJelajah = posisi!.latitude;
        longitudeJelajah = posisi!.longitude;
      });
    }

    SharedPreferencesService sharedPreferencesService =
        SharedPreferencesService();

    String? subLocalityJelajahTerkini;
    Future<void> updateListDataPenjualRealtimeSaatJelajah() async {
      context.read<DataPenjualRealtimeBloc>().add(
          DataPenjualRealtimeEventInitial(true, subLocalityJelajahTerkini!));

      pb.collection('pengguna_pembeli').unsubscribe('*');

      context.read<DataPembeliRealtimeBloc>().add(
          DataPembeliRealtimeEventInitial(true, subLocalityJelajahTerkini!));

      pb.collection('pengguna_pembeli').subscribe('*', (e) {
        context.read<DataPembeliRealtimeBloc>().add(
            DataPembeliRealtimeEventInitial(true, subLocalityJelajahTerkini!));
      });

      pb.collection('pengguna_anonim').unsubscribe('*');

      context.read<DataAnonimRealtimeBloc>().add(
          DataAnonimRealtimeEventInitial(true, subLocalityJelajahTerkini!));

      pb.collection('pengguna_anonim').subscribe('*', (e) {
        context.read<DataAnonimRealtimeBloc>().add(
            DataAnonimRealtimeEventInitial(true, subLocalityJelajahTerkini!));
      });
    }

    GeocodingService geocodingService = GeocodingService();

    Future<void> handleModeJelajah() async {
      if (onDragMapJelajah == true) {
        setState(() {
          onDragMapJelajah = false;
        });

        double selisihLatitude = (latitudeJelajah - _latitudeSayaCurrent).abs();

        if (!isModeJelajah) {
          // 0.000045332704598792759
          if (selisihLatitude > 0.000045332704598792759) {
            // isModeJelajah = true;
            setState(() {
              isModeJelajah = true;
            });

            context
                .read<StatusModeJelajahBloc>()
                .add(StatusModeJelajahEventSet(true));

            print("Masuk MODE JELAJAH pada selisih $selisihLatitude");

            final getPlace = await geocodingService.getPlace(
                latitudeJelajah, longitudeJelajah);

            context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
                isDragMapJelajah: false,
                subLocality: getPlace['subLocality'],
                isModeJelajah: true));
          } else {
            print(
                "BELUM MODE JELAJAH karena, selisihLatitude = $selisihLatitude ");

            context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
                isDragMapJelajah: false,
                subLocality: "",
                isModeJelajah: false));
          }
        } else {
          context
              .read<StatusModeJelajahBloc>()
              .add(StatusModeJelajahEventSet(true));

          final getPlace = await geocodingService.getPlace(
              latitudeJelajah, longitudeJelajah);

          context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
              isDragMapJelajah: false,
              subLocality: getPlace['subLocality'],
              // subLocality: subLocalityTerkini!,
              isModeJelajah: true));

          if (subLocalityJelajahTerkini == null) {
            subLocalityJelajahTerkini = getPlace['subLocality'];

            updateListDataPenjualRealtimeSaatJelajah();
          } else {
            if (subLocalityJelajahTerkini != getPlace['subLocality']) {
              subLocalityJelajahTerkini = getPlace['subLocality'];

              updateListDataPenjualRealtimeSaatJelajah();
            }
          }
        }
      } else {
        context.read<StatusSubLocalityBloc>().add(StatusSubLocalityEventSet(
            isDragMapJelajah: false, subLocality: "", isModeJelajah: false));
      }
    }

    List<Marker> buildMarkers(List<PenjualItems> markersData) {
      return markersData.map((data) {
        return Marker(
          // point: LatLng(-6.23300139192348, 107.07764769501497),
          point: data.tipePenjual[0] == 'Tetap'
              ? LatLng(data.alamatTetap.latitude, data.alamatTetap.longitude)
              : LatLng(
                  data.alamatKeliling.latitude, data.alamatKeliling.longitude),
          // width: 80,
          // height: 80,
          builder: (context) {
            if (data.isLogOut == false) {
              if (data.tipePenjual[0] == 'Tetap') {
                return MarkerWithTooltip(
                  child: Icon(
                    Icons.pin_drop,
                    color: data.isOnline == true ? Colors.green : Colors.red,
                    size: 30.0,
                  ),
                  tooltip: data.isOnline == true
                      ? data.namaDagang
                      : "${data.namaDagang} (Offline)",
                  onTap: () {
                    setState(() {
                      isDragMap = false;
                    });
                    print("MARKER DI KLIK..");

                    context
                        .read<DataPenjualRealtimeBloc>()
                        .add(DataPenjualRealtimeEventMarkerClicked(data.id));
                  },
                );
              } else {
                if (data.isOnline) {
                  return MarkerWithTooltip(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 30.0,
                    ),
                    tooltip: data.namaDagang,
                    onTap: () {
                      setState(() {
                        isDragMap = false;
                      });
                      print("MARKER DI KLIK..");

                      context
                          .read<DataPenjualRealtimeBloc>()
                          .add(DataPenjualRealtimeEventMarkerClicked(data.id));
                    },
                  );
                }
              }
            }

            return const SizedBox();
          },
        );
      }).toList();
    }

    return BlocConsumer<LokasikuRealtimeBloc, LokasikuRealtimeState>(
      listener: (context, state) {
        if (state is LokasikuRealtimeStateShare) {
          if (state.forceOffModeJelajah == true) {
            isModeJelajah = false;
            isDragMap = false;
          }

          if (isModeJelajah == false && state.isModeJelajah == false) {
            context
                .read<StatusModeJelajahBloc>()
                .add(StatusModeJelajahEventSet(false));

            double latitudenya = state.latitude;
            double longitudenya = state.longitude;

            setState(() {
              _latitudeSayaCurrent = latitudenya;
              _longitudeSayaCurrent = longitudenya;

              _mapController.move(LatLng(latitudenya, longitudenya), 18);
            });
          }
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
                onTap: (tapPosition, point) {
                  print('onTap | handleOnTap()');
                  handleOnTap();
                },
                onPositionChanged: (mapPosition, boolValue) {
                  if (isDragMap) {
                    print('onPositionChanged | handlePosisiJelajah()');
                    handlePosisiJelajah(mapPosition);
                  }
                },
                onPointerDown: (event, point) {
                  print('onPointerDown | handleOnPointerDown()');
                  handleOnPointerDown();
                },
                onPointerUp: (event, point) {
                  if (isDragMap && onDragMapJelajah) {
                    print('onPointerUp | handleModeJelajah()');
                    handleModeJelajah();
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  rotate: true,
                  markers: [
                    isModeJelajah
                        ? Marker(
                            point: LatLng(latitudeJelajah, longitudeJelajah),
                            width: 80,
                            height: 80,
                            builder: (ctx) => Container(
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.deepPurpleAccent,
                                size: 30.0,
                              ),
                            ),
                          )
                        : Marker(
                            point: state is LokasikuRealtimeStateShare
                                ? LatLng(state.latitude, state.longitude)
                                : LatLng(_latitudeSayaCurrent,
                                    _longitudeSayaCurrent),
                            width: 80,
                            height: 80,
                            builder: (ctx) => Container(
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.deepPurple,
                                size: 30.0,
                              ),
                            ),
                          ),
                  ],
                ),
                BlocBuilder<DataPenjualRealtimeBloc, DataPenjualRealtimeState>(
                  builder: (context, state) {
                    if (state is DataPenjualRealtimeStateResultListsNull) {
                      return const SizedBox();
                    }

                    if (state is DataPenjualRealtimeStateChange) {
                      return MarkerLayer(
                        rotate: true,
                        markers: buildMarkers(state.items!),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
