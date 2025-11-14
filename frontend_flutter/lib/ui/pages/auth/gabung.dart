import 'package:aplikasi_yo/services/pocketbase.dart';
import 'package:flutter/material.dart';

import '../../../routes/router.dart';
import '../../../services/socket_client.dart';

class GabungPage extends StatefulWidget {
  const GabungPage({super.key});

  @override
  State<GabungPage> createState() => _GabungPageState();
}

class _GabungPageState extends State<GabungPage> {
  PocketbaseService pocketbaseService = PocketbaseService();
  SocketClientService socketClientService = SocketClientService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: const Column(
              children: [
                SizedBox(height: 17),
                Text(
                  "Selamat Datang",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Divider(height: 0),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.background,
                  child: ElevatedButton(
                    child: const Text(
                      'Gabung sekarang',
                    ),
                    onPressed: () async {
                      context.pushReplacementNamed(Routes.gabungViaEmailPage);
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.background,
                  child: TextButton(
                    child: const Text(
                      'Gabung nanti',
                    ),
                    onPressed: () => {
                      context.pushReplacementNamed(Routes.bottomNavigasiPage)
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
