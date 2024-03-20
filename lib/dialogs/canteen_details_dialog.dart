import 'package:flutter/material.dart';
import 'package:timetable/model/graphql/canteens/canteen.dart';
import 'package:timetable/model/graphql/canteens/timeperiod.dart';
import 'package:timetable/widgets/dialog_wrapper.dart';

class CanteenDetailsDialog extends StatelessWidget {
  const CanteenDetailsDialog(this.canteen, {super.key});

  final Canteen canteen;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<TimePeriod>> openingHours = {
      'Mo': canteen.openingHours?.monday ?? [],
      'Di': canteen.openingHours?.tuesday ?? [],
      'Mi': canteen.openingHours?.wednesday ?? [],
      'Do': canteen.openingHours?.thursday ?? [],
      'Fr': canteen.openingHours?.friday ?? [],
      'Sa': canteen.openingHours?.saturday ?? [],
      'So': canteen.openingHours?.sunday ?? [],
    };

    return DialogWrapper(
      title: canteen.name ?? 'Beilage',
      children: [
        Text(canteen.address ?? ''),
        const SizedBox(height: 20),
        const Text(
          'Öffnungszeiten:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ...openingHours.entries.map((e) {
          final String hourString = e.value.length == 0
              ? 'Geschlossen'
              : e.value.map((e) => '${e.opens} - ${e.closes}').join(', ');
          return Text(
            '${e.key}: $hourString',
          );
        }).toList(),
      ],
    );
  }
}
