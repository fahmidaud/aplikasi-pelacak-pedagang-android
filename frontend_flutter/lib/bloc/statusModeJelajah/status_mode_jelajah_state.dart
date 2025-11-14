part of 'status_mode_jelajah_bloc.dart';

@immutable
sealed class StatusModeJelajahState {}

final class StatusModeJelajahInitial extends StatusModeJelajahState {}

class StatusModeJelajahStateShare extends StatusModeJelajahState {
  final bool isModeJelajah;
  // final bool isShareNotifMode;
  // final bool isShareNotif;

  StatusModeJelajahStateShare(this.isModeJelajah);
}

class StatusModeJelajahStateShareStatusNotifPromosi
    extends StatusModeJelajahState {
  final bool isShareNotif;
  final String namaDagang;
  final String textPromosi;
  final String subLocality;

  StatusModeJelajahStateShareStatusNotifPromosi(
      this.isShareNotif, this.namaDagang, this.textPromosi, this.subLocality);
}
