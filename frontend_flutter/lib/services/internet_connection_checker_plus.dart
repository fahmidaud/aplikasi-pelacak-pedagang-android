import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetConnectionCheckerPlusService {
  Future<bool?> cekKoneksiInternet() async {
    bool hasInternetAccess = await InternetConnection().hasInternetAccess;
    // print('hasInternetAccess in service = $hasInternetAccess');

    return hasInternetAccess;
  }
}
