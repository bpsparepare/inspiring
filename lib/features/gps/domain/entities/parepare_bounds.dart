class ParepareBounds {
  // Batas koordinat Kota Parepare (approximate bounds)
  static const double minLatitude = -4.0583; // Selatan
  static const double maxLatitude = -3.9389; // Utara
  static const double minLongitude = 119.5919; // Barat
  static const double maxLongitude = 119.6719; // Timur

  static bool isInParepare(double latitude, double longitude) {
    return latitude >= minLatitude &&
        latitude <= maxLatitude &&
        longitude >= minLongitude &&
        longitude <= maxLongitude;
  }

  static String getLocationInfo(double latitude, double longitude) {
    if (isInParepare(latitude, longitude)) {
      return 'Koordinat berada di wilayah Kota Parepare';
    }

    String direction = '';
    if (latitude < minLatitude) direction += 'Selatan ';
    if (latitude > maxLatitude) direction += 'Utara ';
    if (longitude < minLongitude) direction += 'Barat ';
    if (longitude > maxLongitude) direction += 'Timur ';

    return 'Koordinat berada di $direction Kota Parepare';
  }
}
