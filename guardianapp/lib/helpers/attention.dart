import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

bool canVibrate = true;

final Iterable<Duration> pauses = [
  const Duration(milliseconds: 100),
  const Duration(milliseconds: 500),
  const Duration(milliseconds: 500),
  const Duration(milliseconds: 500),
  const Duration(milliseconds: 500),
];

Future<void> vibrate() async {
  bool canVibrate = await Vibrate.canVibrate;
  if (canVibrate) {
    Vibrate.vibrateWithPauses(pauses);
  }
}

Future<void> ring() async {
  FlutterRingtonePlayer().play(
    fromAsset: "assets/mixkit_battleship.mp3",
    asAlarm: true,
  );
}
