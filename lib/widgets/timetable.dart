import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/weekday.dart';
import '../pages/login_page.dart';
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
          late final List<Event> events;
          if (state.downloadedUntil == null ||
              state.currentWeek.isAfter(state.downloadedUntil!)) {
            LoginPage.performLogin(onLoginSuccess: () async {
              await loadWeekInterval(
                start: store.state.currentWeek,
              );
            });

            events = [];
          } else {
            events = state.events
                .where((element) =>
                    element.weekFrom?.isAtSameMomentAs(state.currentWeek) ??
                    false)
                .where((element) => element.day == weekday)
                .where((element) => !element.hidden)
                .toList();

            events.sort(
              (a, b) => a.start.totalMinutes.compareTo(b.start.totalMinutes),
            );

            checkForCollisions(events);
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

          return ListView.builder(
              itemCount: events.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                events.sort();
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
