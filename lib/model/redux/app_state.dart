import 'package:flutter/material.dart';

import '../date_time_calculator.dart';
import '../event.dart';
import '../login_state.dart';
import '../module.dart';
import '../timetable_view.dart';

class AppState {
  ThemeMode activeTheme = ThemeMode.system;
  bool dataLoaded = false;
  int runningTasks = 0;
  bool get loading => runningTasks > 0;

  bool showChangelog = false;
  LoginFormState loginFormState = LoginFormState.notShown;
  late DateTime currentWeek;

  TimetableView currentView = TimetableView.daily;
  TimetableView defaultView = TimetableView.daily;
  bool notificationsEnabled = false;
  bool enableConfirmRefreshDialog = true;
  DateTime? lastUpdated;

  String? account;
  String? cnsc, args;
  List<Event> events = [];
  DateTime? downloadedUntil;

  List<Module> modules = [];
  double gpa = 0;

  ThemeMode get effectiveTheme {
    if (activeTheme == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    } else {
      return activeTheme;
    }
  }

  AppState() {
    currentWeek = getFirstDayOfWeek(
      cleanDate(DateTime.now()),
    );

    if (DateTime.now().weekday >= 6) {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
  }
}
