import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_language.dart';
import '../services/notification_service.dart';
import '../services/message_service.dart';
import 'settings_screen.dart';
import 'package:home_widget/home_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class HappyScreen extends StatefulWidget {
  final String currentColor;
  final Function(String) onColorChanged;

  const HappyScreen({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<HappyScreen> createState() => _HappyScreenState();
}

class _HappyScreenState extends State<HappyScreen> with WidgetsBindingObserver {
  String currentLanguage = 'pl';
  String? currentHappyMessage;
  bool notificationsEnabled = false;
  bool isFirstTime = true;
  int currentDay = 1; // Nowa zmienna do śledzenia aktualnego dnia
  final ScreenshotController screenshotController = ScreenshotController();
  Timer? _testTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    
    // ZMIANA TESTOWA: Timer odświeżający tekst co 30 sekund, by w równej minucie zmienił się tekst na ekranie i wywołał update widgetu
    _testTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && notificationsEnabled) {
        _loadCurrentMessage();
      }
    });
  }

  Future<void> _initializeApp() async {
    await _loadSavedState();
    await _checkNotificationStatus();
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationStatus();
      if (notificationsEnabled) {
        await _checkDailyMessageUpdate();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Zapisz stan przy zamknięciu aplikacji
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_language', currentLanguage);
    }
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('saved_language');
    if (savedLanguage != null) {
      setState(() {
        currentLanguage = savedLanguage;
      });
    } else {
      // First launch auto language detection
      try {
        final osLanguage = ui.PlatformDispatcher.instance.locale.languageCode;
        if (AppLanguage.languages.containsKey(osLanguage)) {
          setState(() {
            currentLanguage = osLanguage;
          });
        } else {
          setState(() {
            currentLanguage = 'en'; 
          });
        }
      } catch (e) {
        setState(() {
          currentLanguage = 'en';
        });
      }
      await prefs.setString('saved_language', currentLanguage);
    }
    
    // Oblicz aktualny dzień na podstawie czasu instalacji
    final installTimestamp = prefs.getInt('install_timestamp');
    if (installTimestamp != null) {
      final installDate = DateTime.fromMillisecondsSinceEpoch(installTimestamp);
      final now = DateTime.now();
      
      // Obliczamy różnicę w pełnych dniach (niezależnie od godzin)
      final installDay = DateTime(installDate.year, installDate.month, installDate.day);
      final currentDayDate = DateTime(now.year, now.month, now.day);
      
      final daysDifference = currentDayDate.difference(installDay).inDays;
      
      setState(() {
        // Dzień 1 to dzień instalacji, więc dodajemy 1
        currentDay = daysDifference + 1;
        // Zabezpieczenie na wypadek zmiany czasu do tyłu
        if (currentDay < 1) currentDay = 1; 
      });
    }
    
    // Załaduj wiadomość jeśli powiadomienia są włączone
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    if (enabled) {
      await _loadCurrentMessage();
      
      // ZMIANA TESTOWA: Wymuszenie przeładowania harmonogramu co start aplikacji (żeby na pewno zaczął pikać w tle)
      final hour = prefs.getInt('notif_hour') ?? 9;
      final minute = prefs.getInt('notif_minute') ?? 0;
      await NotificationService.scheduleDailyNotification(currentLanguage, hour, minute);
    }
  }

  Future<void> _debugAddOneDay() async {
    final prefs = await SharedPreferences.getInstance();
    final installTimestamp = prefs.getInt('install_timestamp');
    if (installTimestamp != null) {
      // Odejmij 24 godziny od czasu instalacji (przyspiesza czas o 1 dzień do przodu)
      final newTimestamp = installTimestamp - const Duration(days: 1).inMilliseconds;
      await prefs.setInt('install_timestamp', newTimestamp);
      await _loadSavedState(); // Przeliczy currentDay i pobierze nową wiadomość
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tryb Testowy: Przyspieszono o 1 dzień! (Jesteś na Dniu $currentDay)'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.colorSchemes[widget.currentColor]!['button'],
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (notificationsEnabled) {
      _checkDailyMessageUpdate();
    }
  }

  // Sprawdź czy minął dzień i zaktualizuj wiadomość
  Future<void> _checkDailyMessageUpdate() async {
    if (!notificationsEnabled) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_message_update');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastUpdate != today) {
      await _loadCurrentMessage();
      await prefs.setString('last_message_update', today);
    }
  }

  Future<void> _checkNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    final firstTime = prefs.getBool('first_time') ?? true;
    
    setState(() {
      notificationsEnabled = enabled;
      isFirstTime = firstTime;
    });

    if (enabled) {
      await _checkDailyMessageUpdate();
    }
  }

  void changeLanguage(String languageCode) async {
    setState(() {
      currentLanguage = languageCode;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_language', languageCode);
    
    if (notificationsEnabled) {
      final hour = prefs.getInt('notif_hour') ?? 9;
      final minute = prefs.getInt('notif_minute') ?? 0;
      NotificationService.scheduleDailyNotification(languageCode, hour, minute);
      await _loadCurrentMessage(useSavedIndex: true);
    }
  }

  Future<void> _loadCurrentMessage({bool useSavedIndex = false}) async {
    final prefs = await SharedPreferences.getInstance();
    String message;
    
    final allMessages = await HappyMessageService.getAllMessages(currentLanguage);
    
    if (allMessages.isNotEmpty) {
      // ZMIANA TESTOWA: Oparcie indeksu o minuty, aby zmieniał się co 2 minuty (Dzielenie całkowite przed modulo)
      final currentMinutes = DateTime.now().minute;
      final testIndex = (currentMinutes ~/ 2) % allMessages.length;
      
      message = allMessages[testIndex];
      await prefs.setInt('current_message_index', testIndex);
    } else {
      message = await HappyMessageService.getRandomHappyMessage(currentLanguage);
    }
    
    setState(() {
      currentHappyMessage = message;
    });
    
    // Zaktualizuj Widget na ekranie głównym
    _updateWidget(message);
  }

  Future<void> _shareMessage() async {
    if (currentHappyMessage == null) return;

    final colorScheme = AppColors.colorSchemes[widget.currentColor]!;
    
    // Tworzymy widget do przechwycenia (ładniejszy niż to co na ekranie)
    final widgetToCapture = Container(
      padding: const EdgeInsets.all(40),
      color: colorScheme['background'],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Be Happy Everyday",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme['text']!.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentHappyMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: colorScheme['text'],
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    try {
      final image = await screenshotController.captureFromWidget(
        widgetToCapture,
        delay: const Duration(milliseconds: 10),
        context: context,
      );

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/quote.png').create();
      await imagePath.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Pozdrowienia z Be Happy Everyday! ✨',
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  Future<void> _updateWidget(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const isPremium = true; // ODBLOKOWANE (wyłączona blokada) na potrzeby testów wyświetlania cytatów
      final languageData = AppLanguage.languages[currentLanguage]!;
      final colorScheme = AppColors.colorSchemes[widget.currentColor]!;

      // Obliczanie HEX dla kolorów widgetu
      final bgColorHex = '#${colorScheme['background']!.value.toRadixString(16).substring(2).toUpperCase()}';
      final textColorHex = '#${colorScheme['text']!.value.toRadixString(16).substring(2).toUpperCase()}';

      await HomeWidget.saveWidgetData<String>('title', 'Be Happy Everyday');
      await HomeWidget.saveWidgetData<String>('message', message);
      await HomeWidget.saveWidgetData<String>('lockedMessage', languageData.lockedWidgetMessage);
      await HomeWidget.saveWidgetData<bool>('isPremium', isPremium); // Przekazujemy wiedzę o płatności
      
      await HomeWidget.saveWidgetData<String>('bgColor', bgColorHex);
      await HomeWidget.saveWidgetData<String>('textColor', textColorHex);
      
      await HomeWidget.updateWidget(
        name: 'HappyWidgetProvider',
        androidName: 'HappyWidgetProvider',
        iOSName: 'HappyWidget', // Będzie nasłuchiwać na iOS
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }


  Future<void> _requestNotificationPermission() async {
    await NotificationService.initialize();
    
    final prefs = await SharedPreferences.getInstance();
    // Zapisz czas instalacji tylko za pierwszym razem
    if (prefs.getInt('install_timestamp') == null) {
      await prefs.setInt('install_timestamp', DateTime.now().millisecondsSinceEpoch);
      setState(() {
        currentDay = 1;
      });
    }

    await _loadCurrentMessage();
    
    setState(() {
      notificationsEnabled = true;
      isFirstTime = false;
    });
    
    final granted = await NotificationService.requestPermission();
    if (granted) {
      final hour = prefs.getInt('notif_hour') ?? 9;
      final minute = prefs.getInt('notif_minute') ?? 0;
      await NotificationService.scheduleDailyNotification(currentLanguage, hour, minute);
      await prefs.setBool('notifications_enabled', true);
      await prefs.setBool('first_time', false);
    } else {
      await prefs.setBool('first_time', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageData = AppLanguage.languages[currentLanguage]!;
    final colorScheme = AppColors.colorSchemes[widget.currentColor]!;
    
    return Scaffold(
      backgroundColor: colorScheme['background']!,
      body: Container(
        color: colorScheme['background']!,
        child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: isFirstTime || !notificationsEnabled
                    ? ElevatedButton(
                        onPressed: _requestNotificationPermission,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) => colorScheme['button']!),
                          foregroundColor: MaterialStateProperty.resolveWith((states) => colorScheme['text']!),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )),
                          elevation: MaterialStateProperty.all(0),
                          minimumSize: MaterialStateProperty.all(const Size(240, 32)),
                          maximumSize: MaterialStateProperty.all(const Size(300, 50)),
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          animationDuration: const Duration(milliseconds: 500),
                        ),
                        child: Text(
                          languageData.mainButtonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Padding(
                          key: ValueKey<String>(currentHappyMessage ?? ""),
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: GestureDetector(
                            onLongPress: _debugAddOneDay,
                            child: Text(
                              currentHappyMessage ?? languageData.mainButtonText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: colorScheme['text']!,
                            ),
                          ),
                        ),
                        ),
                      ),
              ),
            ],
          ),
          Positioned(
            top: 70,
            right: 20,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colorScheme['button']!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            currentLanguage: currentLanguage,
                            currentColor: widget.currentColor,
                            onLanguageChanged: changeLanguage,
                            onColorChanged: widget.onColorChanged,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings_outlined,
                      color: colorScheme['text']!,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 30,
                    ),
                    style: IconButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (currentHappyMessage != null && !isFirstTime && notificationsEnabled)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  onPressed: _shareMessage,
                  icon: Icon(
                    Icons.ios_share,
                    color: colorScheme['text']!.withOpacity(0.25),
                    size: 22,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
