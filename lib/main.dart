import 'package:decafe_app/page/mainMenuPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const DecafeApp());
}

class DecafeApp extends StatelessWidget {
  const DecafeApp({Key? key}) : super(key: key);

  double _fontScale(Size size) {
    final shortestSide = size.shortestSide;
    if (shortestSide < 360) return 0.72;
    if (shortestSide < 600) return 0.82;
    if (shortestSide < 900) return 0.92;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: const Color.fromRGBO(85, 206, 55, 1),
            ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final currentScale = mediaQuery.textScaler.scale(1);
        final scaledFactor = (currentScale * _fontScale(mediaQuery.size))
            .clamp(0.75, 1.15)
            .toDouble();
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(scaledFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: false,
        child: const MainMenu(),
      ),
    );
  }
}
