import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetable/dialogs/confirm_delete_dialog.dart';
import 'package:timetable/model/date_time_calculator.dart';
import 'package:timetable/model/event.dart';
import 'package:timetable/model/redux/actions.dart' as redux;
import 'package:timetable/model/redux/store.dart';
import 'package:timetable/model/time.dart';
import 'package:timetable/model/weekday.dart';
import 'package:timetable/service/db/events.dart';
import 'package:timetable/widgets/page_wrapper.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({this.event, super.key});

  final Event? event;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController abbreviationController;
  late final TextEditingController roomController;

  late TimeOfDay startTime;
  late TimeOfDay endTime;

  late Weekday weekday = Weekday.monday;

  late DateTime firstDate;
  late DateTime lastDate;

  bool _shouldUpdateSingleEvent = true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController.fromValue(
      TextEditingValue(text: widget.event?.title ?? ''),
    );
    abbreviationController = TextEditingController.fromValue(
      TextEditingValue(text: widget.event?.abbreviation ?? ''),
    );
    roomController = TextEditingController.fromValue(
      TextEditingValue(text: widget.event?.room ?? ''),
    );

    startTime = widget.event == null
        ? TimeOfDay(hour: DateTime.now().hour, minute: 0)
        : TimeOfDay(
            hour: widget.event!.start.hour,
            minute: widget.event!.start.minute,
          );

    endTime = widget.event == null
        ? TimeOfDay(hour: DateTime.now().hour + 2, minute: 0)
        : TimeOfDay(
            hour: widget.event!.end.hour,
            minute: widget.event!.end.minute,
          );

    weekday = widget.event?.day ?? Weekday.monday;

    firstDate = cleanDate(DateTime.now());
    lastDate = firstDate.add(const Duration(days: 30));
  }

  List<DateTime> getDatesOfNewEvent() {
    final DateTime firstWeek = getFirstDayOfWeek(firstDate);

    return [
      for (DateTime date = firstWeek.add(Duration(days: weekday.value));
          date.isBefore(lastDate);
          date = date.add(const Duration(days: 7)))
        if (date.weekday - 1 == weekday.value) date
    ]..removeWhere(
        (element) => element.isBefore(firstDate) || element.isAfter(lastDate));
  }

  bool _timeValidator() {
    return startTime.hour * 60 + startTime.minute <
        endTime.hour * 60 + endTime.minute;
  }

  bool _dateRangeValidator() {
    return firstDate.isBefore(lastDate);
  }

  bool isFormValid() {
    return _formKey.currentState!.validate() && _timeValidator();
  }

  void createNewEvents() {
    if (widget.event != null) return;
    if (!isFormValid()) return;
    final List<DateTime> dates = getDatesOfNewEvent();
    if (dates.isEmpty) return;

    dates.map((date) {
      return Event(
        title: titleController.text,
        abbreviation: abbreviationController.text,
        start: Time(startTime.hour, startTime.minute),
        end: Time(endTime.hour, endTime.minute),
        room: roomController.text,
        day: weekday,
        weekFrom: date,
        mode: EventMode.customEvent,
      );
    }).forEach((event) {
      final List<Event> events = store.state.events;
      events.add(event);
      store.dispatch(redux.setEvents(events));
    });

    writeDataToStorage();
    Navigator.pop(context);
  }

  void updateSingleEvent() {
    if (widget.event == null) return;
    if (!_shouldUpdateSingleEvent) return;
    if (!isFormValid()) return;
    if (!store.state.events.contains(widget.event)) return;

    final List<Event> events = store.state.events;

    events[events.indexOf(widget.event!)] = widget.event!.copyWith(
      title: titleController.text,
      abbreviation: abbreviationController.text,
      start: Time(startTime.hour, startTime.minute),
      end: Time(endTime.hour, endTime.minute),
      room: roomController.text,
      day: weekday,
      mode: widget.event!.mode == EventMode.customEvent
          ? EventMode.customEvent
          : EventMode.edited,
    );

    store.dispatch(redux.setEvents(events));

    writeDataToStorage();
    Navigator.pop(context);
  }

  void updateAllEvents() {
    if (widget.event == null) return;
    if (_shouldUpdateSingleEvent) return;
    if (!isFormValid()) return;

    final List<Event> updatedEvents = store.state.events.map((event) {
      // map each item of the day
      if (event.title == widget.event!.title &&
          event.start == widget.event!.start &&
          event.end == widget.event!.end &&
          event.day == widget.event!.day) {
        // is same event
        final EventMode newMode = event.mode == EventMode.customEvent
            ? EventMode.customEvent
            : EventMode.edited;

        final newEvent = event.copyWith(
          title: titleController.text,
          abbreviation: abbreviationController.text,
          start: Time(startTime.hour, startTime.minute),
          end: Time(endTime.hour, endTime.minute),
          room: roomController.text,
          day: weekday,
          mode: newMode,
        );
        return newEvent;
      } else {
        // other event -> do not update
        return event;
      }
    }).toList();

    store.dispatch(redux.setEvents(updatedEvents));

    writeDataToStorage();
    Navigator.pop(context);
  }

  void deleteSingleEvent() {
    if (widget.event == null) return;
    if (!_shouldUpdateSingleEvent) return;
    if (widget.event!.mode != EventMode.customEvent) return;
    if (!store.state.events.contains(widget.event)) return;

    final events = store.state.events;
    events.remove(widget.event);

    store.dispatch(redux.setEvents(events));

    writeDataToStorage();
    Navigator.pop(context);
  }

  void deleteAllEvents() {
    if (widget.event == null) return;
    if (_shouldUpdateSingleEvent) return;
    if (widget.event!.mode != EventMode.customEvent) return;

    final List<Event> updatedEvents = store.state.events
        .where(
          (event) => !(event.title == widget.event!.title &&
              event.start == widget.event!.start &&
              event.end == widget.event!.end &&
              event.day == widget.event!.day),
        )
        .toList();

    store.dispatch(redux.setEvents(updatedEvents));

    writeDataToStorage();
    Navigator.pop(context);
  }

  void hideSingleEvent() {
    if (widget.event == null) return;
    if (!_shouldUpdateSingleEvent) return;
    if (widget.event!.mode == EventMode.customEvent) return;
    if (!store.state.events.contains(widget.event)) return;

    final List<Event> updatedEvents = store.state.events;
    updatedEvents[updatedEvents.indexOf(widget.event!)] =
        widget.event!.copyWith(hidden: true);

    store.dispatch(redux.setEvents(updatedEvents));

    writeDataToStorage();
    Navigator.pop(context);
  }

  void hideAllEvent() {
    if (widget.event == null) return;
    if (_shouldUpdateSingleEvent) return;
    if (widget.event!.mode == EventMode.customEvent) return;

    final List<Event> updatedEvents = store.state.events.map((event) {
      // map each item of the day
      if (event.title == widget.event!.title &&
          event.start == widget.event!.start &&
          event.end == widget.event!.end &&
          event.day == widget.event!.day) {
        return event.copyWith(hidden: true);
      } else {
        // other event -> do not update
        return event;
      }
    }).toList();

    store.dispatch(redux.setEvents(updatedEvents));

    writeDataToStorage();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String startTimeString =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final String endTimeString =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    final String firstDateString = dateFormat.format(firstDate);
    final String lastDateString = dateFormat.format(lastDate);

    final List<String> dates =
        getDatesOfNewEvent().map((e) => dateFormat.format(e)).toList();

    return PageWrapper(
      title: widget.event == null
          ? 'Neue Veranstaltung'
          : 'Veranstaltung bearbeiten',
      simpleDesign: true,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 20,
                  right: 20,
                  bottom: 80,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titel'),
                        validator: (value) {
                          if (value!.trim().isEmpty)
                            return 'Bitte geben Sie einen Titel ein';
                          else
                            return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: abbreviationController,
                                enabled: widget.event == null,
                                style: widget.event == null
                                    ? null
                                    : const TextStyle(color: Colors.grey),
                                decoration: const InputDecoration(
                                  labelText: 'Abkürzung',
                                ),
                                validator: (value) {
                                  if (value!.trim().isEmpty)
                                    return 'Bitte geben Sie eine Abkürzung ein';
                                  else
                                    return null;
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: roomController,
                                decoration: const InputDecoration(
                                  labelText: 'Raum',
                                ),
                                validator: (value) {
                                  if (value!.trim().isEmpty)
                                    return 'Bitte geben Sie einen Raum ein';
                                  else
                                    return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                ).then(
                                  (value) => setState(() {
                                    startTime = value ?? startTime;
                                  }),
                                );
                              },
                              child: Text(
                                'Start: $startTimeString',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const Text(
                              '-',
                              style: const TextStyle(fontSize: 18),
                            ),
                            TextButton(
                              onPressed: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: endTime,
                                ).then(
                                  (value) => setState(() {
                                    endTime = value ?? endTime;
                                  }),
                                );
                              },
                              child: Text(
                                'Ende: $endTimeString',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_timeValidator())
                        const Text(
                          'Die Startzeit muss vor der Endzeit liegen',
                          style: const TextStyle(color: Colors.red),
                        ),
                      // wochentag (dropdown)
                      DropdownButtonFormField<Weekday>(
                        decoration: const InputDecoration(
                          labelText: 'Wochentag',
                        ),
                        isExpanded: true,
                        hint: const Text('Wochentag'),
                        value: weekday,
                        items: Weekday.values
                            .where((e) =>
                                e != Weekday.saturday && e != Weekday.sunday)
                            .map((e) => DropdownMenuItem(
                                  child: Text(e.text),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (weekday) {
                          setState(() {
                            this.weekday = weekday ?? this.weekday;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // erster & letzter tag (date picker)
                      if (widget.event == null) ...[
                        const Text(
                          'Termine in folgendem Zeitraum anlegen:',
                          style: const TextStyle(fontSize: 15),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: firstDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then(
                                  (value) => setState(() {
                                    firstDate = cleanDate(value ?? firstDate);
                                  }),
                                );
                              },
                              child: Text(
                                'Von: ${firstDateString}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: lastDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                ).then(
                                  (value) => setState(() {
                                    lastDate = cleanDate(value ?? lastDate);
                                  }),
                                );
                              },
                              child: Text(
                                'Bis: ${lastDateString}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        if (!_dateRangeValidator())
                          const Text(
                            'Der erste Tag muss vor dem letzten Tag liegen',
                            style: const TextStyle(color: Colors.red),
                          ),
                      ],
                      const SizedBox(height: 10),
                      // Termin anlegen
                      if (widget.event == null)
                        ElevatedButton(
                          onPressed: dates.isEmpty ? null : createNewEvents,
                          child: const Text('Termine anlegen'),
                        ),
                      if (widget.event != null)
                        // Termin speichern
                        ...[
                        const SizedBox(
                          height: 20.0,
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),
                              ),
                              onPressed: _shouldUpdateSingleEvent
                                  ? updateSingleEvent
                                  : updateAllEvents,
                              child: Text(
                                _shouldUpdateSingleEvent
                                    ? 'Speichern'
                                    : 'Alle speichern',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (widget.event?.mode == EventMode.customEvent)
                              ElevatedButton(
                                onPressed: () {
                                  showDialog<bool>(
                                    context: context,
                                    builder: (context) => ConfirmDeleteDialog(
                                      deleteMultiple: !_shouldUpdateSingleEvent,
                                    ),
                                  ).then((shouldDelete) {
                                    if (shouldDelete == true) {
                                      if (_shouldUpdateSingleEvent) {
                                        deleteSingleEvent();
                                      } else {
                                        deleteAllEvents();
                                      }
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: Text(
                                  _shouldUpdateSingleEvent
                                      ? 'Löschen'
                                      : 'Alle löschen',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (widget.event?.mode != EventMode.customEvent)
                              ElevatedButton(
                                onPressed: _shouldUpdateSingleEvent
                                    ? hideSingleEvent
                                    : hideAllEvent,
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 5,
                                    ),
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                      side: const BorderSide(
                                          color: Colors.red, width: 2),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                ),
                                child: Text(
                                  _shouldUpdateSingleEvent
                                      ? 'Ausblenden'
                                      : 'Alle ausblenden',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Abbrechen
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Abbrechen'),
                      ),

                      if (widget.event == null && dates.isEmpty)
                        const Text(
                          'Keine Termine vorhanden',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.red,
                          ),
                        ),
                      if (widget.event == null && dates.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Termine: ' + dates.join(', '),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
            if (widget.event != null)
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SegmentedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.selected)
                                ? const Color(0xFF009fe3)
                                : Colors.transparent;
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.selected) ||
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                ? Colors.white
                                : Colors.black;
                          },
                        ),
                        // disable border
                        side: MaterialStateProperty.all(
                          BorderSide(
                              color: Colors.grey.withOpacity(0.2), width: 2),
                        ),
                      ),
                      showSelectedIcon: false,
                      segments: const <ButtonSegment<bool>>[
                        ButtonSegment<bool>(
                          label: const Text('Dieser Termin'),
                          value: true,
                        ),
                        ButtonSegment<bool>(
                          label: const Text('Alle Termine'),
                          value: false,
                        ),
                      ],
                      selected: {_shouldUpdateSingleEvent},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _shouldUpdateSingleEvent = selected.first;
                        });
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
