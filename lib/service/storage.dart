import 'package:flutter/material.dart' as ui;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable/model/event.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import '../model/timetable_view.dart';

Future<void> writeCredentials() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.args != null && store.state.cnsc != null) {
    prefs.setString('args', store.state.args!);
    prefs.setString('cnsc', store.state.cnsc!);
  }
}

Future<void> loadCredentials() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('args') && prefs.containsKey('cnsc')) {
    store.dispatch(
      setCredentials(prefs.getString('args')!, prefs.getString('cnsc')!),
    );
  }
}

Future<void> writeDesign() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.activeTheme == ui.ThemeMode.system) {
    if (prefs.containsKey('darkmode')) {
      prefs.remove('darkmode');
    }
  } else {
    prefs.setBool('darkmode', store.state.activeTheme == ui.ThemeMode.dark);
  }
}

Future<void> loadDesign() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  ui.ThemeMode themeMode = ui.ThemeMode.system;

  if (prefs.getBool('darkmode') == true) {
    themeMode = ui.ThemeMode.dark;
  } else if (prefs.getBool('darkmode') == false) {
    themeMode = ui.ThemeMode.light;
  }

  store.dispatch(setDesign(themeMode));
}

Future<void> crashlyticsDialogShown() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('crashlyticsDialogShown', '1');
}

Future<bool> didShowCrashlyticsDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('crashlyticsDialogShown');
}

Future<void> writeGPA({bool isGuest = false}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (isGuest) {
    prefs.setDouble('gpa', 2.0);
    return;
  }
  prefs.setDouble('gpa', store.state.gpa);
}

Future<void> loadGPA() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('gpa')) {
    store.dispatch(setGPA(prefs.getDouble('gpa')!));
  }
}

Future<void> writeDownloadedRange() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.downloadedUntil == null) {
    prefs.remove('downloadedRange');
  } else {
    prefs.setString(
        'downloadedRange', dayFormat.format(store.state.downloadedUntil!));
  }
}

Future<void> loadDownloadedRange() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    store.dispatch(
      setDownloadedUntil(
        prefs.containsKey('downloadedRange')
            ? dayFormat.parse(prefs.getString('downloadedRange')!)
            : null,
      ),
    );
  } on FormatException {
    store.dispatch(setLastUpdated(null));
  }
}

Future<void> writeNotificationsEnabled() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('notificationsEnabled', store.state.notificationsEnabled);
}

Future<void> loadNotificationsEnabled() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('notificationsEnabled')) {
    store.dispatch(setNotificationsEnabled(
      prefs.getBool('notificationsEnabled')!,
    ));
  }
}

Future<void> writeDefaultView() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('defaultView', store.state.defaultView.index);
}

Future<void> loadDefaultView() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('defaultView')) {
    store.dispatch(
      setDefaultView(TimetableView.values[prefs.getInt('defaultView')!]),
    );
    store.dispatch(setView(
      TimetableView.values[prefs.getInt('defaultView')!],
    ));
  }
}

Future<void> writeAccount({bool isGuest = false}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (isGuest) {
    prefs.setString('account', 'Gastnutzer');
    return;
  }
  if (store.state.account == null) return;
  prefs.setString('account', store.state.account!);
}

Future<void> loadAccount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('account')) {
    store.dispatch(
      setAccount(prefs.getString('account')),
    );
  }
}

Future<void> writeEnableConfirmRefreshDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(
      'enableConfirmRefreshDialog', store.state.enableConfirmRefreshDialog);
}

Future<void> loadEnableConfirmRefreshDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('enableConfirmRefreshDialog')) {
    store.dispatch(setEnableConfirmRefreshDialog(
      prefs.getBool('enableConfirmRefreshDialog')!,
    ));
  }
}

Future<void> writeLastUpdated() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.lastUpdated == null) return;
  prefs.setString('lastUpdated', dayFormat.format(store.state.lastUpdated!));
}

Future<void> loadLastUpdated() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('lastUpdated')) {
      store.dispatch(
        setLastUpdated(dayFormat.parse(prefs.getString('lastUpdated')!)),
      );
    }
  } on FormatException {
    store.dispatch(setLastUpdated(null));
  }
}

Future<void> clearStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();

  final String path = join(await getDatabasesPath(), 'timetable.db');
  await deleteDatabase(path);

  CookieManager.instance().deleteAllCookies();
}
