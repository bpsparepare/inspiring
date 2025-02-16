import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/power_selector.dart';
import '../widgets/result_card.dart';
import '../../domain/entities/tariff_type.dart';
import '../../domain/entities/meter_type.dart';
import '../../domain/entities/tariff_block.dart';

class KwhPage extends StatefulWidget {
  const KwhPage({super.key});

  @override
  State<KwhPage> createState() => _KwhPageState();
}

class _KwhPageState extends State<KwhPage> {
  final _formKey = GlobalKey<FormState>();
  final _biayaController = TextEditingController();
  int _selectedPower = 900;
  String _selectedWilayah = 'Parepare'; // Set as default
  double? _calculatedKwh;
  TariffType _tariffType = TariffType.nonSubsidi;
  MeterType _meterType = MeterType.prabayar;
  bool _showResult = false; // Add this

  final List<int> _powerOptions = [450, 900, 1300, 2200, 3500];
  final Map<String, double> _ppjRates = {
    'Parepare': 0.1, // PPJ 5% untuk Sulsel
    'DKI Jakarta': 0.03,
    'Jawa Barat': 0.025,
    'Jawa Tengah': 0.03,
    'Jawa Timur': 0.03,
    'Banten': 0.025,
  };

  // Helper method to get sorted wilayah list
  List<String> get _sortedWilayah => [
        'Parepare', // Always first
        ..._ppjRates.keys.where((w) => w != 'Parepare').toList()..sort(),
      ];

  bool get _isPrabayar => _meterType == MeterType.prabayar;

  void _calculateKwh() {
    if (!_formKey.currentState!.validate()) return;

    final totalBiaya = double.parse(_biayaController.text.replaceAll(',', ''));
    final bebanBiaya =
        TariffBlockCalculator.getBebanBiaya(_selectedPower, _isPrabayar);
    final ppj = totalBiaya * _ppjRates[_selectedWilayah]!;

    // Rumus berbeda untuk prabayar dan pascabayar
    final adjustedBiaya = totalBiaya - ppj;
    final blocks = TariffBlockCalculator.getBlocks(
      _selectedPower,
      _isPrabayar,
      tariffType: _selectedPower == 900 ? _tariffType : null,
    );

    double totalKwh;
    if (_isPrabayar) {
      // Prabayar: langsung bagi dengan tarif dasar
      totalKwh = adjustedBiaya / blocks.first.rate;
    } else {
      // Pascabayar: perhitungan per blok dan mempertimbangkan biaya beban
      // final biayaAfterBeban = adjustedBiaya - bebanBiaya;
      double remainingBiaya = adjustedBiaya;
      totalKwh = 0;

      // Hitung KWH per blok tarif
      for (var block in blocks) {
        if (remainingBiaya <= 0) break;

        final blockMaxKwh = block.endKwh - block.startKwh;
        final blockMaxBiaya = blockMaxKwh * block.rate;
        final blockBiaya =
            remainingBiaya > blockMaxBiaya ? blockMaxBiaya : remainingBiaya;
        final blockKwh = blockBiaya / block.rate;

        totalKwh += blockKwh;
        remainingBiaya -= blockBiaya;
      }
    }

    setState(() {
      if (adjustedBiaya > bebanBiaya) {
        _calculatedKwh = totalKwh;
      } else {
        _calculatedKwh = adjustedBiaya / blocks.first.rate;
      }
      _showResult = true; // Just toggle visibility
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator kWh'),
        backgroundColor: Colors.amber.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Reduced padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2, // Reduced elevation
                margin: EdgeInsets.zero, // Remove card margin
                child: Padding(
                  padding: const EdgeInsets.all(12), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Combined Row for TextFormField and DropdownButtonFormField
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Biaya Field
                          Expanded(
                            flex: 3, // Takes 75% of space
                            child: TextFormField(
                              controller: _biayaController,
                              decoration: const InputDecoration(
                                labelText: 'Total Biaya (Rp)',
                                border: OutlineInputBorder(),
                                prefixText: 'Rp ',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                // Add thousand separator
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  if (newValue.text.isEmpty) return newValue;
                                  final value = int.parse(newValue.text);
                                  final formatted = value
                                      .toString()
                                      .replaceAllMapped(
                                          RegExp(
                                              r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                          (Match m) => '${m[1]},');
                                  return TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                        offset: formatted.length),
                                  );
                                }),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan total biaya';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8), // Space between fields
                          // Wilayah Dropdown
                          Expanded(
                            flex: 2, // Takes 25% of space
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Wilayah',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                helperText:
                                    '${(_ppjRates[_selectedWilayah]! * 100).toStringAsFixed(1)}%',
                                helperStyle: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              value: _selectedWilayah,
                              isExpanded: true,
                              items: _sortedWilayah
                                  .map((w) => DropdownMenuItem(
                                        value: w,
                                        child: Text(
                                          w,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedWilayah = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Reduced spacing
                      PowerSelector(
                        powers: _powerOptions,
                        selectedPower: _selectedPower,
                        onChanged: (value) =>
                            setState(() => _selectedPower = value),
                      ),
                      const SizedBox(height: 12), // Reduced spacing

                      // Meter Type Selection
                      Text('Jenis Meteran',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          )),
                      const SizedBox(height: 4), // Minimal spacing
                      SegmentedButton<MeterType>(
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                          ),
                        ),
                        segments: MeterType.values
                            .map((type) => ButtonSegment<MeterType>(
                                  value: type,
                                  icon: Icon(type.icon),
                                  label: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(type.display),
                                      Text(
                                        type.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        selected: {_meterType},
                        onSelectionChanged: (Set<MeterType> selected) {
                          setState(() {
                            _meterType = selected.first;
                          });
                        },
                      ),

                      // Tariff Type Selection (if power is 900)
                      if (_selectedPower == 900) ...[
                        const SizedBox(height: 12),
                        Text('Jenis Tarif',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 4),
                        SegmentedButton<TariffType>(
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                            ),
                          ),
                          segments: TariffType.values
                              .map((type) => ButtonSegment<TariffType>(
                                    value: type,
                                    label: Text(type.display),
                                  ))
                              .toList(),
                          selected: {_tariffType},
                          onSelectionChanged: (Set<TariffType> selected) {
                            setState(() {
                              _tariffType = selected.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12), // Reduced spacing
              ElevatedButton(
                onPressed: _calculateKwh,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hitung KWH',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              if (_showResult) ...[
                const SizedBox(height: 12), // Reduced spacing
                ResultCard(
                  biaya:
                      double.parse(_biayaController.text.replaceAll(',', '')),
                  isPrabayar: _isPrabayar,
                  wilayah: _selectedWilayah,
                  dayaPower: _selectedPower,
                  ppjRate: _ppjRates[_selectedWilayah]!,
                  tariffType: _selectedPower == 900 ? _tariffType : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _biayaController.dispose();
    super.dispose();
  }
}
