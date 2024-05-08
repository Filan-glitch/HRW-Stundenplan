import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable/core/toast.dart';

import '../../model/date_time_calculator.dart';
import '../../model/event.dart';
import '../../model/redux/actions.dart';
import '../../model/redux/store.dart';
import '../../model/weekday.dart';
import '../storage.dart';
import 'connection.dart';

Future<void> loadDataFromStorage() async {
  try {
    final Database db = await openDB();
    final List<Map<String, dynamic>> dbResult = await db.query('Events');

    final List<Event> events = [];
    final DateTime firstDayOfCurrentWeek = getFirstDayOfWeek(DateTime.now());

    for (Map<String, dynamic> raw in dbResult) {
      final Event event = Event.fromDB(raw);

      // check if difference between weekFrom and current week is more then 14 days
      bool shouldDelete = true;
      if (event.weekFrom == null)
        shouldDelete = true;
      else {
        shouldDelete =
            event.weekFrom!.difference(firstDayOfCurrentWeek).inDays < -14;
      }

      if (shouldDelete) {
        await db.delete(
          'Events',
          where: 'EventID = ?',
          whereArgs: [event.eventID],
        );
      } else {
        events.add(event);
      }
    }

    store.dispatch(setEvents(events));

    await db.close();
  } catch (e, stackTrace) {
    showErrorToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<void> writeDataToStorage() async {
  try {
    final Database db = await openDB();

    // clean db
    await db.delete('Events');

    // write items to db
    final List<dynamic> dbEntries =
        store.state.events.map((e) => e.toDB()).toList();

    try {
      for (var e in dbEntries) {
        await db.insert(
          'Events',
          e,
          // conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print(e);
    }

    store.dispatch(setLastUpdated(DateTime.now()));
    writeLastUpdated();

    await db.close();
  } catch (e, stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
  }
}

Future<List<Event>> getNextEvents() async {
  final db = await openDB();
  final now = DateTime.now();
  final rangeStart = now.hour * 60 + now.minute + 7;
  final rangeEnd = now.hour * 60 + now.minute + 23;
  final monday = getFirstDayOfWeek(now);

  try {
    final result = await db.query('Events', where: 'HIDE_FLAG = 0');
    return result
        .map(Event.fromDB)
        .where((event) => event.weekFrom != null)
        .where((event) =>
            event.weekFrom!.isAtSameMomentAs(monday) &&
            event.day == Weekday.getByValue(now.weekday - 1) &&
            event.start.totalMinutes >= rangeStart &&
            event.start.totalMinutes <= rangeEnd)
        .toList()
      ..sort((a, b) => a.start.totalMinutes - b.start.totalMinutes);
  } finally {
    await db.close();
  }
}
