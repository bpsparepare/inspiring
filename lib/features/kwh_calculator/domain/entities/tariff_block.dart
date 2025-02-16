import 'tariff_type.dart';

class TariffBlock {
  final int startKwh;
  final int endKwh;
  final double rate;

  const TariffBlock({
    required this.startKwh,
    required this.endKwh,
    required this.rate,
  });
}

class TariffBlockCalculator {
  static List<TariffBlock> getBlocks(int power, bool isPrabayar,
      {TariffType? tariffType}) {
    // Prabayar menggunakan tarif flat
    if (isPrabayar) {
      return [
        TariffBlock(
          startKwh: 0,
          endKwh: 999999,
          rate: getTariffRate(power, tariffType: tariffType),
        ),
      ];
    }

    // Pascabayar menggunakan tarif blok
    switch (power) {
      case 450:
        return const [
          TariffBlock(startKwh: 0, endKwh: 30, rate: 169),
          TariffBlock(startKwh: 30, endKwh: 60, rate: 360),
          TariffBlock(startKwh: 60, endKwh: 999999, rate: 495),
        ];

      case 900:
        if (tariffType == TariffType.subsidi) {
          return const [
            TariffBlock(startKwh: 0, endKwh: 20, rate: 275),
            TariffBlock(startKwh: 20, endKwh: 60, rate: 445),
            TariffBlock(startKwh: 60, endKwh: 999999, rate: 495),
          ];
        } else {
          return const [
            TariffBlock(startKwh: 0, endKwh: 999999, rate: 1352),
          ];
        }

      case 1300:
        return const [
          TariffBlock(startKwh: 0, endKwh: 999999, rate: 1444.70),
        ];
      case 2200:
        return const [
          TariffBlock(startKwh: 0, endKwh: 999999, rate: 1444.70),
        ];

      case 3500:
        return const [
          TariffBlock(startKwh: 0, endKwh: 999999, rate: 1699.53),
        ];
      case 4400:
        return const [
          TariffBlock(startKwh: 0, endKwh: 999999, rate: 1699.53),
        ];

      default:
        return const [
          TariffBlock(startKwh: 0, endKwh: 999999, rate: 1444.70),
        ];
    }
  }

  static double getTariffRate(int power, {TariffType? tariffType}) {
    if (power == 900) {
      return tariffType == TariffType.subsidi ? 605.0 : 1352.0;
    }

    switch (power) {
      case 450:
        return 415.0;
      case 1300:
      case 2200:
        return 1444.70;
      case 3500:
      case 4400:
        return 1699.53;
      default:
        return 1444.70;
    }
  }

  static double getBebanBiaya(int power, bool isPrabayar,
      {TariffType? tariffType}) {
    // Prabayar tidak ada biaya beban
    if (isPrabayar) return 0;

    // Biaya beban tetap untuk pascabayar
    switch (power) {
      case 450:
        return 11000; // Rp 4.950 untuk R1/450VA
      case 900:
        return tariffType == TariffType.subsidi
            ? 48672 // (40x900/1000X1352)
            : 20000; // Rp 18.000 untuk R1/900VA non-subsidi
      case 1300:
        return 75124; // Rp 75.124 untuk R1/1300VA
      case 2200:
        return 127133; // Rp 127.113 untuk R1/2200VA
      case 3500:
        return 237934; // Rp 127.113 untuk R1/2200VA
      default:
        return 0; // Daya lainnya tidak ada biaya beban
    }
  }
}
