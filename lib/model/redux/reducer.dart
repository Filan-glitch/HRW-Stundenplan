import 'package:flutter/material.dart' as ui;

import '../biometrics.dart';
import '../campus.dart';
import '../date_time_calculator.dart';
import '../timetable_view.dart';
import 'actions.dart';
import 'app_state.dart';

// TODO: validate runtime type of payload

AppState appReducer(AppState state, dynamic action) {
  if (action is! Action) return state;

  switch (action.type) {
    case ActionTypes.setEvents:
      state.events = action.payload;
      break;
    case ActionTypes.setDownloadedUntil:
      state.downloadedUntil = action.payload;
      break;
    case ActionTypes.clear:
      clearState(state);
      break;
    case ActionTypes.setDesign:
      state.activeTheme = action.payload;
      break;
    case ActionTypes.setCredentials:
      state
        ..args = action.payload['args']
        ..cnsc = action.payload['cnsc'];
      break;
    case ActionTypes.startTask:
      state.runningTasks++;
      break;
    case ActionTypes.stopTask:
      state.runningTasks--;
      break;
    case ActionTypes.setupCompleted:
      state.dataLoaded = true;
      break;
    case ActionTypes.showChangelog:
      state.showChangelog = action.payload;
      break;
    case ActionTypes.setLoginFormState:
      state.loginFormState = action.payload;
      break;
    case ActionTypes.setCurrentWeek:
      state.currentWeek = cleanDate(action.payload);
      break;
    case ActionTypes.setGrades:
      state.modules = action.payload;
      break;
    case ActionTypes.setGPA:
      state.gpa = action.payload;
      break;
    case ActionTypes.setCampus:
      state.selectedCampus = action.payload;
      break;
    case ActionTypes.setBiometricsType:
      state.biometrics = action.payload;
      break;
    case ActionTypes.setLockState:
      state.appLocked = action.payload;
      break;
    case ActionTypes.setNotificationsEnabled:
      state.notificationsEnabled = action.payload;
      break;
    case ActionTypes.setView:
      state.currentView = action.payload;
      break;
    case ActionTypes.setDefaultView:
      state.defaultView = action.payload;
      break;
    case ActionTypes.setAccount:
      state.account = action.payload;
      break;
    case ActionTypes.setLastUpdated:
      state.lastUpdated = action.payload;
      break;
    case ActionTypes.setEnableConfirmRefreshDialog:
      state.enableConfirmRefreshDialog = action.payload;
      break;
    case ActionTypes.setCanteenData:
      state.campuses = action.payload;
    default:
      break;
  }
  return state;
}

void clearState(AppState state) {
  state
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
