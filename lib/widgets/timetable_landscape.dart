import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/model/event.dart';
import 'package:timetable/model/redux/app_state.dart';
import 'package:timetable/model/weekday.dart';
import 'package:timetable/pages/login_page.dart';
import 'package:timetable/service/network_fetch.dart';
import 'package:timetable/widgets/break.dart';
import 'package:timetable/widgets/empty_schedule.dart';
import 'package:timetable/widgets/list_item.dart';

class TimetableLandscape extends StatelessWidget {
  const TimetableLandscape({super.key, required this.weekday});

  final Weekday weekday;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            if (state.downloadedUntil == null ||
                state.currentWeek.isAfter(state.downloadedUntil!)) {
              LoginPage.performLogin(onLoginSuccess: () async {
                await loadWeekInterval(
                  start: state.currentWeek,
                );
              });

              return Container();
            }

            final List<Event> eventsInWeek = state.events
                .where((element) =>
                    element.weekFrom?.isAtSameMomentAs(state.currentWeek) ??
                    false)
                .toList();

            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (Weekday day in Weekday.values.where((element) =>
                      element != Weekday.saturday && element != Weekday.sunday))
                    Builder(
                      builder: (context) {
                        final List<Event> events = eventsInWeek
                            .where((element) => element.day == day)
                            .where((element) => !element.hidden)
                            .toList();

                        events.sort(
                          (a, b) => a.start.totalMinutes
                              .compareTo(b.start.totalMinutes),
                        );
                        checkForCollisions(events);

                        return Container(
                          width: 400,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                day.text,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20.0,
                                ),
                              ),
                              Expanded(
                                child: events.length == 0
                                    ? const EmptyScheduleWidget(sunSize: 70.0)
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: events.length,
                                        itemBuilder: (context, index) {
                                          // display break widget, if there is a time span longer than 15 minutes
                                          if (events.length > index + 1 &&
                                              events[index + 1]
                                                          .start
                                                          .totalMinutes -
                                                      events[index]
                                                          .end
                                                          .totalMinutes >=
                                                  15) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListItem(
                                                  event: events[index],
                                                  maxWidth: 300,
                                                ),
                                                const BreakWidget()
                                              ],
                                            );
                                          } else {
                                            return ListItem(
                                              event: events[index],
                                              maxWidth: 300,
                                            );
                                          }
                                        },
                                      ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
