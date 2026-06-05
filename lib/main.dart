import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicjalizuj strefy czasowe
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
  
  final prefs = await SharedPreferences.getInstance();
  final String initialColor = prefs.getString('saved_color') ?? 'matchagreen';
  
  runApp(MyApp(initialColor: initialColor));
}

class MyApp extends StatefulWidget {
  final String initialColor;
  const MyApp({super.key, required this.initialColor});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.initialColor;
  }

  void changeAppColor(String colorCode) async {
    setState(() {
      currentColor = colorCode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_color', colorCode);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColors.colorSchemes[currentColor]!;
    
    return MaterialApp(
      title: 'Be Happy Everyday',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorScheme['text']!,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: colorScheme['background']!,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(colorScheme['button']!),
            foregroundColor: MaterialStateProperty.all(colorScheme['text']!),
            elevation: MaterialStateProperty.all(0),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            animationDuration: Duration.zero,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme['background']!,
          foregroundColor: colorScheme['text']!,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            overlayColor: Colors.transparent,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      home: AppRouter(
        currentColor: currentColor,
        onColorChanged: changeAppColor,
      ),
    );
  }
}

class AppRouter extends StatefulWidget {
  final String currentColor;
  final Function(String) onColorChanged;

  const AppRouter({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: _showSplash
          ? SplashScreen(key: const ValueKey('splash'), currentColor: widget.currentColor)
          : HappyScreen(
              key: const ValueKey('home'),
              currentColor: widget.currentColor,
              onColorChanged: widget.onColorChanged,
            ),
    );
  }
}
