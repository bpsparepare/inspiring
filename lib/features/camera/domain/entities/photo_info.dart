import '../../utils/coordinate_converter.dart';

class PhotoInfo {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;

  const PhotoInfo({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  String get coordinatesFormatted {
    return CoordinateConverter.formatCoordinates(latitude, longitude);
  }
}
