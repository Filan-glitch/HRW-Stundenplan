import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/weekday.dart';
import '../pages/login_page.dart';
import '../service/db/events.dart';
import '../service/network_fetch.dart';
import 'break.dart';
import 'empty_schedule.dart';
import 'list_item.dart';

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({
    required this.weekday,
    super.key,
  });

  final Weekday weekday;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          final String key = formatter.format(state.currentWeek);
          List<Event> events = [];

          if (state.events.containsKey(key)) {
            events = state.events[key]!
                .where((element) => element.day == weekday)
                .toList()
              ..sort();
          } else {
            LoginPage.performLogin(onLoginSuccess: () async {
              await loadWeekInterval(
                start: store.state.currentWeek,
              );
              await writeDataToStorage();
            });
          }

          if (events.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const EmptyScheduleWidget(),
              ),
            );
          }

          if (state.events.containsKey(key)) {
            events = state.events[key]!
                .where((element) => element.day == weekday)
                .toList()
              ..sort();
            checkForCollisions(events);
          }

          return ListView.builder(
              itemCount: events.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                // display break widget, if there is a time span longer than 15 minutes
                if (events.length > index + 1 &&
                    events[index + 1].start.totalMinutes -
                            events[index].end.totalMinutes >=
                        15) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        event: events[index],
                      ),
                      const BreakWidget()
                    ],
                  );
                } else {
                  return ListItem(
                    event: events[index],
                  );
                }
              });
        },
      );
    });
  }
}

void checkForCollisions(List<Event> events) {
  events.forEach((element) {
    element.collision = false;
  });
  events.asMap().forEach((i, event1) {
    events.sublist(i + 1).forEach((event2) {
      if (event1.isCollidingWith(event2)) {
        event1.collision = true;
        event2.collision = true;
      }
    });
  });
}