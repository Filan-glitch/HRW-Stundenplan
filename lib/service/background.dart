import 'dart:async';

import 'package:workmanager/workmanager.dart';


Future<void> registerBackgroundService() {
  return Workmanager().registerPeriodicTask(
    'TIMETABLE_REMINDER_TASK',
    'Terminerinnerung',
    tag: 'TIMETABLE_REMINDER_TASK',
    frequency: const Duration(minutes: 15),
  );
}

Future<void> unregisterBackgroundService() {
  return Workmanager().cancelByTag('TIMETABLE_REMINDER_TASK');
}
