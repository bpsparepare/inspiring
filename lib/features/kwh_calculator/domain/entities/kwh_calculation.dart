class KwhCalculation {
  final double totalBiaya;
  final int dayaPower;
  final bool isPrabayar;
  final String wilayah;
  final double? tarifPerKwh;
  final double? totalKwh;
  final double? ppj; // Pajak Penerangan Jalan
  final double? adminCharge;

  KwhCalculation({
    required this.totalBiaya,
    required this.dayaPower,
    required this.isPrabayar,
    required this.wilayah,
    this.tarifPerKwh,
    this.totalKwh,
    this.ppj,
    this.adminCharge,
  });
}
