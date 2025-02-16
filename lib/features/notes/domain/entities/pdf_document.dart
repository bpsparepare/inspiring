class PdfDocument {
  final String title;
  final String assetPath;
  final String? description;

  const PdfDocument({
    required this.title,
    required this.assetPath,
    this.description,
  });
}

class PdfDocuments {
  static const List<PdfDocument> items = [
    PdfDocument(
      title: 'Panduan Susenas 2025',
      assetPath: 'assets/pdfs/panduan_susenas_2025.pdf',
      description: 'Buku pedoman pencacahan Susenas 2025',
    ),
    PdfDocument(
      title: 'Kuesioner Individu',
      assetPath: 'assets/pdfs/kuesioner_individu.pdf',
      description: 'Kuesioner kor individu Susenas 2025',
    ),
    // Tambahkan dokumen PDF lainnya di sini
  ];
}
