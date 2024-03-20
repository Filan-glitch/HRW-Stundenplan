import 'package:timetable/model/graphql/canteens/timeperiod.dart';

class OpeningHours {
  List<TimePeriod>? monday;
  List<TimePeriod>? tuesday;
  List<TimePeriod>? wednesday;
  List<TimePeriod>? thursday;
  List<TimePeriod>? friday;
  List<TimePeriod>? saturday;
  List<TimePeriod>? sunday;

  OpeningHours(Map<String, dynamic> json) {
    if (json['monday'] != null) {
      monday = [];
      json['monday'].forEach((v) {
        monday!.add(TimePeriod(v));
      });
    }
    if (json['tuesday'] != null) {
      tuesday = [];
      json['tuesday'].forEach((v) {
        tuesday!.add(TimePeriod(v));
      });
    }
    if (json['wednesday'] != null) {
      wednesday = [];
      json['wednesday'].forEach((v) {
        wednesday!.add(TimePeriod(v));
      });
    }
    if (json['thursday'] != null) {
      thursday = [];
      json['thursday'].forEach((v) {
        thursday!.add(TimePeriod(v));
      });
    }
    if (json['friday'] != null) {
      friday = [];
      json['friday'].forEach((v) {
        friday!.add(TimePeriod(v));
      });
    }
    if (json['saturday'] != null) {
      saturday = [];
      json['saturday'].forEach((v) {
        saturday!.add(TimePeriod(v));
      });
    }
    if (json['sunday'] != null) {
      sunday = [];
      json['sunday'].forEach((v) {
        sunday!.add(TimePeriod(v));
      });
    }
  }
}
