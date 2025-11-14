import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  SharedPreferences? prefs;

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setLocalDataString(key, objData) async {
    await initSharedPreferences();
    // key                                                          awal mula set key
    // authStoreData                                                (lib\ui\pages\auth\child\gabung_email.dart)
    // subLocality                                                  (lib\ui\pages\bottom_nav.dart)
    // lokasiSayaTerkini(hanyaUntukPenjualKeliling&Pembeli/Anonim)  (lib\ui\pages\bottom_nav.dart)
    // statusPromosiDagangan(hanyaUntukPenjual)                     (lib\ui\pages\home\home.dart)
    // themeMode                                                    (lib\ui\pages\profile\profile.dart)

    var toString = jsonEncode(objData);
    // var toString = objData;

    final setString = await prefs!.setString(key, toString);

    print('setLocalDataString = ${setString}');
  }

  Future<bool?> cariLocalDataString(key) async {
    await initSharedPreferences();

    final bool? cariLocalDataString = await prefs!.containsKey(key);

    return cariLocalDataString;
  }

  Future<Map?> getLocalDataString(key) async {
    await initSharedPreferences();

    final String? getString = await prefs!.getString(key);

    var toMap = jsonDecode(getString!);

    return toMap;
  }

  Future<void> removeLocalDataString(key) async {
    await initSharedPreferences();

    await prefs!.remove(key);
  }
}
