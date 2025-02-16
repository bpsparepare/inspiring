import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini
import '../domain/entities/photo_info.dart';

class ImageStamper {
  static Future<void> stampImage({
    required String sourceImagePath,
    required PhotoInfo photoInfo,
  }) async {
    try {
      // Baca gambar
      final File imageFile = File(sourceImagePath);
      final bytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) throw Exception('Failed to decode image');

      // Format waktu dan tanggal
      final jam = DateFormat('HH:mm').format(photoInfo.timestamp);
      final hariTanggal =
          DateFormat('EEEE, dd-MM-yyyy', 'id_ID').format(photoInfo.timestamp);

      // Ukuran dan posisi
      final height = originalImage.height;
      final width = originalImage.width;
      final boxHeight = 220; // Tinggi area stamp diperbesar
      final leftPadding = 30;
      final rightPadding = 30;
      final bottomPadding = 25;
      final topPadding = 20;

      // Background overlay hitam transparan
      img.fillRect(
        originalImage,
        x1: 0,
        y1: height - boxHeight,
        x2: width,
        y2: height,
        color: img.ColorRgba8(0, 0, 0, 200),
      );

      // Rectangle orange untuk jam
      final timeBoxWidth = 180;
      final timeBoxHeight = 80;
      final timeBoxY = height - boxHeight + topPadding;

      // Kotak orange dengan border putih
      img.fillRect(
        originalImage,
        x1: leftPadding,
        y1: timeBoxY,
        x2: leftPadding + timeBoxWidth,
        y2: timeBoxY + timeBoxHeight,
        color: img.ColorRgba8(255, 140, 0, 255),
      );

      img.drawRect(
        originalImage,
        x1: leftPadding - 1,
        y1: timeBoxY - 1,
        x2: leftPadding + timeBoxWidth + 1,
        y2: timeBoxY + timeBoxHeight + 1,
        color: img.ColorRgba8(255, 255, 255, 255),
        thickness: 2,
      );

      // Font setup
      final largeFont = img.arial48;
      final normalFont = img.arial24;
      final smallFont = img.arial14;

      // Jam dalam kotak orange
      img.drawString(
        originalImage,
        jam,
        font: largeFont,
        x: leftPadding + 20,
        y: timeBoxY + 15,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      // Hari dan tanggal di bawah kotak orange (dalam satu baris)
      img.drawString(
        originalImage,
        hariTanggal,
        font: smallFont,
        x: leftPadding,
        y: timeBoxY + timeBoxHeight + 15,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      // Koordinat (dua baris, rata kanan)
      final coordLines = photoInfo.coordinatesFormatted.split('\n');
      final coordX = width - 350; // Lebih ke kiri
      final coordY = timeBoxY + 15;

      img.drawString(
        originalImage,
        coordLines[0], // Latitude
        font: normalFont,
        x: coordX,
        y: coordY,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      if (coordLines.length > 1) {
        img.drawString(
          originalImage,
          coordLines[1], // Longitude
          font: normalFont,
          x: coordX,
          y: coordY + 30,
          color: img.ColorRgba8(255, 255, 255, 255),
        );
      }

      // Alamat dan Catatan (di bawah, sebelah kiri)
      final addressWords = photoInfo.address.split(' ');
      final midPoint = (addressWords.length / 2).ceil();
      final addressLine1 = addressWords.take(midPoint).join(' ');
      final addressLine2 = addressWords.skip(midPoint).join(' ');

      final addressY = height - 70; // Posisi alamat dinaikkan

      img.drawString(
        originalImage,
        addressLine1,
        font: normalFont,
        x: leftPadding,
        y: addressY,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      if (addressLine2.isNotEmpty) {
        img.drawString(
          originalImage,
          addressLine2,
          font: normalFont,
          x: leftPadding,
          y: addressY + 25,
          color: img.ColorRgba8(255, 255, 255, 255),
        );
      }

      // Catatan Susenas (di bawah alamat, sebelah kiri)
      img.drawString(
        originalImage,
        "Catatan: Susenas Maret 2025",
        font: smallFont,
        x: leftPadding,
        y: height - 25,
        color: img.ColorRgba8(255, 255, 255, 255),
      );

      // Simpan gambar
      final encodedImage = img.encodeJpg(originalImage, quality: 100);
      await File(sourceImagePath).writeAsBytes(encodedImage);
    } catch (e) {
      debugPrint('Error stamping image: $e');
      if (e.toString().contains('date')) {
        debugPrint(
            'Error format tanggal: pastikan initializeDateFormatting sudah dipanggil');
      } else if (e is FileSystemException) {
        debugPrint('Error file system: ${e.message}');
      } else if (e is ArgumentError) {
        debugPrint('Error argument: ${e.message}');
      }
      rethrow;
    }
  }
}
