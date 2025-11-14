import 'dart:convert';

import 'package:http/http.dart' as http;

class HttpRequestService {
  Future<void> kirimNotifikasi(keyTo, title, body) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=YOUR_API_KEY'
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

