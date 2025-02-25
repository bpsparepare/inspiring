import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/water_subscription_group.dart';
import '../../domain/entities/water_tariff.dart';
import '../widgets/water_result_card.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final _formKey = GlobalKey<FormState>();
  final _biayaController = TextEditingController();
  // Update default group ke kelompokII (yang sebelumnya rumahTangga2)
  WaterSubscriptionGroup _selectedGroup = WaterSubscriptionGroup.kelompokIIIb;
  double? _calculatedUsage;

  void _calculateUsage() {
    if (!_formKey.currentState!.validate()) return;

    final targetBill = double.parse(_biayaController.text.replaceAll(',', ''));
    // Kurangi biaya admin dari total tagihan
    final waterOnlyBill = targetBill - WaterTariff.adminCharge;
    double estimatedUsage = 1.0;
    double calculatedWaterBill;

    // Iterative calculation to find the closest usage for water consumption only
    do {
      double bloc1Usage = estimatedUsage <= 10 ? estimatedUsage : 10.0;
      double bloc2Usage = estimatedUsage <= 10
          ? 0.0
          : (estimatedUsage <= 20 ? estimatedUsage - 10 : 10.0);
      double bloc3Usage = estimatedUsage <= 20 ? 0.0 : estimatedUsage - 20;

      calculatedWaterBill =
          (bloc1Usage * WaterTariff.getTariff(_selectedGroup, 5)) +
              (bloc2Usage * WaterTariff.getTariff(_selectedGroup, 15)) +
              (bloc3Usage * WaterTariff.getTariff(_selectedGroup, 25));

      if (calculatedWaterBill < waterOnlyBill) {
        estimatedUsage += 0.1;
      } else {
        // Cek selisih dengan nilai sebelumnya
        double prevUsageWaterBill =
            WaterTariff.calculateBill(_selectedGroup, estimatedUsage - 0.1) -
                WaterTariff.adminCharge;

        if (calculatedWaterBill - waterOnlyBill >
            waterOnlyBill - prevUsageWaterBill) {
          estimatedUsage -= 0.1;
        }
        break;
      }
    } while (estimatedUsage < 100);

    setState(() {
      _calculatedUsage = estimatedUsage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Air PDAM'),
        backgroundColor: Colors.cyan,
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _biayaController,
                        decoration: const InputDecoration(
                          labelText: 'Total Tagihan (Rp)',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.isEmpty) return newValue;
                            final value = int.parse(newValue.text);
                            final formatted = value.toString().replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                );
                            return TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan total tagihan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Kelompok Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...WaterSubscriptionGroup.values.map(
                        (group) => RadioListTile<WaterSubscriptionGroup>(
                          title: Text(group.display),
                          subtitle: Text(group.description),
                          value: group,
                          groupValue: _selectedGroup,
                          onChanged: (value) {
                            setState(() {
                              _selectedGroup = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculateUsage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hitung Pemakaian Air',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_calculatedUsage != null) ...[
                const SizedBox(height: 16),
                WaterResultCard(
                  usage: _calculatedUsage!,
                  group: _selectedGroup,
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
