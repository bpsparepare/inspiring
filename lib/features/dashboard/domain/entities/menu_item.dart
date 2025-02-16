import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String route;
  final Color color;
  final bool isNew;
  final bool isBeta;

  const MenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
    this.isNew = false,
    this.isBeta = false,
  });
}
