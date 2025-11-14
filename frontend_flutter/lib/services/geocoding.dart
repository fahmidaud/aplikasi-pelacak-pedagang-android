import 'dart:convert';

import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<Map> getPlace(lat, long) async {
    // List<Placemark> newPlace =
    //     await placemarkFromCoordinates(-6.3994989045758155, 106.97497372571749, localeIdentifier: "en");

    // await Future.delayed(Duration(milliseconds: 2000));
    List<Placemark> newPlace =
        await placemarkFromCoordinates(lat, long, localeIdentifier: "en");

    // this is all you need
    Placemark placeMark = newPlace[0];
    String name = placeMark.name.toString();
    String subLocality = placeMark.subLocality.toString();
    String locality = placeMark.locality.toString();
    String administrativeArea = placeMark.administrativeArea.toString();
    String postalCode = placeMark.postalCode.toString();
    String country = placeMark.country.toString();
    // String address =
    //     "$name, $subLocality, $locality, $administrativeArea $postalCode, $country";

    // setState(() {
    //   _address = address; // update _address
    // });

    print('postalCode = $postalCode');

    var obj = {
      "name": name,
      "subLocality": subLocality,
      "locality": locality,
      "administrativeArea": administrativeArea,
      "postalCode": postalCode,
      "country": country
    };

    String convertToJSONString = jsonEncode(obj);
    var convertToJSONMap = jsonDecode(convertToJSONString);

    return convertToJSONMap;
  }
}
