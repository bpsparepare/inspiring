import 'package:flutter/material.dart';

enum MeterType {
  prabayar('Prabayar', 'Token', Icons.electric_bolt),
  pascabayar('Pascabayar', 'Bulanan', Icons.calendar_month);

  final String display;
  final String description;
  final IconData icon;

  const MeterType(this.display, this.description, this.icon);
}
