import 'package:timetable/model/date_time_calculator.dart';

import 'menu.dart';
import 'openinghours.dart';

class Canteen {
  int? id;
  String? name;
  List<Menu>? menus;
  OpeningHours? openingHours;
  String? building;
  String? address;

  Canteen(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['menus'] != null) {
      menus = [];
      json['menus'].forEach((v) {
        menus!.add(Menu(v));
      });
      menus!
          .where(
            (element) => !element.isoDate!.isBefore(cleanDate(DateTime.now())),
          )
          .toList()
          .sort((a, b) => a.isoDate!.compareTo(b.isoDate!));
    }
    if (json['building'] != null) {
      building = json['building']['name'];
      address =
          '${json['building']['address']['street']} ${json['building']['address']['houseNumber']}\n' +
              '${json['building']['address']['postalCode']} ${json['building']['address']['city']['name']}';
    }

    if (json['openinghours']?['default']?[0] != null) {
      openingHours = OpeningHours(json['openinghours']['default'][0]);
    }
  }
}
