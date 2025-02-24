import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

const S sDefault = S();

class S implements WidgetsLocalizations {
  const S();

  static S current;

  static const GeneratedLocalizationsDelegate delegate =
      GeneratedLocalizationsDelegate();

  static S of(BuildContext context) =>
      Localizations.of<S>(context, S) ?? sDefault;

  @override
  TextDirection get textDirection => TextDirection.ltr;

  String get access_to_location_denied => "Access to location denied";

  String get allow_access_to_the_location_services =>
      "Allow access to the location services.";

  String get cant_get_current_location => "Can't get current location";

  String get finding_place => "Finding place...";

  String get no_result_found => "No result found";

  String get ok => "Ok";

  String get please_check_your_connection => "Please check your connection";

  String get please_make_sure_you_enable_gps_and_try_again =>
      "Please make sure you enable GPS and try again";

  String get search_place => "Search place";

  String get server_error => "Server error";
}

class $en extends S {
  const $en();
}

class $vi extends S {
  const $vi();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  @override
  String get cant_get_current_location => "Không thể tìm được vị trí hiện tại";

  @override
  String get finding_place => "Tìm địa điểm...";

  @override
  String get no_result_found => "Không có kết quả nào";

  @override
  String get access_to_location_denied => "App Cần quyền truy cập vào Vị Trí";

  @override
  String get allow_access_to_the_location_services =>
      "Cho phép truy cập vào các dịch vụ định vị.";

  @override
  String get server_error => "Lỗi kết nối";

  @override
  String get search_place => "Địa điểm tìm kiếm";

  @override
  String get ok => "Đồng ý";

  @override
  String get please_check_your_connection =>
      "Vui lòng kiểm tra kết nối của bạn";

  @override
  String get please_make_sure_you_enable_gps_and_try_again =>
      "Vui lòng đảm bảo rằng bạn bật GPS và thử lại";
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("vi", ""),
      Locale("en", ""),
    ];
  }

  LocaleListResolutionCallback listResolution(
      {Locale fallback, bool withCountry = true}) {
    return (List<Locale> locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution(
      {Locale fallback, bool withCountry = true}) {
    return (Locale locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<S> load(Locale locale) async {
    String lang = getLang(locale);
    final SharedPreferences prefInstance =
        await SharedPreferences.getInstance();
    if (prefInstance.containsKey("language_code")) {
      lang = prefInstance.get("language_code");
    }
    if (lang != null) {
      switch (lang) {
        case "vi":
          S.current = const $vi();
          return SynchronousFuture<S>(S.current);
          break;
        case "en":
          S.current = const $en();
          return SynchronousFuture<S>(S.current);
          break;
        default:
      }
    }
    S.current = const S();
    return SynchronousFuture<S>(S.current);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported,
      bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry &&
            (supportedLocale.countryCode == null ||
                supportedLocale.countryCode.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String getLang(Locale l) => l == null
    ? null
    : l.countryCode != null && l.countryCode.isEmpty
        ? l.languageCode
        : l.toString();
