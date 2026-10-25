import 'package:flutter/material.dart';
import '../models/app_language.dart';
import '../models/shop_type.dart';

class MzansiAppState extends ChangeNotifier {
  ShopType _activeShop = ShopType.spaza;
  AppLanguage _activeLanguage = AppLanguage.english;

  ShopType get activeShop => _activeShop;
  AppLanguage get activeLanguage => _activeLanguage;

  void setShop(ShopType shop) {
    if (_activeShop != shop) {
      _activeShop = shop;
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage language) {
    if (_activeLanguage != language) {
      _activeLanguage = language;
      notifyListeners();
    }
  }

  static MzansiAppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (provider == null) {
      throw StateError('AppStateScope not found in widget tree.');
    }
    return provider.state;
  }
}

class AppStateScope extends InheritedNotifier<MzansiAppState> {
  const AppStateScope({
    super.key,
    required MzansiAppState state,
    required super.child,
  }) : super(notifier: state);

  MzansiAppState get state => notifier!;
}
