import 'water_subscription_group.dart';

class WaterTariff {
  static double getTariff(WaterSubscriptionGroup group, double usage) {
    // Menentukan blok tarif berdasarkan pemakaian
    int block = usage <= 10
        ? 1
        : usage <= 20
            ? 2
            : 3;

    switch (group) {
      case WaterSubscriptionGroup.kelompokI:
        switch (block) {
          case 1:
            return 1500; // 0-10 m3
          case 2:
            return 1500; // 11-20 m3
          case 3:
            return 1500; // >20 m3
        }

      case WaterSubscriptionGroup.kelompokII:
        switch (block) {
          case 1:
            return 1650;
          case 2:
            return 1650;
          case 3:
            return 1650;
        }

      case WaterSubscriptionGroup.kelompokIIIa:
        switch (block) {
          case 1:
            return 3500;
          case 2:
            return 4000;
          case 3:
            return 4500;
        }

      case WaterSubscriptionGroup.kelompokIIIb:
        switch (block) {
          case 1:
            return 5500;
          case 2:
            return 6500;
          case 3:
            return 8000;
        }

      case WaterSubscriptionGroup.kelompokIIIc:
        switch (block) {
          case 1:
            return 7000;
          case 2:
            return 7500;
          case 3:
            return 8500;
        }

      case WaterSubscriptionGroup.kelompokIVa:
        switch (block) {
          case 1:
            return 8500;
          case 2:
            return 10000;
          case 3:
            return 11000;
        }

      case WaterSubscriptionGroup.kelompokIVb:
        switch (block) {
          case 1:
            return 12000;
          case 2:
            return 14000;
          case 3:
            return 15000;
        }
    }
    return 0;
  }

  // Biaya tetap per bulan
  static const double adminCharge = 13000.0;
  // static const double maintenanceCharge = 3500.0;
  // static const double meterCharge = 2500.0;

  static double calculateBill(WaterSubscriptionGroup group, double usage) {
    double total = 0;

    // Hitung pemakaian per blok
    if (usage <= 10) {
      total += usage * getTariff(group, 5); // Blok 1
    } else if (usage <= 20) {
      total += 10 * getTariff(group, 5); // Blok 1 penuh
      total += (usage - 10) * getTariff(group, 15); // Sisa di Blok 2
    } else {
      total += 10 * getTariff(group, 5); // Blok 1 penuh
      total += 10 * getTariff(group, 15); // Blok 2 penuh
      total += (usage - 20) * getTariff(group, 25); // Sisa di Blok 3
    }

    // Tambahkan biaya tetap
    total += adminCharge;

    return total;
  }
}
