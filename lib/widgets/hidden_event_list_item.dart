import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/model/date_time_calculator.dart';
import 'package:timetable/model/redux/actions.dart' as redux;
import 'package:timetable/service/db/events.dart';

import '../model/event.dart';
import '../model/redux/store.dart';

class HiddenEventListItem extends StatefulWidget {
  final Event event;

  const HiddenEventListItem({super.key, required this.event});

  @override
  State<HiddenEventListItem> createState() => _HiddenEventListItemState();
}

class _HiddenEventListItemState extends State<HiddenEventListItem> {
  bool _isHidden = true;
  bool _isChanging = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isHidden ? 0.4 : 1.0,
      child: ListTile(
        title: Text(widget.event.title),
        subtitle: Text(
            '${DateFormat('dd/MM/yyyy').format(cleanDate(DateFormat('dd/MM/yyyy').parse(widget.event.weekFrom)).add(Duration(days: widget.event.day.value)))} ${widget.event.start} - ${widget.event.end}'),
        trailing: IconButton(
          icon: _isChanging
              ? const CircularProgressIndicator()
              : Icon(_isHidden ? Icons.visibility_off : Icons.visibility),
          onPressed: () async {
            setState(() {
              _isChanging = true;
            });
            await setEventsHideFlag([widget.event], !_isHidden);
            if (_isHidden) {
              store.dispatch(
                redux.Action(
                  redux.ActionTypes.addEvent,
                  payload: widget.event,
                ),
              );
            } else {
              store.dispatch(
                redux.Action(
                  redux.ActionTypes.deleteEvent,
                  payload: widget.event,
                ),
              );
            }
            setState(() {
              _isHidden = !_isHidden;
              _isChanging = false;
            });
          },
        ),
      ),
    );
  }
}
