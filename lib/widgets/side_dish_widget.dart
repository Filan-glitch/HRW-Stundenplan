import 'package:flutter/material.dart';
import 'package:timetable/dialogs/side_dish_dialog.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';

class SideDishWidget extends StatelessWidget {
  const SideDishWidget({
    super.key,
    required this.width,
    required this.meal,
  });

  final double width;
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => SideDishDetailsDialog(meal));
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
            ],
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${meal.category}: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              meal.name ?? '',
            ),
            const SizedBox(height: 15),
            if (meal.diets?.contains(Diet.VEGAN) ?? false) const Text('Vegan'),
            if (meal.diets?.contains(Diet.VEGETARIAN) ?? false)
              const Text('Vegetarisch'),
            if (meal.diets?.contains(Diet.FISH) ?? false) const Text('Fisch'),
            if (meal.diets?.contains(Diet.PIG) ?? false) const Text('Schwein'),
            if (meal.diets?.contains(Diet.BEEF) ?? false) const Text('Rind'),
            if (meal.diets?.contains(Diet.POULTRY) ?? false)
              const Text('Geflügel'),
          ],
        ),
      ),
    );
  }
}
