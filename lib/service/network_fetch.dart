import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timetable/core/toast.dart';

import '../model/constants.dart';
import '../model/date_time_calculator.dart';
import '../model/event.dart';
import '../model/module.dart';
import '../model/redux/actions.dart';
import '../model/redux/store.dart';
import '../model/time.dart';
import '../model/weekday.dart';
import 'db/events.dart';
import 'db/grades.dart';
import 'storage.dart';

Future<void> reloadAll({bool keepEdited = true}) async {
  // clear events before reloading
  store.dispatch(setEvents(
    store.state.events
        .where((event) =>
            event.mode == EventMode.customEvent ||
            (event.mode == EventMode.edited && keepEdited))
        .toList(),
  ));

  await Future.wait([
    if (store.state.downloadedUntil != null)
      for (DateTime monday = getFirstDayOfWeek(DateTime.now());
          monday.isBefore(store.state.downloadedUntil!) ||
              monday.isAtSameMomentAs(store.state.downloadedUntil!);
          monday = monday.add(const Duration(days: 7)))
        fetchTimetableData(monday, keepEdited),
    fetchGradeData(),
    fetchAccountData()
  ]);

  store.dispatch(startTask());
  await writeDataToStorage();
  await writeGradesToStorage();
  await writeGPA();
  await writeAccount();
  await loadDataFromStorage();
  store.dispatch(stopTask());
}

Future<void> loadWeekInterval({
  DateTime? start,
  int numWeeks = 6,
  bool keepEdited = false,
}) {
  start ??= DateTime.now();

  start = getFirstDayOfWeek(
    cleanDate(start),
  );

  final List<DateTime> weeks = [
    for (int i = 0; i < numWeeks; i++) start.add(Duration(days: i * 7))
  ];

  return Future.wait(
    weeks.map((week) => fetchTimetableData(week, keepEdited)),
  ).then((_) {
    writeDataToStorage();
  });
}

Future<void> fetchTimetableData(DateTime monday, bool keepEdited) async {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  List<Event> events = [];
  try {
    if (store.state.args == null || store.state.cnsc == null) return;
    log('fetching ${formatter.format(monday)}');

    store.dispatch(startTask());
    final dom.Document body = await _fetchScheduleHTML(monday);
    events = await _parseTimetable(body, monday);

    if (store.state.downloadedUntil == null ||
        store.state.downloadedUntil!.isBefore(monday)) {
      store.dispatch(setDownloadedUntil(monday));
      writeDownloadedRange();
    }

    store.dispatch(stopTask());
  } on TimeoutException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } on SocketException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(stopTask());

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
  } finally {
    final List<Event> eventsToAdd;

    if (keepEdited) {
      final List<Event> eventsToKeep = keepEdited
          ? store.state.events
              .where((event) => event.mode == EventMode.edited)
              .where((event) => event.weekFrom != null)
              .where((event) => event.weekFrom!.isAtSameMomentAs(monday))
              .toList()
          : [];

      eventsToAdd = [];
      for (Event event in events) {
        if (!eventsToKeep.any((e) {
          return event.abbreviation == e.abbreviation &&
              event.start == e.start &&
              event.end == e.end &&
              event.day == e.day &&
              event.weekFrom?.isAtSameMomentAs(e.weekFrom ?? DateTime.now()) ==
                  true;
        })) {
          eventsToAdd.add(event);
        }
      }
    } else {
      eventsToAdd = events;
    }

    final List<Event> newEventList = [
      ...store.state.events
          .where((event) => event.weekFrom != null)
          .where((event) =>
              !event.weekFrom!.isAtSameMomentAs(monday) ||
              event.mode == EventMode.customEvent ||
              (event.mode == EventMode.edited && keepEdited))
          .toList(),
      ...eventsToAdd,
    ];

    store.dispatch(setEvents(newEventList));
  }
}

Future<void> fetchGradeData() async {
  try {
    if (store.state.args == null || store.state.cnsc == null) return;

    store.dispatch(startTask());
    final dom.Document body = await _fetchGradesHTML();
    final List<Module> modules = await _parseGrades(body);
    final double gpa = await _parseGPA(body);

    store.dispatch(setGrades(modules));
    store.dispatch(setGPA(gpa));

    store.dispatch(stopTask());
  } on TimeoutException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } on SocketException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(stopTask());

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
  }
}

Future<void> fetchAccountData() async {
  try {
    if (store.state.args == null || store.state.cnsc == null) return;

    store.dispatch(startTask());
    final dom.Document body = await _fetchAccountHTML();
    final String account = await _parseAccount(body);

    store.dispatch(setAccount(account));

    store.dispatch(stopTask());
  } on TimeoutException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } on SocketException {
    store.dispatch(stopTask());
    showErrorToast('Keine Verbindung');
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    store.dispatch(stopTask());

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
  }
}

Future<dom.Document> _fetchScheduleHTML(
  DateTime monday,
) async {
  String args = store.state.args!;
  args = args.split(',')[0];
  final http.Response registrations = await http.get(
      Uri.parse(
        "$BASE_URL?APPNAME=CampusNet&PRGNAME=SCHEDULER&ARGUMENTS=$args,-N000403,-A${monday.day.toString().padLeft(2, "0")}/${monday.month.toString().padLeft(2, "0")}/${monday.year},-A,-N1,-N0,-N1",
      ),
      headers: {
        'Cookie': 'cnsc=${store.state.cnsc}'
      }).timeout(const Duration(seconds: 10), onTimeout: () {
    throw TimeoutException('The connection has timed out.');
  });

  return html.parse(utf8.decode(registrations.bodyBytes));
}

Future<dom.Document> _fetchGradesHTML() async {
  String? args = store.state.args;
  final String? cnsc = store.state.cnsc;
  args = args?.split(',')[0];
  final http.Response registrations = await http.get(
      Uri.parse(
        '$BASE_URL?APPNAME=CampusNet&PRGNAME=STUDENT_RESULT&ARGUMENTS=$args,-N000407,-N0,-N000000000000000,-N000000000000000,-N000000000000000,-N0,-N000000000000000',
      ),
      headers: {
        'Cookie': 'cnsc=$cnsc'
      }).timeout(const Duration(seconds: 10), onTimeout: () {
    throw TimeoutException('The connection has timed out.');
  });

  final temp = _cleanString(utf8.decode(registrations.bodyBytes));
  return html.parse(temp);
}

Future<dom.Document> _fetchAccountHTML() async {
  String? args = store.state.args;
  final String? cnsc = store.state.cnsc;
  args = args?.split(',')[0];
  final http.Response registrations = await http.get(
      Uri.parse(
        '$BASE_URL?APPNAME=CampusNet&PRGNAME=PERSADDRESS&ARGUMENTS=$args,-N000426,',
      ),
      headers: {
        'Cookie': 'cnsc=$cnsc'
      }).timeout(const Duration(seconds: 10), onTimeout: () {
    throw TimeoutException('The connection has timed out.');
  });

  final temp = _cleanString(utf8.decode(registrations.bodyBytes));
  return html.parse(temp);
}

Future<List<Event>> _parseTimetable(
    dom.Document document, DateTime monday) async {
  final List<Event> events = [];
  if (!document.outerHtml.contains('Stundenplan')) {
    store.dispatch(setCredentials(null, null));
    showInfoToast('Bitte melden Sie sich erneut an');
    return [];
  }

  for (dom.Element element in document.querySelectorAll('td.appointment')) {
    final String details =
        element.querySelectorAll('.timePeriod').map((e) => e.text).join();

    final List<RegExpMatch> timePeriod =
        RegExp(r'(\d{2}):(\d{2}) - (\d{2}):(\d{2})')
            .allMatches(details)
            .toList();

    String room;

    if (element.querySelectorAll('.timePeriod a').isEmpty) {
      // Variante 1
      final allText = element.text.trim();
      final texts = allText.split('\n').map((e) => e.trim()).toList();

      if (texts.length > 1) {
        room = texts[1].replaceAll(RegExp('(d+)'), '').trim();
      } else {
        room = ''; // Für den Fall, dass das Format unerwartet ist
      }
    } else {
      // Variante 2
      room = element
          .querySelectorAll('.timePeriod a')
          .map((e) => e.text.replaceAll(RegExp('(d+)'), '').trim())
          .join(', ');
    }

    final String? title = element.querySelector('a.link')?.attributes['title'];

    // Lies den Text zwischen dem <a></a> Tag aus und speicher ihn in einer Variable abbr
    final String? abbr = element
        .querySelector('a.link')
        ?.text
        .replaceAll('\t', '')
        .replaceAll('\n', '');

    if (title == null) continue;

    final Time start = Time(
      int.tryParse(timePeriod.first.group(1) ?? '0') ?? 0,
      int.tryParse(timePeriod.first.group(2) ?? '0') ?? 0,
    );
    final Time end = Time(
      int.tryParse(timePeriod.first.group(3) ?? '0') ?? 0,
      int.tryParse(timePeriod.first.group(4) ?? '0') ?? 0,
    );

    events.add(
      Event(
        title: title.trim(),
        room: room.replaceAll(RegExp(r'\(\d+\)'), '').trim(),
        abbreviation: abbr ?? '',
        start: start,
        end: end,
        day: Weekday.getByText(element.attributes['abbr'] ?? ''),
        weekFrom: monday,
        mode: EventMode.fromDB,
      ),
    );
  }

  return events;
}

Future<List<Module>> _parseGrades(dom.Document document) async {
  if (!document.outerHtml.contains('Studienergebnisse')) {
    store.dispatch(setCredentials(null, null));
    showInfoToast('Bitte melden Sie sich erneut an');
    return [];
  }
  final List<Module> modules = [];
  for (dom.Element element in document.querySelectorAll('tr')) {
    final data = element.querySelectorAll('.tbdata');
    if (data.isEmpty) continue;

    final Module module = Module(
      identifier: data.first.text,
      title: data[1].querySelector('a')?.text ??
          data[1].text.replaceAll('\n', '').trim(),
      creditsAll: int.tryParse(data[3].text.split(',').firstOrNull ?? '0') ?? 0,
      creditsCharged:
          int.tryParse(data[4].text.split(',').firstOrNull ?? '0') ?? 0,
      grade: double.tryParse(
            data[5].text.replaceAll(',', '.'),
          ) ??
          0.0,
    );

    switch (data[6].querySelector('img')?.attributes['src']) {
      case '/img/individual/pass.gif':
        module.status = Status.passed;
        break;
      case '/img/individual/incomplete.gif':
        module.status = Status.failed;
        break;
      default:
        module.status = Status.open;
        break;
    }

    modules.add(module);
  }
  return modules;
}

Future<double> _parseGPA(dom.Document document) async {
  try {
    final data = document.querySelectorAll(
        'table.nb.list.students_results th.tbsubhead[style="text-align:right;"]');
    if (data.length > 1) {
      return double.tryParse(data[1].text.trim().replaceAll(',', '.')) ?? 0.0;
    }
  } on FormatException {
    return 0.0;
  }
  return 0.0;
}

Future<String> _parseAccount(dom.Document document) async {
  final firstName =
      _cleanString(document.querySelector('td[name="firstName"]')!.text).trim();
  final lastName =
      _cleanString(document.querySelector('td[name="middleName"]')!.text)
          .trim();
  final matriculationNumber = _cleanString(
          document.querySelector('td[name="matriculationNumber"]')!.text)
      .trim();
  return '$firstName $lastName ($matriculationNumber)';
}

String _cleanString(String input) {
  return input.replaceAll('\t', '').replaceAll('\n', '');
}
