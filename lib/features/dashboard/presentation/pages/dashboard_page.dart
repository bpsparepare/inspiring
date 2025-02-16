import 'package:flutter/material.dart';
import '../../../../core/constants/menu_items.dart';
import '../../domain/entities/menu_item.dart';
import '../widgets/menu_card.dart';
import '../widgets/header_widget.dart';
import '../widgets/search_box.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> filteredItems = MenuItems.items;
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = MenuItems.items.where((item) {
        return item.title.toLowerCase().contains(query.toLowerCase()) ||
            (item.subtitle?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();
    });
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildSectionHeader(String title, bool hasMore, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasMore)
          TextButton.icon(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: isExpanded ? 0.5 : 0,
              child: const Icon(Icons.expand_more),
            ),
            label: Text(
              isExpanded ? 'Lebih Sedikit' : 'Lihat Semua',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  double _calculateGridHeight(BuildContext context, int itemCount) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final itemWidth = (size.width - (5 * 16)) / 4; // width minus paddings
    final itemHeight = itemWidth * 1.2; // aspect ratio 0.8
    final rows = (itemCount / 4).ceil();
    final calculatedHeight =
        rows * itemHeight + ((rows - 1) * 16); // height plus spacing

    // Limit height in portrait, but allow scrolling in landscape
    if (isPortrait) {
      return calculatedHeight;
    } else {
      return size.height - 200; // Approximate height minus header
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems =
        isExpanded ? filteredItems : filteredItems.take(8).toList();
    final mediaQuery = MediaQuery.of(context);
    final bool isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeaderWidget(),
                    const SizedBox(height: 16),
                    SearchBox(
                      controller: _searchController,
                      onChanged: _filterItems,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Fitur Aplikasi',
                      filteredItems.length > 8,
                      _toggleExpand,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isPortrait ? 4 : 6;
                        final childAspectRatio = isPortrait ? 0.8 : 1.0;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: displayedItems.length,
                          itemBuilder: (context, index) {
                            return MenuCard(menuItem: displayedItems[index]);
                          },
                        );
                      },
                    ),
                    if (filteredItems.length > 8 && !isExpanded)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 16),
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
