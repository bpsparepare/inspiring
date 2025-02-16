enum TariffType {
  subsidi,
  nonSubsidi;

  String get display {
    switch (this) {
      case TariffType.subsidi:
        return 'Subsidi';
      case TariffType.nonSubsidi:
        return 'Non-Subsidi';
    }
  }
}
