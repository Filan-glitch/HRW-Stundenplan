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

Future<void> writeGradesToStorage() async {
  try {
    final Database db = await openDB();

    await db.delete('Grades', where: null);

    for (Module module in store.state.modules) {
      await db.insert(
        'Grades',
        module.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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
