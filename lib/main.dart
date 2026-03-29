import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';

import 'firebase_options.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/bk/presentation/bk_provider.dart';
import 'features/guru/presentation/guru_provider.dart';
import 'features/notification/presentation/notification_provider.dart';
import 'features/piket/presentation/piket_provider.dart';

import 'features/guru/presentation/guru_main_screen.dart';
import 'features/sekretaris/presentation/sekretaris_main_screen.dart';

import 'features/sekretaris/presentation/sekretaris_provider.dart';
import 'features/piket/presentation/dashboard_piket_screen.dart';
import 'features/bk/presentation/laporan_rekap_screen.dart';
import 'features/notification/presentation/notifikasi_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'core/network/api_client.dart';
import 'core/services/push_notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Inisialisasi Firebase Messaging untuk Foreground/Background
  final pushService = PushNotificationService();
  await pushService.init();
  pushService.onNotificationNavigated = (String route) {
    if (kDebugMode) print('Navigating to $route from Push Notification');
    navigatorKey.currentState?.pushNamed(route);
  };

  // 2. Global handler for token expired / 401 Unauthorized
  ApiClient.onUnauthorized.stream.listen((_) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      if (kDebugMode) print('🚪 Sesi kedaluwarsa. Redirecting ke Login...');
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout(); 
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GuruProvider()),
        ChangeNotifierProvider(create: (_) => PiketProvider()),
        ChangeNotifierProvider(create: (_) => BkProvider()),
        ChangeNotifierProvider(create: (_) => SekretarisProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Presentra',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
        locale: const Locale('id', 'ID'),
        theme: AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/guru': (context) => const GuruMainScreen(),
          '/guru_bk': (context) => const GuruMainScreen(),
          '/sekretaris': (context) => const SekretarisMainScreen(),
          '/dashboard_piket': (context) => const DashboardPiketScreen(),
          '/laporan_rekap': (context) => const LaporanRekapScreen(),
          '/notifikasi': (context) => const NotifikasiScreen(),
        },
      ),
    );
  }
}