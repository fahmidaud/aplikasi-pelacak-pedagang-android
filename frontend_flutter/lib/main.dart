import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'routes/router.dart';
import 'services/firebase_messaging.dart';
import 'services/local_notification.dart';
import 'services/pocketbase.dart';
import 'services/shared_preferences.dart';

import 'bloc/bloc.dart';

FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print('Notifikasi Background ' + "${message.notification!.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await firebaseMessagingService.firebaseInit();

  // notif Background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await requestPermission();

  LocalNotification.initialize();

  runApp(const MyApp());
}

Future<void> requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PocketbaseService pocketbaseService = PocketbaseService();
  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // handleGetToken();

    handleNotifTerminated();

    // notifForeground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotification.createNotification(message);
      }
    });
  }

  void handleNotifTerminated() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      print("getInitialMessage = ${message.notification!.title}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeToggleBloc()),
        BlocProvider(create: (_) => LokasikuRealtimeBloc()),
        BlocProvider(create: (_) => StatusModeJelajahBloc()),
        BlocProvider(create: (_) => StatusSubLocalityBloc()),
        BlocProvider(create: (_) => DataPenjualRealtimeBloc()),
        BlocProvider(create: (_) => DataPembeliRealtimeBloc()),
        BlocProvider(create: (_) => DataAnonimRealtimeBloc()),
        BlocProvider(create: (_) => ChatRoomsRealtimeBloc()),
        BlocProvider(create: (_) => ChatRoomDetailsRealtimeBloc()),
        BlocProvider(create: (_) => PesananRealtimeByIdPenggunaBloc()),
        BlocProvider(create: (_) => LacakPosisiPenjualRealtimeBloc()),
      ],
      child: BlocBuilder<ThemeToggleBloc, ThemeToggleState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: state is ThemeToggleStateIsLight ? lightTheme : darkTheme,
            routerConfig: router,
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}

final lightTheme = ThemeData.light(useMaterial3: true);

final darkTheme = ThemeData.dark(useMaterial3: true);
