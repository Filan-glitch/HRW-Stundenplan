import 'package:flutter/material.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';
import 'package:timetable/model/graphql/canteens/menu.dart';
import 'package:timetable/widgets/main_dish_widget.dart';
import 'package:timetable/widgets/side_dish_widget.dart';

class MealListWidget extends StatelessWidget {
  MealListWidget(this.menu, {super.key});

  final Menu menu;
  final int numPerRow = 2;
  final ScrollController _mainDishHorizontalScrollController =
      ScrollController();

  @override
  Widget build(BuildContext context) {
    if (menu.mainDishes == null) return Container();

    final int sideDishRows = (menu.sideDishes!.length / numPerRow).ceil();
    final double sideDishItemWidth =
        MediaQuery.of(context).size.width / numPerRow - 30;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Main dishes
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
            ),
            const SizedBox(height: 10),
            const Text(
              'Beilagen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
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
                                width: sideDishItemWidth,
                                meal: menu.sideDishes![i * numPerRow + j],
                              );
                            },
                          )
                      ],
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
