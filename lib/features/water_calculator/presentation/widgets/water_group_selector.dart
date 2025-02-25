import 'package:flutter/material.dart';
import '../../domain/entities/water_subscription_group.dart';

class WaterGroupSelector extends StatelessWidget {
  final WaterSubscriptionGroup selectedGroup;
  final ValueChanged<WaterSubscriptionGroup> onChanged;

  const WaterGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - 8) / 2; // 8 adalah spacing
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: itemWidth / 100, // Sesuaikan tinggi item
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: WaterSubscriptionGroup.values.map((group) {
                final isSelected = selectedGroup == group;
                return InkWell(
                  onTap: () => onChanged(group),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.cyan.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.cyan : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? Colors.cyan.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected ? Colors.cyan : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                group.display,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.cyan.shade700
                                      : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            group.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
