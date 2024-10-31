import 'package:timetable/model/date_time_calculator.dart';

import 'meal.dart';

class Menu {
  String? id;
  DateTime? isoDate;
  List<Meal>? mainDishes;
  List<Meal>? sideDishes;

  Menu(Map<String, dynamic> json) {
    id = json['id'];

    if (json['isoDate'] != null) {
      isoDate = cleanDate(DateTime.parse(json['isoDate']));
    }

    if (json['maindishes'] != null) {
      mainDishes = [];
      json['maindishes'].forEach((v) {
        mainDishes!.add(Meal(v));
      });
    }
    if (json['sidedishes'] != null) {
      sideDishes = [];
      json['sidedishes'].forEach((v) {
        sideDishes!.add(Meal(v));
      });
    }
  }
}
