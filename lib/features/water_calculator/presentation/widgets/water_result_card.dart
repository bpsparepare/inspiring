import 'package:flutter/material.dart';
import '../../domain/entities/water_subscription_group.dart';
import '../../domain/entities/water_tariff.dart';

class WaterBlock {
  final String name;
  final String range;
  final double usage;
  final double rate;
  final double cost;
  final Color color;

  WaterBlock({
    required this.name,
    required this.range,
    required this.usage,
    required this.rate,
    required this.cost,
    required this.color,
  });
}

class WaterResultCard extends StatelessWidget {
  final double targetBill;
  final WaterSubscriptionGroup group;

  const WaterResultCard({
    super.key,
    required this.targetBill,
    required this.group,
  });

  double _calculateUsage() {
    double remainingBill = targetBill - WaterTariff.adminCharge;
    final bloc1Rate = WaterTariff.getTariff(group, 5);
    final bloc2Rate = WaterTariff.getTariff(group, 15);
    final bloc3Rate = WaterTariff.getTariff(group, 25);

    // Hitung Blok 1 (0-10 m³)
    final maxBloc1Cost = 10.0 * bloc1Rate;
    if (remainingBill <= maxBloc1Cost) {
      return remainingBill / bloc1Rate;
    }
    remainingBill -= maxBloc1Cost;

    // Hitung Blok 2 (11-20 m³)
    final maxBloc2Cost = 10.0 * bloc2Rate;
    if (remainingBill <= maxBloc2Cost) {
      return 10.0 + (remainingBill / bloc2Rate);
    }
    remainingBill -= maxBloc2Cost;

    // Hitung Blok 3 (>20 m³)
    return 20.0 + (remainingBill / bloc3Rate);
  }

  List<WaterBlock> _getWaterBlocks(double usage) {
    final blocks = <WaterBlock>[];
    final bloc1Usage = usage <= 10 ? usage : 10.0;
    final bloc2Usage = usage <= 10 ? 0.0 : (usage <= 20 ? usage - 10 : 10.0);
    final bloc3Usage = usage <= 20 ? 0.0 : usage - 20;

    if (bloc1Usage > 0) {
      blocks.add(WaterBlock(
        name: 'Blok 1',
        range: '0-10 m³',
        usage: bloc1Usage,
        rate: WaterTariff.getTariff(group, 5),
        cost: bloc1Usage * WaterTariff.getTariff(group, 5),
        color: Colors.cyan.shade100,
      ));
    }

    if (bloc2Usage > 0) {
      blocks.add(WaterBlock(
        name: 'Blok 2',
        range: '11-20 m³',
        usage: bloc2Usage,
        rate: WaterTariff.getTariff(group, 15),
        cost: bloc2Usage * WaterTariff.getTariff(group, 15),
        color: Colors.cyan.shade200,
      ));
    }

    if (bloc3Usage > 0) {
      blocks.add(WaterBlock(
        name: 'Blok 3',
        range: '> 20 m³',
        usage: bloc3Usage,
        rate: WaterTariff.getTariff(group, 25),
        cost: bloc3Usage * WaterTariff.getTariff(group, 25),
        color: Colors.cyan.shade300,
      ));
    }

    return blocks;
  }

  String _formatNumber(double number) =>
      number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final usage = _calculateUsage();
    final waterBlocks = _getWaterBlocks(usage);
    final waterOnlyBill = targetBill - WaterTariff.adminCharge;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: 16),
            _buildCostSection(waterOnlyBill),
            const Divider(height: 32),
            _buildBlocksSection(waterBlocks),
            const Divider(height: 16),
            _buildTotalUsage(usage),
            const Divider(height: 32),
            _buildGroupInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
        children: [
          Icon(Icons.water_drop, color: Colors.cyan.shade700),
          const SizedBox(width: 8),
          const Text(
            'Hasil Perhitungan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );

  Widget _buildCostSection(double waterOnlyBill) => Column(
        children: [
          _buildResultRow(
              'Biaya Admin', 'Rp ${_formatNumber(WaterTariff.adminCharge)}'),
          _buildResultRow(
            'Biaya Air',
            'Rp ${_formatNumber(waterOnlyBill)}',
            subtitle: '(Total Tagihan - Admin)',
          ),
        ],
      );

  Widget _buildBlocksSection(List<WaterBlock> blocks) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rincian Penggunaan per Blok',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyan.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ...blocks.map((block) => _buildBlockCard(block)),
        ],
      );

  Widget _buildBlockCard(WaterBlock block) => Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: block.color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(block.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(block.range,
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${block.usage.toStringAsFixed(1)} m³ × Rp ${_formatNumber(block.rate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Rp ${_formatNumber(block.cost)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildTotalUsage(double usage) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.cyan.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.cyan.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, color: Colors.cyan.shade700, size: 40),
            const SizedBox(width: 16),
            Column(
              children: [
                const Text('Total Pemakaian',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: usage.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                      TextSpan(
                        text: ' m³',
                        style: TextStyle(
                            fontSize: 24, color: Colors.cyan.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildGroupInfo() => Text(
        'Kelompok: ${group.display}\n${group.description}',
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );

  Widget _buildResultRow(String label, String value,
      {bool isBold = false, Color? textColor, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
