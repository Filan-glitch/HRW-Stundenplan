import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/dialogs/collision_dialog.dart';
import 'package:timetable/pages/edit_event_page.dart';

import '../model/date_time_calculator.dart';
import '../model/event.dart';
import '../model/mode.dart';
import '../model/redux/app_state.dart';

class ListItem extends StatefulWidget {
  const ListItem({required this.event, super.key});

  final Event event;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          final DateTime currentMonday = getFirstDayOfWeek(
            cleanDate(DateTime.now()),
          );

          final bool isCurrentWeek =
              state.currentWeek.day == currentMonday.day &&
                  state.currentWeek.month == currentMonday.month &&
                  state.currentWeek.year == currentMonday.year;

          final DateTime now = DateTime.now();
          final DateTime start = DateTime(
            state.currentWeek.year,
            state.currentWeek.month,
            state.currentWeek.day + widget.event.day.value,
            widget.event.start.hour,
            widget.event.start.minute,
          );

          final DateTime end = DateTime(
            state.currentWeek.year,
            state.currentWeek.month,
            state.currentWeek.day + widget.event.day.value,
            widget.event.end.hour,
            widget.event.end.minute,
          );

          Widget? timeIndicatorWidget;
          if (now.isBefore(start) && start.difference(now).inMinutes <= 90) {
            timeIndicatorWidget = Text(
              'Beginnt in ${start.difference(now).inMinutes} Minuten',
            );
          } else if (now.isBefore(end) && now.isAfter(start) ||
              now.isAtSameMomentAs(start)) {
            timeIndicatorWidget = Text(
              'Läuft noch ${end.difference(now).inMinutes} Minuten',
            );
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventPage(
                    event: widget.event,
                  ),
                ),
              );
            },
            child: Opacity(
              opacity:
                  widget.event.state == Mode.done && isCurrentWeek ? 0.6 : 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.background,
                    widget.event.state == Mode.active && isCurrentWeek
                        ? 0.9
                        : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: widget.event.state == Mode.active && isCurrentWeek
                      ? 15.0
                      : 10.0,
                ),
                margin: EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal:
                        widget.event.state == Mode.active && isCurrentWeek
                            ? 5.0
                            : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          ((widget.event.collision == true) ? 0.7 : 0.80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.event.start} - ${widget.event.end}',
                          ),
                          Text(
                            widget.event.room,
                          ),
                          if (timeIndicatorWidget != null) timeIndicatorWidget,
                        ],
                      ),
                    ),
                    if (widget.event.collision == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const CollisionDialog(),
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.exclamationmark_triangle_fill,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
