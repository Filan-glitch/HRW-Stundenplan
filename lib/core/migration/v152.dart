import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

Future<void> migrate() async {
  final String path = join(await getDatabasesPath(), 'timetable.db');
  await deleteDatabase(path);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('downloadedRange');
  prefs.remove('args');
  prefs.remove('cnsc');
}
