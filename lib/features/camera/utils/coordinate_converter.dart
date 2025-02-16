class CoordinateConverter {
  static String toDMS(double decimal, bool isLatitude) {
    String direction =
        isLatitude ? (decimal >= 0 ? "N" : "S") : (decimal >= 0 ? "E" : "W");

    decimal = decimal.abs();
    int degrees = decimal.floor();
    double minutesDecimal = (decimal - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double seconds = (minutesDecimal - minutes) * 60;

    // Menggunakan simbol derajat yang benar
    return "${degrees.toString().padLeft(3, ' ')}° ${minutes.toString().padLeft(2, '0')}' ${seconds.toStringAsFixed(1)}\" $direction";
  }

  static String formatCoordinates(double latitude, double longitude) {
    String latDMS = toDMS(latitude, true);
    String lonDMS = toDMS(longitude, false);
    return "$latDMS\n$lonDMS";
  }
}
