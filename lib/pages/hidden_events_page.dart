import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:timetable/model/redux/app_state.dart';
import 'package:timetable/model/redux/actions.dart' as redux;
import 'package:timetable/model/redux/store.dart';
import 'package:timetable/widgets/page_wrapper.dart';

import '../model/event.dart';

class HiddenEventsPage extends StatelessWidget {
  const HiddenEventsPage({super.key});

  void showEvent(Event event) {
    final List<Event> events = store.state.events;
    events[events.indexOf(event)].hidden = false;
    store.dispatch(redux.Action(
      redux.ActionTypes.setEvents,
      payload: events,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Ausgeblendet',
      simpleDesign: true,
      body: StoreConnector<AppState, AppState>(
          builder: (context, state) {
            final List<Event> hiddenEvents =
                state.events.where((event) => event.hidden).toList();

            if (hiddenEvents.isEmpty) {
              return const Center(
                child: Text('Keine Veranstaltungen ausgeblendet'),
              );
            }
            return ListView.builder(
              itemCount: hiddenEvents.length,
              itemBuilder: (context, index) {
                final Event event = hiddenEvents[index];

                if (event.weekFrom == null) return Container();

                final String realDate = DateFormat('dd.MM.yyyy').format(
                  event.weekFrom!.add(Duration(days: event.day.value)),
                );

                return ListTile(
                  title: Text(event.title),
                  subtitle: Text('$realDate ${event.start} - ${event.end}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () => showEvent(event),
                  ),
                );
              },
            );
          },
          converter: (store) => store.state),
    );
  }
}
