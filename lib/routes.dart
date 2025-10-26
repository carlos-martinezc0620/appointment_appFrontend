import 'package:flutter/material.dart';
import '../main.dart'; // Para LoginPage
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/privacy_page.dart';
import 'pages/about_page.dart';
import 'pages/messages_page.dart';
import 'pages/appointments_page.dart';

class Routes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String messages = '/messages';
  static const String appointments = '/appointments';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPage());
      case Routes.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case Routes.messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case Routes.appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Esta ruta no existe: ${settings.name}')),
          ),
        );
    }
  }
}
