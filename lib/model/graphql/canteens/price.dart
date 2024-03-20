enum PriceCategory {
  students,
  employees,
  guests;

  @override
  String toString() {
    switch (this) {
      case PriceCategory.students:
        return 'Studenten';
      case PriceCategory.employees:
        return 'Mitarbeiter';
      case PriceCategory.guests:
        return 'Gäste';
      default:
        return '';
    }
  }
}

class Price {
  String? id;
  double? value;
  String? currency;
  PriceCategory? category;

  Price(Map<String, dynamic> json) {
    id = json['id'];
    value = double.parse(json['value']?.toString() ?? '0');
    currency = json['currency'];

    switch (json['category']) {
      case 'Students':
        category = PriceCategory.students;
        break;
      case 'Employees':
        category = PriceCategory.employees;
        break;
      case 'Guests':
        category = PriceCategory.guests;
        break;
      default:
        category = null;
    }
  }
}
