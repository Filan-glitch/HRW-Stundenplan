import 'package:flutter/material.dart' as ui;
import 'package:flutter/material.dart';
import 'package:timetable/model/biometrics.dart';
import 'package:timetable/model/campus.dart';
import 'package:timetable/model/date_time_calculator.dart';
import 'package:timetable/model/event.dart';
import 'package:timetable/model/login_state.dart';
import 'package:timetable/model/module.dart';
import 'package:timetable/model/redux/app_state.dart';
import 'package:timetable/model/redux/store.dart';
import 'package:timetable/model/timetable_view.dart';
import '../graphql/canteens/campus.dart' as canteens;

AppState setEvents(List<Event> events) {
  return store.state..events = events;
}

AppState setGrades(List<Module> modules) {
  return store.state..modules = modules;
}

AppState setCampus(Campus campus) {
  return store.state..selectedCampus = campus;
}

AppState clear() {
  return store.state
    ..activeTheme = ui.ThemeMode.system
    ..runningTasks = 0
    ..cnsc = null
    ..args = null
    ..events = []
    ..downloadedUntil = null
    ..modules = []
    ..gpa = 0
    ..selectedCampus = Campus.muelheim
    ..biometrics = Biometrics.OFF
    ..currentView = TimetableView.daily
    ..defaultView = TimetableView.daily
    ..appLocked = false
    ..account = null;
}

AppState setDesign(ThemeMode theme) {
  return store.state..activeTheme = theme;
}

AppState setCredentials(String? args, String? cnsc) {
  return store.state
    ..args = args
    ..cnsc = cnsc;
}

AppState startTask() {
  return store.state..runningTasks = store.state.runningTasks + 1;
}

AppState stopTask() {
  return store.state..runningTasks = store.state.runningTasks - 1;
}

AppState setupCompleted() {
  return store.state..dataLoaded = true;
}

AppState showChangelog(bool show) {
  return store.state..showChangelog = show;
}

AppState setLoginFormState(LoginFormState state) {
  return store.state..loginFormState = state;
}

AppState setCurrentWeek(DateTime date) {
  return store.state..currentWeek = cleanDate(date);
}

AppState setGPA(double gpa) {
  return store.state..gpa = gpa;
}

AppState setLockState(bool isLocked) {
  return store.state..appLocked = isLocked;
}

AppState setBiometricsType(Biometrics type) {
  return store.state..biometrics = type;
}

AppState setNotificationsEnabled(bool enabled) {
  return store.state..notificationsEnabled = enabled;
}

AppState setView(TimetableView view) {
  return store.state..currentView = view;
}

AppState setDefaultView(TimetableView view) {
  return store.state..defaultView = view;
}

AppState setAccount(String? account) {
  return store.state..account = account;
}

AppState setLastUpdated(DateTime? lastUpdated) {
  return store.state..lastUpdated = lastUpdated;
}

AppState setEnableConfirmRefreshDialog(bool enabled) {
  return store.state..enableConfirmRefreshDialog = enabled;
}

AppState setCanteenData(List<canteens.Campus> canteens) {
  return store.state..campuses = canteens;
}

AppState setDownloadedUntil(DateTime? date) {
  return store.state..downloadedUntil = date;
}
