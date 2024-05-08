import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/model/campus.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';
import 'package:timetable/model/graphql/canteens/menu.dart';
import 'package:timetable/model/redux/app_state.dart';
import 'package:timetable/widgets/main_dish_widget.dart';
import 'package:timetable/widgets/side_dish_widget.dart';

class MealListWidget extends StatelessWidget {
  MealListWidget(this.menu, {super.key});

  final Menu menu;
  final int numPerRow = 2;
  final ScrollController _mainDishHorizontalScrollController =
      ScrollController();

  Widget _buildMuelheimMainDishes(BuildContext context) {
    return // Main dishes
        Scrollbar(
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 2,
      controller: _mainDishHorizontalScrollController,
      radius: const Radius.circular(5.0),
      child: SingleChildScrollView(
        controller: _mainDishHorizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (Meal meal in menu.mainDishes!)
                  MainDishWidget(
                    width: 200,
                    meal: meal,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottropMainDishes(BuildContext context) {
    final int mainDishRows = (menu.mainDishes!.length / numPerRow).ceil();
    final double mainDishItemWidth =
        MediaQuery.of(context).size.width / numPerRow - 30;

    return Column(
      children: [
        for (int i = 0; i < mainDishRows; i++)
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 0; j < numPerRow; j++)
                  Builder(
                    builder: (context) {
                      if (i * numPerRow + j >= menu.mainDishes!.length)
                        return Container();

                      return SideDishWidget(
                        width: mainDishItemWidth *
                            (j == 0 &&
                                    (i * numPerRow + j + 1 >=
                                        menu.mainDishes!.length)
                                ? 2
                                : 1),
                        meal: menu.mainDishes![i * numPerRow + j],
                      );
                    },
                  )
              ],
            ),
          )
      ],
    );
  }

  Widget _buildSideDishes(BuildContext context) {
    final int sideDishRows = (menu.sideDishes!.length / numPerRow).ceil();
    final double sideDishItemWidth =
        MediaQuery.of(context).size.width / numPerRow - 30;

    return Column(
      children: [
        const Text(
          'Beilagen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < sideDishRows; i++)
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 0; j < numPerRow; j++)
                  Builder(
                    builder: (context) {
                      if (i * numPerRow + j >= menu.sideDishes!.length)
                        return Container();

                      return SideDishWidget(
                        width: sideDishItemWidth *
                            (j == 0 &&
                                    (i * numPerRow + j + 1 >=
                                        menu.sideDishes!.length)
                                ? 2
                                : 1),
                        meal: menu.sideDishes![i * numPerRow + j],
                      );
                    },
                  )
              ],
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (menu.mainDishes == null) return Container();

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  if (state.selectedCampus == Campus.muelheim)
                    _buildMuelheimMainDishes(context)
                  else
                    _buildBottropMainDishes(context),
                  const SizedBox(height: 10),
                  _buildSideDishes(context),
                ],
              ),
            ),
          );
        });
  }
}
