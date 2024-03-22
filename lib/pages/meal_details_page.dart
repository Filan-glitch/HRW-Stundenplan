import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/model/graphql/canteens/meal.dart';
import 'package:timetable/model/graphql/canteens/price.dart';
import 'package:timetable/model/redux/app_state.dart';
import 'package:timetable/widgets/page_wrapper.dart';

class MealDetailsPage extends StatelessWidget {
  const MealDetailsPage(this.meal, {super.key});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return PageWrapper(
          simpleDesign: true,
          title: meal.category ?? 'Details',
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Hero(
                  tag: meal.id!,
                  child: Container(
                    color: Colors.grey,
                    child: meal.pictureUrl == null
                        ? null
                        : Image.network(
                            meal.pictureUrl!,
                            width: MediaQuery.of(context).size.width,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(),
                          ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width - 50,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          meal.name ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <String>[
                            if (meal.diets?.contains(Diet.VEGAN) ?? false)
                              'Vegan',
                            if (meal.diets?.contains(Diet.VEGETARIAN) ?? false)
                              'Vegetarisch',
                            if (meal.diets?.contains(Diet.FISH) ?? false)
                              'Fisch',
                            if (meal.diets?.contains(Diet.PIG) ?? false)
                              'Schwein',
                            if (meal.diets?.contains(Diet.BEEF) ?? false)
                              'Rind',
                            if (meal.diets?.contains(Diet.POULTRY) ?? false)
                              'Geflügel',
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            meal.additives
                                    ?.map((e) => Meal.additiveToString(e))
                                    .join(', ') ??
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
                            meal.allergens
                                    ?.map((e) => Meal.allergeneToString(e))
                                    .join(', ') ??
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
