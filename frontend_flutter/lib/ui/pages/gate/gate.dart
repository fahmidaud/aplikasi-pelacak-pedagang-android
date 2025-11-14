import 'package:flutter/material.dart';

import '../../../routes/router.dart';

class GatePage extends StatefulWidget {
  const GatePage(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> {
  bool isSudahDiperiksa = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ambil parameter "id" dari route
    final route = ModalRoute.of(context);
    if (route != null) {
      final settings = route.settings;
      final arguments = settings.arguments as Map<String, dynamic>;

      if (arguments.containsKey("is_sudah_diperiksa")) {
        String tampungParam = arguments["is_sudah_diperiksa"];
        print('is_sudah_diperiksa - tampungParam = ${tampungParam}');
        bool booleanValue = (tampungParam.toLowerCase() == "true");
        isSudahDiperiksa = booleanValue;
      }
    }
  }

  void cekStatusSudahDiperiksaParam() async {
    print('cekStatusSudahDiperiksaParam = ${isSudahDiperiksa}');
    if (isSudahDiperiksa == false) {
      Future.delayed(Duration.zero, () {
        context.pushReplacementNamed(Routes.periksaPerizinanPage);
      });
    } else {
      Future.delayed(Duration.zero, () {
        context.pushReplacementNamed(Routes.bottomNavigasiPage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // cekStatusSudahDiperiksaParam();
    Future.delayed(const Duration(milliseconds: 666), () {
      cekStatusSudahDiperiksaParam();
    });

    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }
}
