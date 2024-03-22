import 'package:flutter/material.dart';

import '../widgets/dialog_wrapper.dart';

enum HideEventDialogResult { only_this, all_at_this_time, all, cancel }

class HideEventDialog extends StatelessWidget {
  final String event_name;

  const HideEventDialog({super.key, required this.event_name});

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: 'Veranstaltung ausblenden',
      children: [
        Text('Welche Veranstaltungen von $event_name möchtest du ausblenden?'),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, HideEventDialogResult.only_this);
              },
              child: const Text('Nur diese Veranstaltung'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, HideEventDialogResult.all_at_this_time);
              },
              child: const Text('Alle zu dieser Zeit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, HideEventDialogResult.all);
              },
              child: const Text('Alle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, HideEventDialogResult.cancel);
              },
              child: const Text('Abbrechen'),
            ),
          ],
        )
      ],
    );
  }
}
