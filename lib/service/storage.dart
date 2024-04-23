import 'package:flutter/material.dart' as ui;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable/model/event.dart';

import '../model/biometrics.dart';
import '../model/campus.dart';
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
    store.dispatch(Action(ActionTypes.setCredentials, payload: {
      'args': prefs.getString('args'),
      'cnsc': prefs.getString('cnsc'),
    }));
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

  store.dispatch(
    Action(
      ActionTypes.setDesign,
      payload: themeMode,
    ),
  );
}

Future<void> writeCampus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('campus', store.state.selectedCampus.text);
}

Future<void> loadCampus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('campus')) {
    store.dispatch(
      Action(
        ActionTypes.setCampus,
        payload: Campus.getByValue(prefs.getString('campus')!),
      ),
    );
  }
}

Future<void> crashlyticsDialogShown() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('crashlyticsDialogShown', '1');
}

Future<bool> didShowCrashlyticsDialog() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.containsKey('crashlyticsDialogShown');
}

Future<void> writeGPA() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('gpa', store.state.gpa);
}

Future<void> loadGPA() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('gpa')) {
    store.dispatch(
      Action(
        ActionTypes.setGPA,
        payload: prefs.getDouble('gpa'),
      ),
    );
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
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  store.dispatch(
    Action(
      ActionTypes.setDownloadedUntil,
      payload: prefs.containsKey('downloadedRange')
          ? dayFormat.parse(prefs.getString('downloadedRange')!)
          : null,
    ),
  );
}

Future<void> writeBiometrics() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('biometrics', store.state.biometrics.index);
}

Future<void> loadBiometrics() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('biometrics')) {
    store.dispatch(
      Action(
        ActionTypes.setBiometricsType,
        payload: Biometrics.values[prefs.getInt('biometrics')!],
      ),
    );
  }
}

Future<void> writeNotificationsEnabled() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('notificationsEnabled', store.state.notificationsEnabled);
}

Future<void> loadNotificationsEnabled() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('notificationsEnabled')) {
    store.dispatch(
      Action(
        ActionTypes.setNotificationsEnabled,
        payload: prefs.getBool('notificationsEnabled'),
      ),
    );
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
      Action(
        ActionTypes.setDefaultView,
        payload: TimetableView.values[prefs.getInt('defaultView')!],
      ),
    );
    store.dispatch(
      Action(
        ActionTypes.setView,
        payload: TimetableView.values[prefs.getInt('defaultView')!],
      ),
    );
  }
}

Future<void> writeAccount() async {
  if (store.state.account == null) return;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('account', store.state.account!);
}

Future<void> loadAccount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('account')) {
    store.dispatch(
      Action(
        ActionTypes.setAccount,
        payload: prefs.getString('account'),
      ),
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
    store.dispatch(
      Action(
        ActionTypes.setEnableConfirmRefreshDialog,
        payload: prefs.getBool('enableConfirmRefreshDialog'),
      ),
    );
  }
}

Future<void> writeKeepEditedOnReload() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('keepEditedOnReload', store.state.keepEditedOnReload);
}

Future<void> loadKeepEditedOnReload() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('keepEditedOnReload')) {
    store.dispatch(
      Action(
        ActionTypes.setKeepEditedOnReload,
        payload: prefs.getBool('keepEditedOnReload'),
      ),
    );
  }
}

Future<void> writeLastUpdated() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (store.state.lastUpdated == null) return;
  prefs.setString('lastUpdated', dayFormat.format(store.state.lastUpdated!));
}

Future<void> loadLastUpdated() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('lastUpdated')) {
    store.dispatch(
      Action(
        ActionTypes.setLastUpdated,
        payload: dayFormat.parse(prefs.getString('lastUpdated')!),
      ),
    );
  }
}

Future<void> clearStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  final String path = join(await getDatabasesPath(), 'timetable.db');
  await deleteDatabase(path);
  CookieManager.instance().deleteAllCookies();
}
