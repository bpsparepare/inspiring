import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/tariff_block.dart';
import '../../domain/entities/tariff_type.dart';
import '../../domain/entities/meter_type.dart';

class ResultCard extends StatelessWidget {
  // final double kwh;
  final double biaya;
  final bool isPrabayar;
  final String wilayah;
  final int dayaPower;
  final double ppjRate;
  final TariffType? tariffType;

  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final NumberFormat decimalFormat =
      NumberFormat('#,##0.0', 'id_ID'); // Add this

  ResultCard({
    super.key,
    // required this.kwh,
    required this.biaya,
    required this.isPrabayar,
    required this.wilayah,
    required this.dayaPower,
    required this.ppjRate,
    this.tariffType,
  });

  double _calculateKwhValue() {
    final bebanBiaya =
        TariffBlockCalculator.getBebanBiaya(dayaPower, isPrabayar);
    final ppj = biaya * ppjRate;
    final adjustedBiaya = biaya - ppj;
    final blocks = TariffBlockCalculator.getBlocks(
      dayaPower,
      isPrabayar,
      tariffType: tariffType,
    );

    if (isPrabayar) {
      // Prabayar: langsung bagi dengan tarif dasar
      return adjustedBiaya / blocks.first.rate;
    }

    // Pascabayar: perhitungan per blok
    if (adjustedBiaya <= bebanBiaya) {
      return adjustedBiaya / blocks.first.rate;
    }

    double remainingBiaya = adjustedBiaya;
    double totalKwh = 0;

    // Hitung KWH per blok tarif
    for (var block in blocks) {
      if (remainingBiaya <= 0) break;

      final blockMaxKwh = (block.endKwh - block.startKwh).toDouble();
      final blockMaxBiaya = blockMaxKwh * block.rate;
      final blockBiaya =
          remainingBiaya > blockMaxBiaya ? blockMaxBiaya : remainingBiaya;

      totalKwh += blockBiaya / block.rate;
      remainingBiaya -= blockBiaya;
    }

    return totalKwh;
  }

  Widget _buildCompactListTile({
    required String title,
    String? subtitle,
    required Widget trailing,
    Color? titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4), // Reduced padding
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatedKwh = _calculateKwhValue();
    final blocks = TariffBlockCalculator.getBlocks(dayaPower, isPrabayar,
        tariffType: tariffType);
    final bebanBiaya =
        TariffBlockCalculator.getBebanBiaya(dayaPower, isPrabayar);
    final ppjNominal = biaya * ppjRate;

    double remainingKwh = calculatedKwh; // Track remaining kWh to be calculated

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proses Perhitungan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),

            // Total Tagihan Awal
            _buildCompactListTile(
              title: 'Total Tagihan',
              trailing: Text(
                currencyFormat.format(biaya),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            // Pengurangan komponen biaya
            _buildCompactListTile(
              title: 'PPJ ($wilayah)',
              subtitle: '${(ppjRate * 100).toStringAsFixed(1)}%',
              trailing: Text(
                '- ${currencyFormat.format(ppjNominal)}',
                style: const TextStyle(color: Colors.red),
              ),
            ),

            if (!isPrabayar)
              _buildCompactListTile(
                title: 'Biaya Minimal Dibayar',
                trailing: Text(
                  currencyFormat.format(bebanBiaya),
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),

            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Biaya untuk perhitungan KWH:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    currencyFormat.format(biaya - ppjNominal),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Rincian perhitungan per blok

            Text(
              (!isPrabayar) ? 'Perhitungan per Blok:' : 'Perhitungan Kwh:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            ...blocks.map((block) {
              double blockKwh = 0;

              // Hitung kWh untuk blok ini
              if (remainingKwh > 0) {
                // Convert int to double explicitly
                double maxBlockKwh = (block.endKwh - block.startKwh).toDouble();

                // Ambil minimum antara sisa kWh dan maksimum blok
                blockKwh =
                    remainingKwh > maxBlockKwh ? maxBlockKwh : remainingKwh;

                // Kurangi sisa kWh
                remainingKwh -= blockKwh;
              }

              double blockCost = blockKwh * block.rate;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPrabayar)
                      Text('Blok ${block.startKwh + 1}-${block.endKwh} kWh:'),
                    if (blockKwh > 0) // Only show blocks that are used
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '${currencyFormat.format(blockCost)} ÷ ${currencyFormat.format(block.rate)}/kWh = ${decimalFormat.format(blockKwh)} kWh',
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),

            const Divider(thickness: 2),
            // Hasil KWH sebagai highlight utama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total KWH:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${decimalFormat.format(calculatedKwh)} kWh', // Updated this line
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
