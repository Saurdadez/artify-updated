import 'package:art_app/components/page_notifier.dart';
import 'package:art_app/components/bottom_navigationbar.dart';
import 'package:art_app/components/theme_notifier.dart';
import 'package:art_app/firebase_options.dart';
import 'package:art_app/pages/discover_page.dart';
import 'package:art_app/pages/home_page.dart';
import 'package:art_app/pages/login_page.dart';
import 'package:art_app/pages/profile_page.dart';
import 'package:art_app/pages/register_info_page.dart';
import 'package:art_app/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PageChangeNotifier()),
      ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, child) {
      return MaterialApp(
        title: 'Artify',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        theme: ThemeData(colorScheme: notifier.colorScheme),
        routes: {
          '/': (context) => const BottomNavigation(),
          '/home': (context) => const Home(),
          '/profile': (context) => const ProfilePage(),
          '/discover': (context) => const DiscoverPage(),
          '/signup': (context) => const RegisterPage(),
          '/login': (context) => const LoginPage(),
          '/signup-info': (context) => const RegisterInfoPage(email: ''),
        },
      );
    });
  }
}
