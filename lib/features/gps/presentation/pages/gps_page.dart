import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/coordinate.dart';
import '../../domain/entities/parepare_bounds.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  State<GpsPage> createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  final _formKey = GlobalKey<FormState>();
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  Coordinate? _latitude;
  Coordinate? _longitude;
  String? _locationInfo;

  void _convertCoordinates() {
    if (_formKey.currentState!.validate()) {
      final lat = double.parse(_latController.text);
      final long = double.parse(_longController.text);

      setState(() {
        _latitude = Coordinate(
          decimal: lat,
          cardinalPoint: lat >= 0 ? 'N' : 'S',
        );
        _longitude = Coordinate(
          decimal: long,
          cardinalPoint: long >= 0 ? 'E' : 'W',
        );
        _locationInfo = ParepareBounds.getLocationInfo(lat, long);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Koordinat'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Koordinat Desimal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          hintText: 'Contoh: -5.123456',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.compass_calibration),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan latitude';
                          }
                          final latitude = double.tryParse(value);
                          if (latitude == null) {
                            return 'Format tidak valid';
                          }
                          if (!Coordinate.isValidLatitude(latitude)) {
                            return 'Latitude harus antara -90 dan 90';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _longController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          hintText: 'Contoh: 119.123456',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.explore),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*\.?\d*'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan longitude';
                          }
                          final longitude = double.tryParse(value);
                          if (longitude == null) {
                            return 'Format tidak valid';
                          }
                          if (!Coordinate.isValidLongitude(longitude)) {
                            return 'Longitude harus antara -180 dan 180';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _convertCoordinates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Konversi ke DMS',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Konversi (DMS)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildResultRow(
                          'Latitude',
                          _latitude!.toDMS(),
                          Icons.compass_calibration,
                        ),
                        const SizedBox(height: 12),
                        _buildResultRow(
                          'Longitude',
                          _longitude!.toDMS(),
                          Icons.explore,
                        ),
                        if (_locationInfo != null) ...[
                          const Divider(height: 24),
                          Row(
                            children: [
                              Icon(
                                ParepareBounds.isInParepare(
                                  _latitude!.decimal,
                                  _longitude!.decimal,
                                )
                                    ? Icons.location_on
                                    : Icons.location_off,
                                color: ParepareBounds.isInParepare(
                                  _latitude!.decimal,
                                  _longitude!.decimal,
                                )
                                    ? Colors.green
                                    : Colors.red.shade300,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _locationInfo!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.shade300, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }
}
