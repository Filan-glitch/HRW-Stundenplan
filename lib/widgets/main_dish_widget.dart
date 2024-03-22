import 'package:flutter/material.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';
import 'package:timetable/pages/meal_details_page.dart';

class MainDishWidget extends StatelessWidget {
  const MainDishWidget({
    super.key,
    required this.width,
    required this.meal,
  });

  final double width;
  final Meal meal;

  Widget _emptyImageBuilder(BuildContext context) {
    return Container(
      height: width * 0.8,
      width: width * 0.8,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailsPage(meal),
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 20,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: width * 0.8,
              child: Center(
                child: Hero(
                  tag: meal.id!,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: meal.pictureUrl == null
                        ? _emptyImageBuilder(context)
                        : Image.network(
                            meal.pictureUrl!,
                            errorBuilder: (context, error, stackTrace) =>
                                _emptyImageBuilder(context),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              meal.category ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              meal.name ?? '',
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 15),
            ...<String>[
              if (meal.diets?.contains(Diet.VEGAN) ?? false) 'Vegan',
              if (meal.diets?.contains(Diet.VEGETARIAN) ?? false) 'Vegetarisch',
              if (meal.diets?.contains(Diet.FISH) ?? false) 'Fisch',
              if (meal.diets?.contains(Diet.PIG) ?? false) 'Schwein',
              if (meal.diets?.contains(Diet.BEEF) ?? false) 'Rind',
              if (meal.diets?.contains(Diet.POULTRY) ?? false) 'Geflügel',
            ]
                .map((e) => Text(
                      e,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
