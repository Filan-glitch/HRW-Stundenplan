import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sqflite/sqflite.dart';

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
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final List<Map<String, dynamic>> result =
        await db.query('Events', where: 'HIDE_FLAG = 0');
    final Map<String, List<Event>> events = {};

    // fill empty weeks
    DateTime currentMonday = getFirstDayOfWeek(
      cleanDate(DateTime.now()),
    );

    final String? mon = await loadDownloadedRange();
    if (mon != null) {
      final DateTime lastFetchedWeek = cleanDate(formatter.parse(mon));

      while (!lastFetchedWeek.isBefore(currentMonday)) {
        events[formatter.format(currentMonday)] = [];
        currentMonday = currentMonday.add(const Duration(days: 7));
      }
    }

    for (Map<String, dynamic> item in result) {
      final DateTime eventDate = formatter
          .parse(item['WeekFrom'])
          .add(Duration(days: int.parse(item['Weekday'])));

      final DateTime today = DateTime.now();
      // Remove past events
      if (eventDate.year < today.year ||
          eventDate.year == today.year && eventDate.month < today.month) {
        await db.delete(
          'Events',
          where: 'EventID = ?',
          whereArgs: [item['EventID']],
        );
        continue;
      }

      final Event event = Event.fromDB(item);

      // Add event to list
      if (!events.containsKey(event.weekFrom)) {
        events[item['WeekFrom']] = [];
      }
      events[event.weekFrom]!.add(event);
    }

    for (String date in events.keys) {
      store.dispatch(
        Action(
          ActionTypes.setEvents,
          payload: {
            'date': date,
            'events': events[date],
          },
        ),
      );
    }

    //remove past hidden events
    final List<Event> hiddenEvents = await getHiddenEvents();
    final DateTime now = DateTime.now();
    for (Event event in hiddenEvents) {
      final DateTime eventDate =
          formatter.parse(event.weekFrom).add(Duration(days: event.day.value));
      if (eventDate.year < now.year ||
          eventDate.year == now.year && eventDate.month < now.month) {
        await db.delete(
          'Events',
          where: 'EventID = ?',
          whereArgs: [event.eventID],
        );
      }
    }

    await db.close();
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<void> writeDataToStorage() async {
  try {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final Database db = await openDB();

    await db.delete('Events', where: 'HIDE_FLAG = 0');

    final DateTime? lastFetchedWeek = store.state.events.keys
        .map((date) => formatter.parse(date))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    for (Event event in store.state.events.values.expand((x) => x)) {
      // Makes a db call, where event gets inserted into the db, but when already exists it gets update all of its columns except the HIDE_FLAG
      await db.insert(
        'Events',
        event.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    if (lastFetchedWeek != null) {
      await writeDownloadedRange(formatter.format(lastFetchedWeek));
    }

    store.dispatch(Action(ActionTypes.setLastUpdated,
        payload: formatter.format(DateTime.now())));
    writeLastUpdated();

    await db.close();
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
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
        .where((event) =>
            cleanDate(DateFormat('dd/MM/yyyy').parse(event.weekFrom))
                .isAtSameMomentAs(monday) &&
            event.day == Weekday.getByValue(now.weekday - 1) &&
            event.start.totalMinutes >= rangeStart &&
            event.start.totalMinutes <= rangeEnd)
        .toList();
  } finally {
    await db.close();
  }
}

Future<void> setEventsHideFlag(List<Event> events, bool value) async {
  final Database db = await openDB();
  await db.transaction((txn) async {
    for (var event in events) {
      await txn.update(
        'Events',
        {'HIDE_FLAG': value ? 1 : 0},
        where: 'EventID = ?',
        whereArgs: [event.eventID],
      );
    }
  });
  await db.close();
}

Future<List<Event>> getHiddenEvents() async {
  final db = await openDB();
  try {
    final result = await db.query('Events', where: 'HIDE_FLAG = 1');
    return result.map(Event.fromDB).toList();
  } finally {
    await db.close();
  }
}