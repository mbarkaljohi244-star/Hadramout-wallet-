import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/api_service.dart';
import 'src/screens/auth_screens.dart';
import 'src/screens/home_screen.dart';
import 'src/theme.dart';
import 'src/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HadramoutWalletApp());
}

class HadramoutWalletApp extends StatefulWidget {
  const HadramoutWalletApp({super.key});

  @override
  State<HadramoutWalletApp> createState() => _HadramoutWalletAppState();
}

class _HadramoutWalletAppState extends State<HadramoutWalletApp> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'محفظة حضرموت',
      theme: buildWalletTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: SplashScreen(apiService: _apiService),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    final session = await widget.apiService.restoreSession();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => session == null
            ? LoginScreen(apiService: widget.apiService)
            : HomeScreen(apiService: widget.apiService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [WalletColors.navy, WalletColors.blue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WalletLogo(),
              const SizedBox(height: 22),
              const Text(
                'محفظة حضرموت',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'أموالك، بأمان وبساطة',
                style: TextStyle(
                  color: Colors.white.withAlpha(210),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withAlpha(210),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
