import 'canteen.dart';

class Campus {
  int? id;
  String? name;
  List<Canteen>? canteens;

  Campus(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['canteens'] != null) {
      canteens = [];
      json['canteens'].forEach((v) {
        canteens!.add(Canteen(v));
      });
    }
  }
}
