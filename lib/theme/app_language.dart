class LanguageData {
  final String name;
  final String mainButtonText;
  final String languageHeader;
  final String colorHeader;
  final String lockedWidgetMessage;
  final List<String> languages;
  final List<String> colors;

  const LanguageData({
    required this.name,
    required this.mainButtonText,
    required this.languageHeader,
    required this.colorHeader,
    required this.lockedWidgetMessage,
    required this.languages,
    required this.colors,
  });
}

class AppLanguage {
  static const Map<String, String> colorEmojis = {
    'jasminetea': '🍃',
    'cherryblossom': '🌸',
    'coconut': '🥥',
    'tropicalforest2': '🌳',
    'mangoyellow': '🥭',
    'matchagreen': '🍵',
    'oceanblue': '🌊',
    'lavendersoft': '💜',
  };

  static const Map<String, List<String>> colorOrder = {
    'pl': ['jasminetea', 'cherryblossom', 'coconut', 'tropicalforest2', 'mangoyellow', 'matchagreen', 'oceanblue', 'lavendersoft'],
    'en': ['coconut', 'cherryblossom', 'jasminetea', 'mangoyellow', 'matchagreen', 'oceanblue', 'tropicalforest2', 'lavendersoft'],
    'de': ['cherryblossom', 'jasminetea', 'coconut', 'mangoyellow', 'matchagreen', 'oceanblue', 'tropicalforest2', 'lavendersoft'],
    'it': ['coconut', 'cherryblossom', 'mangoyellow', 'matchagreen', 'oceanblue', 'jasminetea', 'tropicalforest2', 'lavendersoft'],
    'es': ['coconut', 'cherryblossom', 'mangoyellow', 'matchagreen', 'oceanblue', 'tropicalforest2', 'jasminetea', 'lavendersoft'],
    'zh': ['coconut', 'cherryblossom', 'jasminetea', 'mangoyellow', 'matchagreen', 'oceanblue', 'tropicalforest2', 'lavendersoft'],
  };

  static const Map<String, LanguageData> languages = {
    'pl': LanguageData(
      name: 'Polski',
      mainButtonText: 'Chce być szczęśliwy',
      languageHeader: 'Język',
      colorHeader: 'Kolor',
      lockedWidgetMessage: 'Otwórz aplikację, aby odblokować cytat ✨',
      languages: ['Polski 🇵🇱', 'Angielski 🇺🇸', 'Niemiecki 🇩🇪', 'Włoski 🇮🇹', 'Hiszpański 🇪🇸', 'Chiński 🇨🇳'],
      colors: ['Herbata Jaśminowa', 'Japoński Kwiat Wiśni', 'Kokos', 'Las Tropikalny', 'Mango', 'Matcha', 'Ocean', 'Lawenda'],
    ),
    'en': LanguageData(
      name: 'English',
      mainButtonText: 'I Want to Be Happy',
      languageHeader: 'Language',
      colorHeader: 'Color',
      lockedWidgetMessage: 'Open the app to unlock today\'s quote ✨',
      languages: ['Polish 🇵🇱', 'English 🇺🇸', 'German 🇩🇪', 'Italian 🇮🇹', 'Spanish 🇪🇸', 'Chinese 🇨🇳'],
      colors: ['Coconut', 'Japanese Cherry Blossom', 'Jasmine Tea', 'Mango', 'Matcha', 'Ocean', 'Tropical Forest', 'Lavender'],
    ),
    'de': LanguageData(
      name: 'Deutsch',
      mainButtonText: 'Ich möchte glücklich sein',
      languageHeader: 'Sprache',
      colorHeader: 'Farbe',
      lockedWidgetMessage: 'Öffnen Sie die App, um das heutige Zitat freizuschalten ✨',
      languages: ['Polnisch 🇵🇱', 'Englisch 🇺🇸', 'Deutsch 🇩🇪', 'Italienisch 🇮🇹', 'Spanisch 🇪🇸', 'Chinesisch 🇨🇳'],
      colors: ['Japanische Kirschblüte', 'Jasmintee', 'Kokosnuss', 'Mango', 'Matcha', 'Ozean', 'Tropenwald', 'Lavendel'],
    ),
    'it': LanguageData(
      name: 'Italiano',
      mainButtonText: 'Voglio essere felice',
      languageHeader: 'Lingua',
      colorHeader: 'Colore',
      lockedWidgetMessage: 'Apri l\'app per sbloccare la citazione di oggi ✨',
      languages: ['Polacco 🇵🇱', 'Inglese 🇺🇸', 'Tedesco 🇩🇪', 'Italiano 🇮🇹', 'Spagnolo 🇪🇸', 'Cinese 🇨🇳'],
      colors: ['Cocco', 'Fiore di Ciliegio Giapponese', 'Mango', 'Matcha', 'Oceano', 'Tè al Gelsomino', 'Foresta Tropicale', 'Lavanda'],
    ),
    'es': LanguageData(
      name: 'Español',
      mainButtonText: 'Quiero ser feliz',
      languageHeader: 'Idioma',
      colorHeader: 'Color',
      lockedWidgetMessage: 'Abre la aplicación para desbloquear la cita de hoy ✨',
      languages: ['Polaco 🇵🇱', 'Inglés 🇺🇸', 'Alemán 🇩🇪', 'Italiano 🇮🇹', 'Español 🇪🇸', 'Chino 🇨🇳'],
      colors: ['Coco', 'Flor de Cerezo Japonés', 'Mango', 'Matcha', 'Océano', 'Selva Tropical', 'Té de Jazmín', 'Lavanda'],
    ),
    'zh': LanguageData(
      name: '中文',
      mainButtonText: '我想要快樂',
      languageHeader: '語言',
      colorHeader: '顏色',
      lockedWidgetMessage: '打開應用程式以解鎖今天的引言 ✨',
      languages: ['波蘭語🇵🇱', '英文🇺🇸', '德語🇩🇪', '義大利文🇮🇹', '西班牙文🇪🇸', '中文🇨🇳'],
      colors: ['椰子', '日本櫻花', '茉莉花茶', '芒果', '抹茶', '海洋', '熱帶森林', '薰衣草'],
    ),
  };
}
