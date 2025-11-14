import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/pages/auth/child/gabung_email.dart';
import '../ui/pages/auth/gabung.dart';
import '../ui/pages/bottom_nav.dart';
import '../ui/pages/chat/child/chat_details.dart';
import '../ui/pages/dibeli/child/lacak_penjual.dart';
import '../ui/pages/error/error.dart';
import '../ui/pages/gate/gate.dart';
import '../ui/pages/gate/instalisasi_data_lokal.dart';
import '../ui/pages/gate/periksa_perizinan.dart';
import '../ui/pages/profile/child/ubah_profile.dart';

export 'package:go_router/go_router.dart';

part 'route_name.dart';

final router = GoRouter(
  // initialLocation: '/gate',
  errorBuilder: (context, state) => const ErrorPage(),
  routes: [
    GoRoute(
      path: '/',
      name: Routes.gatePage,
      builder: (context, state) => GatePage(
        state.queryParameters,
      ),
      routes: [
        GoRoute(
          path: 'periksa-perizinan-gate',
          name: Routes.periksaPerizinanPage,
          builder: (context, state) => PeriksaPerizinanPage(),
        ),
        GoRoute(
          path: 'instalisasi-data-lokal-gate',
          name: Routes.instalisasiDataLokal,
          builder: (context, state) => InstalisasiDataLokal(),
        ),
      ],
    ),
    GoRoute(
      path: '/menu-utama',
      name: Routes.bottomNavigasiPage,
      builder: (context, state) {
        return BottomNavigasiPage();
      },
      routes: [
        GoRoute(
          path: 'gabung',
          name: Routes.gabungPage,
          builder: (context, state) => GabungPage(),
          routes: [
            GoRoute(
              path: 'gabung-via-email',
              name: Routes.gabungViaEmailPage,
              builder: (context, state) => GabungViaEmailPage(),
            ),
          ],
        ),
        GoRoute(
          path: 'chat-details',
          name: Routes.chatDetailsPage,
          builder: (context, state) => ChatDetailsPage(
            state.queryParameters,
            // state.extra as User,
          ),
        ),
        GoRoute(
          path: 'lacak-penjual',
          name: Routes.lacakPenjualPage,
          builder: (context, state) => LacakPenjualPage(
            state.queryParameters,
          ),
        ),
        GoRoute(
          path: 'ubah-profile',
          name: Routes.ubahProfilePage,
          builder: (context, state) => UbahProfilePage(
            state.queryParameters,
          ),
        ),
      ],
    ),
  ],
);
