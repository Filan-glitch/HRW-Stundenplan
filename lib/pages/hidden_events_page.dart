import 'package:flutter/material.dart';
import 'package:timetable/widgets/hidden_event_list_item.dart';
import 'package:timetable/widgets/page_wrapper.dart';

import '../model/event.dart';

class HiddenEventsPage extends StatelessWidget {
  final List<Event> events;

  const HiddenEventsPage({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Ausgeblendet',
      body: events.isEmpty
          ? const Center(
              child: Text('Keine Veranstaltungen ausgeblendet'),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return HiddenEventListItem(
                  event: events[index],
                );
              },
            ),
      simpleDesign: true,
    );
  }
}
