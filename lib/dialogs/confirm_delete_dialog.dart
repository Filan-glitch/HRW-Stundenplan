import 'package:flutter/material.dart';

import '../widgets/dialog_wrapper.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key, required this.deleteMultiple});

  final bool deleteMultiple;

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title:
          deleteMultiple ? 'Veranstaltungen löschen' : 'Veranstaltung löschen',
      children: [
        Text(
          deleteMultiple
              ? 'Sollen diese Veranstaltungen gelöscht werden?'
              : 'Soll diese Veranstaltung gelöscht werden?',
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nein'),
            ),
          ],
        ),
      ],
    );
  }
}
