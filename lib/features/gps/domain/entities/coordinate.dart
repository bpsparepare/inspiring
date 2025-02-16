class Coordinate {
  final double decimal;
  final String cardinalPoint;

  const Coordinate({
    required this.decimal,
    required this.cardinalPoint,
  });

  String toDMS() {
    double abs = decimal.abs();
    int degrees = abs.floor();
    double minutesDecimal = (abs - degrees) * 60;
    int minutes = minutesDecimal.floor();
    // Bulatkan detik ke angka integer
    int seconds = ((minutesDecimal - minutes) * 60).round();

    // Penanganan ketika detik = 60
    if (seconds == 60) {
      seconds = 0;
      minutes += 1;
      // Penanganan ketika menit = 60
      if (minutes == 60) {
        minutes = 0;
        degrees += 1;
      }
    }

    return '$degrees° $minutes\' $seconds" $cardinalPoint';
  }

  static bool isValidLatitude(double value) {
    return value >= -90 && value <= 90;
  }

  static bool isValidLongitude(double value) {
    return value >= -180 && value <= 180;
  }
}
