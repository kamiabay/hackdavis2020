import 'dart:ui';
import 'package:flutter/cupertino.dart';
class Colors {

  const Colors();

  static const Color loginGradientStart = const Color.fromRGBO(231, 251, 250, 1.0);
  static const Color loginGradientEnd = const Color.fromRGBO(231, 251, 250, 1.0);

  static const primaryGradient = const LinearGradient(
    colors: const [loginGradientStart, loginGradientEnd],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}