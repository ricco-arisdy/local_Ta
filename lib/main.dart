import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ta_project/services/SharedPreferences_service.dart';
import 'package:ta_project/views/home_page.dart';
import 'package:ta_project/views/lahan/lahan_page.dart';
import 'package:ta_project/views/laporan/laporan.dart';
import 'package:ta_project/views/login_page.dart';
import 'package:ta_project/views/panen/panen_page.dart';
import 'package:ta_project/views/perawatan/perawatan_page.dart';
import 'package:ta_project/views/register_page.dart';
import 'package:ta_project/viewsModels/laporan_view_models.dart';
import 'package:ta_project/viewsModels/login_view_models.dart';
import 'package:ta_project/viewsModels/panen_view_models.dart';
import 'package:ta_project/viewsModels/perawatan_view_model.dart';
import 'package:ta_project/viewsModels/register_view_models.dart';
import 'package:ta_project/viewsModels/lahan_view_models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => LahanViewModel()),
        ChangeNotifierProvider(create: (_) => PanenViewModel()),
        ChangeNotifierProvider(create: (_) => PerawatanViewModel()),
        ChangeNotifierProvider(create: (_) => LaporanViewModel()),
      ],
      child: MaterialApp(
        title: 'TA Project',
        debugShowCheckedModeBanner: false,
        home: const AuthChecker(),
        routes: {
          '/home': (context) => const HomePage(),
          '/lahan': (context) => const LahanPage(),
          '/panen': (context) => const PanenPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/perawatan': (context) => const PerawatanPage(),
          '/laporan': (context) => const LaporanPageWrapper(),
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferencesService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class LaporanPageWrapper extends StatelessWidget {
  const LaporanPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Reset laporan data setiap kali route dipanggil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final laporanVm = Provider.of<LaporanViewModel>(context, listen: false);
      laporanVm.resetLaporanData();
    });

    return const LaporanPage();
  }
}
