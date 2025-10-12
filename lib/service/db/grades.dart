import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable/core/toast.dart';

import '../../model/module.dart';
import '../../model/redux/actions.dart';
import '../../model/redux/store.dart';
import 'connection.dart';

Future<void> loadGradesFromStorage() async {
  try {
    final Database db = await openDB();

    final List<Map<String, dynamic>> result = await db.query('Grades');
    final List<Module> modules = [];

    for (Map<String, dynamic> item in result) {
      modules.add(Module.fromDB(item));
    }

    store.dispatch(setGrades(modules));

    await db.close();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
  }
}

Future<void> writeGradesToStorage({bool isGuest = false}) async {
  try {
    final Database db = await openDB();
    await db.delete('Grades', where: null);
    if (isGuest) {
      // Beispielmodule für Gastmodus, korrektes DB-Format
      final guestModules = [
        Module(
          identifier: 'GUEST-01',
          title: 'Beispielmodul 1',
          grade: 1.7,
          creditsAll: 6,
          creditsCharged: 6,
          status: Status.passed,
        ),
        Module(
          identifier: 'GUEST-02',
          title: 'Beispielmodul 2',
          grade: 5.0,
          creditsAll: 3,
          creditsCharged: 0,
          status: Status.failed,
        ),
      ];
      final batch = db.batch();
      for (var module in guestModules) {
        batch.insert(
          'Grades',
          module.toDB(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } else {
      final batch = db.batch();
      for (Module module in store.state.modules) {
        batch.insert(
          'Grades',
          module.toDB(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
    await db.close();
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
    showErrorToast('Es ist ein Fehler aufgetreten');
  }
}
