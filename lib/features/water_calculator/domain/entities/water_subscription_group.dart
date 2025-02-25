enum WaterSubscriptionGroup {
  kelompokI('Kelompok I', 'Mesjid'),
  kelompokII('Kelompok II', 'Panti Asuhan'),
  kelompokIIIa('Kelompok III A', 'Rumah Tangga Tipe < 21 '),
  kelompokIIIb(
      'Kelompok III B', 'Rumah Tangga Tipe 21 - 150, Tidak Bertingkat'),
  kelompokIIIc('Kelompok III C',
      'Rumah Tangga Tipe >150 dan Bertingkat, Ruko, Praktek Dokter '),
  kelompokIVa('Kelompok IV A', 'Luas Tanah >300, rumah dinas'),
  kelompokIVb('Kelompok IV B', 'Industri, Rumah 700 juta keatas');

  final String display;
  final String description;

  const WaterSubscriptionGroup(this.display, this.description);
}
