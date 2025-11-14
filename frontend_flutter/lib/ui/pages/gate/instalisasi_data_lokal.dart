import 'package:flutter/material.dart';

import '../../../services/geocoding.dart';
import '../../../services/location.dart';
import '../../../services/geolocator.dart';
import '../../../services/shared_preferences.dart';

import '../../../routes/router.dart';

class InstalisasiDataLokal extends StatefulWidget {
  const InstalisasiDataLokal({super.key});

  @override
  State<InstalisasiDataLokal> createState() => _InstalisasiDataLokalState();
}

class _InstalisasiDataLokalState extends State<InstalisasiDataLokal> {
  String pesanProses = "Sedang instalisasi aplikasi..";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    antriPanggilSebelumHalamanLoad();
  }

  Future<void> antriPanggilSebelumHalamanLoad() async {
    setState(() {
      pesanProses = "Sedang instalisasi lokasi..";
    });
    await instalisasiLokasiSaya();

    setState(() {
      pesanProses = "Sedang instalisasi alamat..";
    });
    await instalisasiSubLocality();
  }

  LocationService locationService = LocationService();
  GeolocatorServices geolocatorServices = GeolocatorServices();
  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  double? latitude, longitude;
  Future<void> instalisasiLokasiSaya() async {
    final handleGetLastKnownPosition =
        await geolocatorServices.handleGetLastKnownPosition();

    if (handleGetLastKnownPosition != null) {
      latitude = handleGetLastKnownPosition.latitude;
      longitude = handleGetLastKnownPosition.longitude;
    }

    if (handleGetLastKnownPosition == null) {
      final getLocation = await locationService.getLocation();

      latitude = getLocation.latitude!;
      longitude = getLocation.longitude!;
    }

    var obj = {"latitude": latitude, "longitude": longitude};

    final cariLocallokasiSayaTerkini =
        await sharedPreferencesService.cariLocalDataString('lokasiSayaTerkini');
    if (cariLocallokasiSayaTerkini == false) {
      await sharedPreferencesService.setLocalDataString(
          'lokasiSayaTerkini', obj);
    } else {
      await sharedPreferencesService.removeLocalDataString('lokasiSayaTerkini');
      await sharedPreferencesService.setLocalDataString(
          'lokasiSayaTerkini', obj);
    }
  }

  GeocodingService geocodingService = GeocodingService();
  Future<void> instalisasiSubLocality() async {
    final getPlace = await geocodingService.getPlace(latitude, longitude);

    final cariLocalSubLocality =
        await sharedPreferencesService.cariLocalDataString('subLocality');

    var obj = {"sub_locality": getPlace['subLocality']};
    if (cariLocalSubLocality! == false) {
      await sharedPreferencesService.setLocalDataString('subLocality', obj);
    } else {
      await sharedPreferencesService.removeLocalDataString('subLocality');
      await sharedPreferencesService.setLocalDataString('subLocality', obj);
    }

    Future.delayed(Duration.zero, () {
      context.pushReplacementNamed(Routes.bottomNavigasiPage);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 24,
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(pesanProses),
          ],
        ),
      ),
    );
  }
}
