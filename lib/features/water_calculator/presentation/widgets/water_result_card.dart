import 'package:flutter/material.dart';
import '../../domain/entities/water_subscription_group.dart';
import '../../domain/entities/water_tariff.dart';

class WaterResultCard extends StatelessWidget {
  final double usage;
  final WaterSubscriptionGroup group;

  const WaterResultCard({
    super.key,
    required this.usage,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final bloc1Usage = usage <= 10 ? usage : 10.0;
    final bloc2Usage = usage <= 10 ? 0.0 : (usage <= 20 ? usage - 10 : 10.0);
    final bloc3Usage = usage <= 20 ? 0.0 : usage - 20;

    final bloc1Rate = WaterTariff.getTariff(group, 5);
    final bloc2Rate = WaterTariff.getTariff(group, 15);
    final bloc3Rate = WaterTariff.getTariff(group, 25);

    final bloc1Cost = bloc1Usage * bloc1Rate;
    final bloc2Cost = bloc2Usage * bloc2Rate;
    final bloc3Cost = bloc3Usage * bloc3Rate;

    // Gunakan calculateBill untuk konsistensi perhitungan
    final calculatedTotalBill = WaterTariff.calculateBill(group, usage);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.cyan.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Hasil Perhitungan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            if (bloc1Usage > 0)
              _buildResultRow('Blok 1 (0-10 m³)',
                  '${bloc1Usage.toStringAsFixed(1)} m³ × Rp ${_formatNumber(bloc1Rate)} = Rp ${_formatNumber(bloc1Cost)}'),
            if (bloc2Usage > 0)
              _buildResultRow('Blok 2 (11-20 m³)',
                  '${bloc2Usage.toStringAsFixed(1)} m³ × Rp ${_formatNumber(bloc2Rate)} = Rp ${_formatNumber(bloc2Cost)}'),
            if (bloc3Usage > 0)
              _buildResultRow('Blok 3 (>20 m³)',
                  '${bloc3Usage.toStringAsFixed(1)} m³ × Rp ${_formatNumber(bloc3Rate)} = Rp ${_formatNumber(bloc3Cost)}'),
            const Divider(height: 16),
            _buildResultRow(
                'Biaya Admin', 'Rp ${_formatNumber(WaterTariff.adminCharge)}'),
            // _buildResultRow('Biaya Pemeliharaan',
            //     'Rp ${_formatNumber(WaterTariff.maintenanceCharge)}'),
            // _buildResultRow(
            //     'Biaya Meter', 'Rp ${_formatNumber(WaterTariff.meterCharge)}'),
            const Divider(height: 16),
            _buildResultRow(
                'Total Pemakaian', '${usage.toStringAsFixed(1)} m³'),
            _buildResultRow(
                'Total Tagihan', 'Rp ${_formatNumber(calculatedTotalBill)}',
                isBold: true),
            const Divider(height: 32),
            Text(
              'Kelompok: ${group.display}\n${group.description}',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
