import 'package:flutter/material.dart';
import '../../domain/entities/menu_item.dart';

class MenuCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuCard({
    super.key,
    required this.menuItem,
  });

  // Daftar route yang sudah tersedia
  static const List<String> availableRoutes = [
    '/camera',
    '/kwh',
    '/gps',
    '/notes',
    '/water',
    '/scanner',
  ];

  void _handleTap(BuildContext context) {
    if (availableRoutes.contains(menuItem.route)) {
      Navigator.pushNamed(context, menuItem.route);
    } else {
      // Hapus snackbar yang sedang ditampilkan (jika ada)
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fitur ${menuItem.title} belum tersedia'),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 800), // Durasi lebih singkat
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Hero(
        tag: menuItem.route,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTap(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: menuItem.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: menuItem.color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          menuItem.icon,
                          color: menuItem.color,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (menuItem.isNew || menuItem.isBeta)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (menuItem.isNew ? Colors.green : Colors.orange)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        menuItem.isNew ? 'Baru' : 'Beta',
                        style: TextStyle(
                          color: menuItem.isNew ? Colors.green : Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      menuItem.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
