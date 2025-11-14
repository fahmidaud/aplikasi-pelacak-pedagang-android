import 'package:url_launcher/url_launcher.dart';

class LaunchURLService {
  Future<void> launchURL(uri) async {
    // final url =
    //     "https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude";
    final Uri _url = Uri.parse(uri);

    if (await launchUrl(_url)) {
      print("Sedang membuka link ${uri}");
    } else {
      print("Tidak dapat membuka link ${uri}");
    }
  }
}
