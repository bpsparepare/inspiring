import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/water_subscription_group.dart';
import '../../domain/entities/water_tariff.dart';
import '../widgets/water_group_selector.dart';
import '../widgets/water_result_card.dart';

/// Halaman kalkulator pemakaian air PDAM
/// Menghitung estimasi pemakaian air berdasarkan total tagihan
class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  // Form key untuk validasi input
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input total tagihan
  final _biayaController = TextEditingController();

  // Default group pelanggan
  WaterSubscriptionGroup _selectedGroup = WaterSubscriptionGroup.kelompokIIIb;

  // Flag untuk menampilkan hasil perhitungan
  bool _showResult = false;

  /// Memvalidasi input dan menampilkan hasil perhitungan
  void _calculateUsage() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _showResult = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_showResult) ...[
                const SizedBox(height: 16),
                _buildResultCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun AppBar dengan judul dan warna tema
  PreferredSizeWidget _buildAppBar() => AppBar(
        title: const Text('Kalkulator Air PDAM'),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
      );

  /// Membangun card untuk input tagihan dan pemilihan kelompok
  Widget _buildInputCard() => Card(
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
              _buildBillInput(),
              const SizedBox(height: 24),
              _buildGroupSelector(),
            ],
          ),
        ),
      );

  /// Membangun input field untuk total tagihan dengan format rupiah
  Widget _buildBillInput() => TextFormField(
        controller: _biayaController,
        decoration: const InputDecoration(
          labelText: 'Total Tagihan (Rp)',
          border: OutlineInputBorder(),
          prefixText: 'Rp ',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _createRupiahFormatter(),
        ],
        validator: (value) =>
            value?.isEmpty ?? true ? 'Masukkan total tagihan' : null,
      );

  /// Membangun selector untuk kelompok pelanggan
  Widget _buildGroupSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kelompok Pelanggan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyan.shade700,
            ),
          ),
          const SizedBox(height: 16),
          WaterGroupSelector(
            selectedGroup: _selectedGroup,
            onChanged: (group) => setState(() => _selectedGroup = group),
          ),
        ],
      );

  /// Membangun tombol untuk menghitung pemakaian
  Widget _buildCalculateButton() => ElevatedButton(
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
      );

  /// Membangun card hasil perhitungan
  Widget _buildResultCard() => WaterResultCard(
        targetBill: double.parse(_biayaController.text.replaceAll(',', '')),
        group: _selectedGroup,
      );

  /// Membuat formatter untuk format rupiah (dengan pemisah ribuan)
  TextInputFormatter _createRupiahFormatter() =>
      TextInputFormatter.withFunction(
        (oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;
          final value = int.parse(newValue.text);
          final formatted = value.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
          return TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        },
      );

  @override
  void dispose() {
    _biayaController.dispose();
    super.dispose();
  }
}
