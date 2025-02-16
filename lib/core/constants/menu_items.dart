import 'package:flutter/material.dart';
import '../../features/dashboard/domain/entities/menu_item.dart';

class MenuItems {
  static const List<MenuItem> items = [
    MenuItem(
      title: 'Kamera',
      subtitle: 'Foto & Video',
      icon: Icons.camera_alt,
      route: '/camera',
      color: Colors.blue,
    ),
    MenuItem(
      title: 'Hitung kWh',
      subtitle: 'Meteran Listrik',
      icon: Icons.electric_bolt,
      route: '/kwh',
      color: Colors.orange,
    ),
    MenuItem(
      title: 'Hitung Air',
      subtitle: 'Meteran PDAM',
      icon: Icons.water_drop,
      route: '/water',
      color: Colors.cyan,
    ),
    MenuItem(
      title: 'GPS',
      subtitle: 'Lokasi & Koordinat',
      icon: Icons.location_on,
      route: '/gps',
      color: Colors.red,
    ),
    MenuItem(
      title: 'Kesehatan',
      subtitle: 'Catatan & Dokumen',
      icon: Icons.note_add,
      route: '/notes',
      color: Colors.green,
    ),
    MenuItem(
      title: 'Harga-harga',
      subtitle: 'QR & Barcode',
      icon: Icons.qr_code_scanner,
      route: '/scanner',
      color: Colors.purple,
    ),
    MenuItem(
      title: 'Survey',
      subtitle: 'Form Digital',
      icon: Icons.assignment,
      route: '/survey',
      color: Colors.indigo,
      isNew: true,
    ),
    MenuItem(
      title: 'OCR',
      subtitle: 'Scan Text',
      icon: Icons.document_scanner,
      route: '/ocr',
      color: Colors.brown,
      isBeta: true,
    ),
    MenuItem(
      title: 'Voice Notes',
      subtitle: 'Rekam Suara',
      icon: Icons.mic,
      route: '/voice',
      color: Colors.teal,
      isNew: true,
    ),
    MenuItem(
      title: 'Kalkulasi',
      subtitle: 'Perhitungan Survei',
      icon: Icons.calculate,
      route: '/calculator',
      color: Colors.deepPurple,
    ),
    MenuItem(
      title: 'Peta',
      subtitle: 'Area & Wilayah',
      icon: Icons.map,
      route: '/map',
      color: Colors.greenAccent,
      isBeta: true,
    ),
    MenuItem(
      title: 'Sync',
      subtitle: 'Sinkronisasi Data',
      icon: Icons.sync,
      route: '/sync',
      color: Colors.blueGrey,
    ),
  ];
}
