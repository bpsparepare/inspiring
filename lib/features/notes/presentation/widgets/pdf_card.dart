import 'dart:io';
import 'package:flutter/material.dart';

class PdfCard extends StatelessWidget {
  final File file;
  final VoidCallback onTap;

  const PdfCard({
    super.key,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final fileSize = (file.lengthSync() / 1024 / 1024).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$fileSize MB'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
