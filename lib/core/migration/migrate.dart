import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'v152.dart' as v152;

final List<Future<void> Function()?> _migrations = [
  null, // migration to version code 1 from previous
  null, // migration to version code 2 from previous
  null, // migration to version code 3 from previous
  null, // migration to version code 4 from previous
  v152.migrate, // migration to version code 5 from previous
  null, // migration to version code 6 from previous
  null, // migration to version code 7 from previous
  null, // migration to version code 8 from previous
  null, // migration to version code 9 from previous
  null, // migration to version code 10 from previous
  null, // migration to version code 11 from previous
  null, // migration to version code 12 from previous
  null, // migration to version code 13 from previous
];

Future<void> performMigration() async {
  final String pubspec = await rootBundle.loadString('pubspec.yaml');
  final int appVersionCode =
      int.parse(loadYaml(pubspec)['version'].split('+')[1]);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final int previousVersionCode = prefs.getInt('versionCode') ?? 0;

  for (int i = previousVersionCode; i < appVersionCode; i++) {
    final Future<void> Function()? migration = _migrations[i];
    if (migration == null) continue;
    await migration();
  }
  prefs.setInt('versionCode', appVersionCode);
}
