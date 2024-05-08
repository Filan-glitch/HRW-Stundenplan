import 'package:advanced_in_app_review/advanced_in_app_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:timetable/pages/edit_event_page.dart';

import '../dialogs/changelog_dialog.dart';
import '../dialogs/confirm_refresh_dialog.dart';
import '../model/date_time_calculator.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/timetable_view.dart';
import '../model/weekday.dart';
import '../service/network_fetch.dart';
import '../widgets/month_overview.dart';
import '../widgets/page_wrapper.dart';
import '../widgets/timetable.dart';
import '../widgets/week_overview.dart';
import '../widgets/week_selector.dart';
import '../widgets/weekday_selector.dart';
import 'grades_overview_page.dart';
import 'hidden_events_page.dart';
import 'login_page.dart';
import 'mensa_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weekday _activePage = Weekday.monday;
  double _swipeDeltaX = 0;

  @override
  void initState() {
    super.initState();

    DateTime currentWeek = getFirstDayOfWeek(
      cleanDate(DateTime.now()),
    );

    if (DateTime.now().weekday < 6) {
      _activePage = Weekday.getByValue(DateTime.now().weekday - 1);
    } else {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }

    store.dispatch(redux.setCurrentWeek(currentWeek));

    AdvancedInAppReview()
        .setMinDaysBeforeRemind(14)
        .setMinDaysAfterInstall(2)
        .setMinLaunchTimes(5)
        .setMinSecondsBeforeShowDialog(4)
        .monitor();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          Widget content = Container();

          if (state.currentView == TimetableView.daily) {
            content = TimetableWidget(
              weekday: _activePage,
            );
          } else if (state.currentView == TimetableView.weekly) {
            content = WeekOverview(
              firstDayOfWeek: state.currentWeek,
            );
          } else if (state.currentView == TimetableView.monthly) {
            content = MonthOverviewWidget(
              onSelectedDayChanged: (dayOfWeek) {
                setState(() {
                  _activePage = Weekday.getByValue(dayOfWeek);
                });
              },
            );
          }

          final DateFormat lastUpdatedFormat = DateFormat('dd.MM.yyyy');
          return PageWrapper(
            bottomNavigationBar: state.currentView == TimetableView.daily
                ? WeekdaySelectorWidget(
                    weekday: _activePage,
                    onChanged: (weekday) => setState(() {
                      _activePage = weekday;
                    }),
                  )
                : null,
            actions: [
              if (state.showChangelog)
                IconButton(
                  onPressed: () {
                    store.dispatch(redux.showChangelog(false));

                    showDialog(
                      context: context,
                      builder: (context) => ChangelogDialog(),
                    );
                  },
                  icon: Badge(
                    backgroundColor: Colors.red.withOpacity(0.9),
                    label: const Text('1'),
                    child: const Icon(
                      Icons.update,
                      color: Colors.white,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditEventPage(event: null),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
            menuActions: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  "Zuletzt aktualisiert: ${state.lastUpdated == null ? "Nie" : lastUpdatedFormat.format(state.lastUpdated!)}",
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.event_busy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Ausgeblendete Veranstaltungen'),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HiddenEventsPage(),
                    ),
                  );
                },
              ),
              if (state.currentView != TimetableView.daily)
                ListTile(
                  leading: Icon(
                    Icons.calendar_view_day,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Tagesübersicht'),
                  onTap: () {
                    store.dispatch(redux.setView(TimetableView.daily));
                    Navigator.pop(context);
                  },
                ),
              if (state.currentView != TimetableView.weekly)
                ListTile(
                  leading: Icon(
                    Icons.view_week,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Wochenübersicht'),
                  onTap: () {
                    store.dispatch(redux.setView(TimetableView.weekly));
                    Navigator.pop(context);
                  },
                ),
              if (state.currentView != TimetableView.monthly)
                ListTile(
                  leading: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Monatsübersicht'),
                  onTap: () {
                    store.dispatch(redux.setView(TimetableView.monthly));
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Speiseplan'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MensaPage(),
                    ),
                  );
                },
              ),
              ListTile(
                  leading: Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Prüfungsergebnisse'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GradesOverviewPage(),
                        ));
                  }),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Einstellungen'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: WeekSelectorWidget(
                    firstDayOfWeek: state.currentWeek,
                    onHome: () {
                      store.dispatch(redux.setCurrentWeek(getFirstDayOfWeek(
                        cleanDate(DateTime.now()),
                      )));

                      setState(() {
                        _activePage = Weekday.getByValue(
                          DateTime.now().weekday - 1,
                        );
                      });
                    },
                    onDateChanged: (week) {
                      store.dispatch(redux.setCurrentWeek(week));
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) => _swipeDeltaX = 0,
                    onHorizontalDragUpdate: (details) =>
                        _swipeDeltaX += details.delta.dx,
                    onHorizontalDragEnd: (details) {
                      if (_swipeDeltaX < -0) {
                        // left swipe -> next page
                        nextDay();
                      } else if (_swipeDeltaX > 0) {
                        // right swipe -> previous page
                        previousDay();
                      }
                    },
                    child: RefreshIndicator(
                      child: content,
                      onRefresh: () async {
                        if (store.state.enableConfirmRefreshDialog) {
                          showDialog(
                            context: context,
                            builder: (context) => const ConfirmRefreshDialog(),
                          );
                        } else {
                          LoginPage.performLogin(
                            onLoginSuccess: () async => await reloadAll(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void nextDay() {
    if (store.state.currentView == TimetableView.daily) {
      if (_activePage == Weekday.friday) {
        store.dispatch(redux.setCurrentWeek(
          store.state.currentWeek.add(const Duration(days: 7)),
        ));

        setState(() {
          _activePage = Weekday.monday;
        });
      } else {
        setState(() {
          _activePage = Weekday.getByValue(_activePage.value + 1);
        });
      }
    } else if (store.state.currentView == TimetableView.weekly) {
      store.dispatch(redux.setCurrentWeek(
        store.state.currentWeek.add(const Duration(days: 7)),
      ));
    }
  }

  void previousDay() {
    if (store.state.currentView == TimetableView.daily) {
      if (_activePage == Weekday.monday &&
          store.state.currentWeek.isAfter(DateTime.now())) {
        store.dispatch(redux.setCurrentWeek(
          store.state.currentWeek.subtract(const Duration(days: 7)),
        ));

        setState(() {
          _activePage = Weekday.friday;
        });
      } else {
        setState(() {
          _activePage = Weekday.getByValue(_activePage.value - 1);
        });
      }
    } else if (store.state.currentView == TimetableView.weekly) {
      store.dispatch(redux.setCurrentWeek(
        store.state.currentWeek.subtract(const Duration(days: 7)),
      ));
    }
  }
}
