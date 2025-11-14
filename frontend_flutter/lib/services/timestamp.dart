import 'package:intl/intl.dart';

class TimestampService {
  String ubahTimestampChat(timestamp) {
    DateTime messageTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedTime = DateFormat('dd/MM/yy - HH:mm').format(messageTime);

    return formattedTime;
  }

  int getTimestamp() {
    DateTime now = DateTime.now();
    int unixTimestamp = now.millisecondsSinceEpoch ~/ 1000;
    print(unixTimestamp);

    return unixTimestamp;
  }

  int selisihWaktuTimestamp(int timestampAwal) {
    int timestampSekarang = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    int selisihDetik = timestampSekarang - timestampAwal;
    int menit = selisihDetik ~/ 60;

    return menit;
  }
}
