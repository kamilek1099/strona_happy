import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_language.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final String currentLanguage;
  final String currentColor;
  final Function(String) onLanguageChanged;
  final Function(String) onColorChanged;

  const SettingsScreen({
    super.key,
    required this.currentLanguage,
    required this.currentColor,
    required this.onLanguageChanged,
    required this.onColorChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String currentLanguage;
  late String currentColor;
  TimeOfDay _notifTime = const TimeOfDay(hour: 9, minute: 0);
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.currentLanguage;
    currentColor = widget.currentColor;
    _loadSavedNotifTime();
    _loadAppVersion();
  }

  Future<void> _loadSavedNotifTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('notif_hour') ?? 9;
    final minute = prefs.getInt('notif_minute') ?? 0;
    setState(() {
      _notifTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void changeLanguage(String languageCode) {
    setState(() { currentLanguage = languageCode; });
    widget.onLanguageChanged(languageCode);
  }

  void changeColor(String colorCode) {
    setState(() { currentColor = colorCode; });
    widget.onColorChanged(colorCode);
  }

  @override
  Widget build(BuildContext context) {
    final languageData = AppLanguage.languages[currentLanguage]!;
    final colorScheme = AppColors.colorSchemes[currentColor]!;

    return Scaffold(
      backgroundColor: colorScheme['background']!,
      body: Container(
        color: colorScheme['background']!,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme['text']!,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 32,
              title: const Text('', style: TextStyle(fontWeight: FontWeight.normal)),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme['text']!),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildLanguageSection(languageData, colorScheme),
                  const SizedBox(height: 20),
                  _buildColorSection(languageData, colorScheme),
                  const SizedBox(height: 20),
                  _buildNotificationsSection(colorScheme),
                  const SizedBox(height: 20),
                  _buildSubscriptionSection(colorScheme),
                  const SizedBox(height: 20),
                  _buildInfoSection(colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  // ── LANGUAGE ──────────────────────────────────────────────────────────────
  Widget _buildLanguageSection(LanguageData languageData, Map<String, Color> colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(languageData.languageHeader, colorScheme['text']!),
        _buildLanguageItem(languageData.languages[0], 'pl', colorScheme),
        _buildLanguageItem(languageData.languages[1], 'en', colorScheme),
        _buildLanguageItem(languageData.languages[2], 'de', colorScheme),
        _buildLanguageItem(languageData.languages[3], 'it', colorScheme),
        _buildLanguageItem(languageData.languages[4], 'es', colorScheme),
        _buildLanguageItem(languageData.languages[5], 'zh', colorScheme),
      ],
    );
  }

  Widget _buildLanguageItem(String language, String languageCode, Map<String, Color> colorScheme) {
    final isSelected = currentLanguage == languageCode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => changeLanguage(languageCode),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isSelected ? colorScheme['text']! : colorScheme['button']!,
          ),
          foregroundColor: MaterialStateProperty.all(
            isSelected ? colorScheme['button']! : colorScheme['text']!,
          ),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          elevation: MaterialStateProperty.all(0),
          minimumSize: MaterialStateProperty.all(const Size(300, 40)),
          maximumSize: MaterialStateProperty.all(const Size(300, 40)),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          animationDuration: Duration.zero,
        ),
        child: Text(language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
      ),
    );
  }

  // ── COLOR ─────────────────────────────────────────────────────────────────
  Widget _buildColorSection(LanguageData languageData, Map<String, Color> colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(languageData.colorHeader, colorScheme['text']!),
        for (int i = 0; i < languageData.colors.length; i++)
          _buildColorItem(
            AppLanguage.colorEmojis[AppLanguage.colorOrder[currentLanguage]![i]]!,
            languageData.colors[i],
            AppLanguage.colorOrder[currentLanguage]![i],
            colorScheme,
          ),
      ],
    );
  }

  Widget _buildColorItem(String emoji, String colorName, String colorCode, Map<String, Color> colorScheme) {
    final isSelected = currentColor == colorCode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => changeColor(colorCode),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) =>
            isSelected ? colorScheme['text']! : colorScheme['button']!,
          ),
          foregroundColor: MaterialStateProperty.resolveWith((states) =>
            isSelected ? colorScheme['button']! : colorScheme['text']!,
          ),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          elevation: MaterialStateProperty.all(0),
          minimumSize: MaterialStateProperty.all(const Size(300, 40)),
          maximumSize: MaterialStateProperty.all(const Size(300, 40)),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          animationDuration: Duration.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(colorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            const SizedBox(width: 8),
            Text(emoji, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────
  Widget _buildNotificationsSection(Map<String, Color> colorScheme) {
    final label = {
      'pl': 'Powiadomienia',
      'en': 'Notifications',
      'de': 'Benachrichtigungen',
      'it': 'Notifiche',
      'es': 'Notificaciones',
      'zh': '通知',
    }[currentLanguage] ?? 'Notifications';

    final hour = _notifTime.hour.toString().padLeft(2, '0');
    final minute = _notifTime.minute.toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(label, colorScheme['text']!),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ElevatedButton(
            onPressed: () => _showTimePicker(colorScheme),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(colorScheme['button']!),
              foregroundColor: MaterialStateProperty.all(colorScheme['text']!),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              elevation: MaterialStateProperty.all(0),
              minimumSize: MaterialStateProperty.all(const Size(300, 40)),
              maximumSize: MaterialStateProperty.all(const Size(300, 40)),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              animationDuration: Duration.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$hour:$minute',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                const SizedBox(width: 8),
                const Text('🕐', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(Map<String, Color> colorScheme) {
    DateTime pickerTime = DateTime(2000, 1, 1, _notifTime.hour, _notifTime.minute);
    showDialog(
      context: context,
      barrierColor: colorScheme['text']!.withOpacity(0.15),
      builder: (ctx) {
        return Dialog(
          backgroundColor: colorScheme['background']!,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 180,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 22,
                          color: colorScheme['text']!,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: pickerTime,
                      use24hFormat: true,
                      minuteInterval: 5,
                      backgroundColor: colorScheme['background']!,
                      onDateTimeChanged: (dt) {
                        pickerTime = dt;
                        _saveAndReschedule(TimeOfDay(hour: dt.hour, minute: dt.minute));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(colorScheme['button']!),
                    foregroundColor: MaterialStateProperty.all(colorScheme['text']!),
                    elevation: MaterialStateProperty.all(0),
                    minimumSize: MaterialStateProperty.all(const Size(double.infinity, 40)),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: const Text('OK', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAndReschedule(TimeOfDay t) async {
    setState(() { _notifTime = t; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_hour', t.hour);
    await prefs.setInt('notif_minute', t.minute);
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    if (enabled) {
      await NotificationService.scheduleDailyNotification(currentLanguage, t.hour, t.minute);
    }
  }

  // ── SUBSCRIPTION ──────────────────────────────────────────────────────────
  Widget _buildSubscriptionSection(Map<String, Color> colorScheme) {
    final label = {
      'pl': 'Subskrypcja',
      'en': 'Subscription',
      'de': 'Abonnement',
      'it': 'Abbonamento',
      'es': 'Suscripción',
      'zh': '订阅',
    }[currentLanguage] ?? 'Subscription';

    final manageLabel = {
      'pl': 'Zarządzaj subskrypcją',
      'en': 'Manage subscription',
      'de': 'Abonnement verwalten',
      'it': 'Gestisci abbonamento',
      'es': 'Gestionar suscripción',
      'zh': '管理订阅',
    }[currentLanguage] ?? 'Manage subscription';

    final restoreLabel = {
      'pl': 'Przywróć zakup',
      'en': 'Restore purchase',
      'de': 'Kauf wiederherstellen',
      'it': 'Ripristina acquisto',
      'es': 'Restaurar compra',
      'zh': '恢复购买',
    }[currentLanguage] ?? 'Restore purchase';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(label, colorScheme['text']!),
        _buildSimpleButton(manageLabel, '💳', colorScheme,
            () => _openUrl('https://apps.apple.com/account/subscriptions')),
        _buildSimpleButton(restoreLabel, '🔄', colorScheme, () {
          // TODO: in_app_purchase restore logic
        }),
      ],
    );
  }

  // ── INFO ──────────────────────────────────────────────────────────────────
  Widget _buildInfoSection(Map<String, Color> colorScheme) {
    final label = {
      'pl': 'Informacje',
      'en': 'Information',
      'de': 'Informationen',
      'it': 'Informazioni',
      'es': 'Información',
      'zh': '信息',
    }[currentLanguage] ?? 'Information';

    final websiteLabel = {
      'pl': 'Regulamin i prywatność',
      'en': 'Terms & Privacy',
      'de': 'AGB & Datenschutz',
      'it': 'Termini e Privacy',
      'es': 'Términos y Privacidad',
      'zh': '条款与隐私',
    }[currentLanguage] ?? 'Terms & Privacy';

    final rateLabel = {
      'pl': 'Oceń aplikację',
      'en': 'Rate the app',
      'de': 'App bewerten',
      'it': "Valuta l'app",
      'es': 'Calificar la app',
      'zh': '评价应用',
    }[currentLanguage] ?? 'Rate the app';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSectionHeader(label, colorScheme['text']!),
        _buildSimpleButton(websiteLabel, '📄', colorScheme,
            () => _openUrl('https://example.com/terms')),
        _buildSimpleButton(rateLabel, '⭐', colorScheme,
            () => _openUrl('https://apps.apple.com/app/idXXXXXXXXX')),
        const SizedBox(height: 12),
        Text(
          'v$_appVersion',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme['text']!.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  // ── SHARED: simple centered button identical to language/color buttons ─────
  Widget _buildSimpleButton(String label, String emoji, Map<String, Color> colorScheme, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(colorScheme['button']!),
          foregroundColor: MaterialStateProperty.all(colorScheme['text']!),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          elevation: MaterialStateProperty.all(0),
          minimumSize: MaterialStateProperty.all(const Size(300, 40)),
          maximumSize: MaterialStateProperty.all(const Size(300, 40)),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          animationDuration: Duration.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            const SizedBox(width: 8),
            Text(emoji, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
