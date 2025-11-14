part of 'status_mode_jelajah_bloc.dart';

@immutable
sealed class StatusModeJelajahEvent {}

class StatusModeJelajahEventSet extends StatusModeJelajahEvent {
  final bool isModeJelajah;
  // final bool isShareNotifMode;
  // final bool isShareNotif;

  StatusModeJelajahEventSet(this.isModeJelajah);
}

class StatusModeJelajahEventShareNotifMode extends StatusModeJelajahEvent {
  final bool isShareNotif;
  final String namaDagang;
  final String textPromosi;
  final String subLocality;

  StatusModeJelajahEventShareNotifMode(
      this.isShareNotif, this.namaDagang, this.textPromosi, this.subLocality);
}
