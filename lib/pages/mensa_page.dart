import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:timetable/dialogs/canteen_details_dialog.dart';
import 'package:timetable/model/graphql/canteens/canteen.dart';
import 'package:timetable/widgets/meal_list.dart';

import '../model/campus.dart';
import '../model/redux/app_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/graphql/canteens.dart';
import '../service/storage.dart';
import '../widgets/horizontal_selector.dart';
import '../widgets/page_wrapper.dart';

class MensaPage extends StatefulWidget {
  const MensaPage({super.key});

  @override
  State<MensaPage> createState() => _MensaPageState();
}

class _MensaPageState extends State<MensaPage> {
  int dayID = 0;

  @override
  void initState() {
    super.initState();
    getCanteenData();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        final Canteen? canteen = state.campuses
            .firstWhereOrNull(
              (campus) =>
                  campus.name ==
                  (state.selectedCampus == Campus.muelheim
                      ? 'Campus Mülheim'
                      : 'Campus Bottrop'),
            )
            ?.canteens
            ?.first;

        final DateFormat formatter = DateFormat('dd.MM.yyyy');

        return PageWrapper(
          simpleDesign: true,
          title: canteen?.name ?? 'Mensa',
          actions: [
            if (canteen != null)
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => CanteenDetailsDialog(canteen),
                  );
                },
                icon: const Icon(
                  Icons.info,
                  size: 25,
                ),
              ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              canteen?.menus == null || canteen!.menus!.isEmpty
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: dayID < 1
                              ? null
                              : () {
                                  setState(() {
                                    dayID--;
                                  });
                                },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              dayID = 0;
                            });
                          },
                          child: Text(
                            formatter.format(canteen.menus![dayID].isoDate!),
                          ),
                        ),
                        IconButton(
                          onPressed: dayID > canteen.menus!.length - 2
                              ? null
                              : () {
                                  setState(() {
                                    dayID++;
                                  });
                                },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ),
                      ],
                    ),
              Expanded(
                child: canteen?.menus == null || canteen!.menus!.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: Text(
                            'Für diese Mensa wurden keine Speisen gefunden.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : MealListWidget(canteen.menus![dayID]),
              ),
              HorizontalSelector(
                items: Campus.values.asMap().map(
                      (key, value) => MapEntry(
                        value,
                        value.name,
                      ),
                    ),
                onChanged: (value) {
                  store.dispatch(
                    redux.Action(
                      redux.ActionTypes.setCampus,
                      payload: value,
                    ),
                  );

                  writeCampus();
                },
                value: state.selectedCampus,
              ),
            ],
          ),
        );
      },
    );
  }
}
