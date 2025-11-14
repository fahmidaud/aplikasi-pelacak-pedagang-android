import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpRequestService {
  Future<void> kirimNotifikasi(keyTo, title, body) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAK75R6wk:APA91bErgQXColWdpzaLbwo0xnN3Dx5BNEnU6cFpMJQNFXQgI-GPqLI-2i1Gk7ucPnFWS9MMgeN6Ke2taV-4OLt908we6z0sGH9N_oGjwf2PP76cUJN-q_NsSIIjIOymPj7s3kQkM4Gy'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": "${keyTo}",
      "mutable_content": true,
      "priority": "high",
      "notification": {"badge": 50, "title": "${title}", "body": "${body}"}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
