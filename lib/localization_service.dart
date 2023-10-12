import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'lang/dede.dart';
import 'lang/enus.dart';
import 'lang/eses.dart';

class LocalizationService extends Translations {
  // Default locale
  static const locale = Locale('de', 'DE');

  // fallbackLocale saves the day when the locale gets in trouble
  static const fallbackLocale = Locale('de', 'DE');

  // Supported languages
  // Needs to be same order with locales
  static final langs = ['English', 'Deutsch', 'Español'];

  // Supported locales
  // Needs to be same order with langs
  static final locales = [
    const Locale('en', 'US'),
    const Locale('de', 'DE'),
    const Locale('es', 'ES'),
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS, // lang/enus.dart
        'de_DE': deDE, // lang/dede.dart
        'es_ES': esES, // lang/eses.dart
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);

    final box = GetStorage();
    box.write('lng', lang);

    Get.updateLocale(locale!);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale? getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) return locales[i];
    }
    return Get.locale;
  }

  Locale getCurrentLocale() {
    final box = GetStorage();
    Locale defaultLocale;

    if (box.read('lng') != null) {
      final locale =
          LocalizationService().getLocaleFromLanguage(box.read('lng'));

      defaultLocale = locale!;
    } else {
      defaultLocale = const Locale(
        'de',
        'DE',
      );
    }

    return defaultLocale;
  }

  String getCurrentLang() {
    final box = GetStorage();

    return box.read('lng') ?? "Deutsch";
  }
}
