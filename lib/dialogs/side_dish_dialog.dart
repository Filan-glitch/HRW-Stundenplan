import 'package:flutter/material.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';
import 'package:timetable/model/graphql/canteens/price.dart';
import 'package:timetable/widgets/dialog_wrapper.dart';

class SideDishDetailsDialog extends StatelessWidget {
  const SideDishDetailsDialog(this.meal, {super.key});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return DialogWrapper(
      title: meal.name ?? 'Beilage',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <String>[
            if (meal.diets?.contains(Diet.VEGAN) ?? false) 'Vegan',
            if (meal.diets?.contains(Diet.VEGETARIAN) ?? false) 'Vegetarisch',
            if (meal.diets?.contains(Diet.FISH) ?? false) 'Fisch',
            if (meal.diets?.contains(Diet.PIG) ?? false) 'Schwein',
            if (meal.diets?.contains(Diet.BEEF) ?? false) 'Rind',
            if (meal.diets?.contains(Diet.POULTRY) ?? false) 'Geflügel',
          ]
              .map((e) => Text(
                    '($e)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (Price price in meal.prices!)
              if (price.value != 0)
                Column(
                  children: [
                    Text(
                      price.category.toString(),
                    ),
                    Text(
                      '${price.value?.toStringAsFixed(2)} ${price.currency}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Zusatzstoffe:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (meal.additives?.isEmpty ?? true)
          const Text('Keine Zusatzstoffe vorhanden'),
        if (meal.additives?.isNotEmpty ?? false)
          Text(
            meal.additives?.map((e) => Meal.additiveToString(e)).join(', ') ??
                '',
          ),
        const SizedBox(height: 15),
        const Text(
          'Allergene:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (meal.allergens?.isEmpty ?? true)
          const Text('Keine Allergene vorhanden'),
        if (meal.allergens?.isNotEmpty ?? false)
          Text(
            meal.allergens?.map((e) => Meal.allergeneToString(e)).join(', ') ??
                '',
          ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, right: 0.0),
          child: Text(
            'Hinweis: Für die Richtigkeit und Vollständigkeit der Angaben wird keine Gewähr übernommen.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}
