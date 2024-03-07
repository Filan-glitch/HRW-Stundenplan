import 'package:flutter/material.dart';
import 'package:timetable/model/event.dart';

import '../widgets/dialog_wrapper.dart';

enum EventDeleteDialogResult { only_this, all_at_this_time, all, cancel }

class EventDeleteDialog extends StatelessWidget {
  final String event_name;
  const EventDeleteDialog({super.key, required this.event_name});

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: '$event_name löschen?',
      children: [
        const Text('Welche Veranstaltungen möchtest du löschen?'),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, EventDeleteDialogResult.only_this);
              },
              child: const Text('Nur diese'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, EventDeleteDialogResult.all);
              },
              child: const Text('Alle zu dieser Zeit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, EventDeleteDialogResult.all);
              },
              child: const Text('Alle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, EventDeleteDialogResult.cancel);
              },
              child: const Text('Abbrechen'),
            ),
          ],
        )
      ],
    );
  }
}
