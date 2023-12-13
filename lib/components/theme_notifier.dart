import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  late ColorScheme _colorScheme;

  ThemeNotifier() {
    _colorScheme = ColorScheme.dark(
      primary: Color.fromARGB(255, 255, 103, 61),
      onPrimaryContainer: const Color.fromARGB(255, 229, 229, 229),
      tertiary: Color.fromARGB(255, 33, 33, 33),
      surfaceVariant: Color.fromARGB(255, 186, 186, 186), // textfield label
      primaryContainer: Color.fromARGB(255, 1, 1, 1),
      secondary: Color.fromARGB(255, 94, 94, 94),
      secondaryContainer: Color.fromARGB(255, 26, 26, 26),
      inversePrimary: Colors.black,
      surface: Color.fromARGB(
          255, 15, 15, 15), // appbar and default container tiles color
      background: Color.fromARGB(255, 15, 15, 15), // scaffold
      error: Colors.red,
      onPrimary: Color.fromARGB(255, 10, 10, 10),
      onSecondary: Color.fromARGB(255, 199, 199, 199), //useless
      onSurface: Color.fromARGB(255, 236, 236, 236), // default texts
      onBackground: const Color.fromARGB(255, 83, 83, 83),
      onError: Colors.white,
      brightness: Brightness.light,
    );
  }
  ColorScheme get colorScheme => _colorScheme;
  Color get primary => _colorScheme.primary;
  Color get onPrimaryContainer => _colorScheme.onPrimaryContainer;
  Color get tertiary => _colorScheme.tertiary;
  Color get surfaceVariant => _colorScheme.surfaceVariant;
  Color get primaryContainer => _colorScheme.primaryContainer;
  Color get secondary => _colorScheme.secondary;
  Color get secondaryContainer => _colorScheme.secondaryContainer;
  Color get inversePrimary => _colorScheme.inversePrimary;
  Color get surface => _colorScheme.surface;
  Color get background => _colorScheme.background;
  Color get error => _colorScheme.error;
  Color get onPrimary => _colorScheme.onPrimary;
  Color get onSecondary => _colorScheme.onSecondary;
  Color get onSurface => _colorScheme.onSurface;
  Color get onBackground => _colorScheme.onBackground;
  Color get onError => _colorScheme.onError;
  Brightness get brightness => _colorScheme.brightness;

  void updateColorScheme(ColorScheme newColorScheme) {
    _colorScheme = newColorScheme;
    notifyListeners();
  }
}
