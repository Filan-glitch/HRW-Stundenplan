import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timetable/widgets/dialog_wrapper.dart';

class CollisionDialog extends StatelessWidget {
  const CollisionDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DialogWrapper(
      title: 'Kollision erkannt!',
      children: [
        Text(
            'Diese Veranstaltung überschneidet sich zeitlich mit einer anderen Veranstaltung!')
      ],
    );
  }
}
