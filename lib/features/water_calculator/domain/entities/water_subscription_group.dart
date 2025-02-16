enum WaterSubscriptionGroup {
  kelompokI('Kelompok I', 'Sosial Umum, Hidran Umum'),
  kelompokII('Kelompok II', 'Rumah Tangga A'),
  kelompokIIIa('Kelompok III A', 'Rumah Tangga B'),
  kelompokIIIb('Kelompok III B', 'Instansi Pemerintah'),
  kelompokIIIc('Kelompok III C', 'Niaga Kecil'),
  kelompokIVa('Kelompok IV A', 'Niaga Besar'),
  kelompokIVb('Kelompok IV B', 'Industri');

  final String display;
  final String description;

  const WaterSubscriptionGroup(this.display, this.description);
}
