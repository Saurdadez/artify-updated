import 'package:flutter/material.dart';

class PageChangeNotifier extends ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldRefresh = false;
  bool _shouldRefreshHome = false;
  bool _shouldUpdate = false;

  bool get shouldRefresh => _shouldRefresh;
  int get currentIndex => _currentIndex;
  bool get shouldRefreshHome => _shouldRefreshHome;
  bool get shouldUpdate => _shouldUpdate;

  void setShouldUpdate(bool value) {
    _shouldUpdate = value;
    notifyListeners();
  }

  void updateIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void triggerRefresh(value) {
    _shouldRefresh = value;
    notifyListeners();
  }

  void triggerRefreshHome() {
    _shouldRefreshHome = !_shouldRefreshHome;
    notifyListeners();
  }

  void updateRefreshHome(bool shouldrefresh) {
    _shouldRefreshHome = shouldrefresh;
    notifyListeners();
  }
}
