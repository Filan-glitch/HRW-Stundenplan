class TimePeriod {
  String opens;
  String closes;

  TimePeriod(Map<String, dynamic> json)
      : opens = json['opens'],
        closes = json['closes'];
}
