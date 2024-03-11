import 'package:flutter/material.dart' as ui;

import '../../service/db/events.dart';
import '../biometrics.dart';
import '../campus.dart';
import '../date_time_calculator.dart';
import '../event.dart';
import '../timetable_view.dart';
import 'actions.dart';
import 'app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is! Action) return state;

  switch (action.type) {
    case ActionTypes.setEvents:
      state.events[action.payload['date']] = action.payload['events'];
      break;
    case ActionTypes.clear:
      state
        ..activeTheme = ui.ThemeMode.system
        ..runningTasks = 0
        ..cnsc = null
        ..args = null
        ..events = {}
        ..modules = []
        ..gpa = 0
        ..campus = Campus.muelheim
        ..biometrics = Biometrics.OFF
        ..currentView = TimetableView.daily
        ..defaultView = TimetableView.daily
        ..appLocked = false
        ..account = null;
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
      state.campus = action.payload;
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
    case ActionTypes.deleteEvent:
      final Event eventToDelete = action.payload;
      state.events.update(eventToDelete.weekFrom, (value) {
        return value.where((event) => event != eventToDelete).toList();
      });
      setEventsHideFlag([eventToDelete], true);
      break;
    case ActionTypes.deleteEvents:
      final Event eventToDelete = action.payload;

      final List<Event> eventsToDelete = state.events.values
          .expand((x) => x)
          .where((event) =>
              event.title == eventToDelete.title &&
              event.start == eventToDelete.start &&
              event.end == eventToDelete.end &&
              event.day == eventToDelete.day)
          .toList();

      setEventsHideFlag(eventsToDelete, true);

      state.events.updateAll((key, value) {
        return value
            .where((event) =>
                event.title != eventToDelete.title ||
                event.start != eventToDelete.start ||
                event.end != eventToDelete.end ||
                event.day != eventToDelete.day)
            .toList();
      });
      break;
    case ActionTypes.deleteAllEvents:
      final Event eventToDelete = action.payload;

      final List<Event> eventsToDelete = state.events.values
          .expand((x) => x)
          .where((event) => event.title == eventToDelete.title)
          .toList();

      setEventsHideFlag(eventsToDelete, true);

      state.events.updateAll((key, value) {
        return value
            .where((event) => event.title != eventToDelete.title)
            .toList();
      });
      break;
    case ActionTypes.addEvent:
      final Event eventToAdd = action.payload;
      state.events.update(eventToAdd.weekFrom, (value) {
        return value..add(eventToAdd);
      });
      state.events[eventToAdd.weekFrom]!.sort();
      break;
    default:
      break;
  }
  return state;
}
