import 'package:flutter/material.dart';

class PowerSelector extends StatelessWidget {
  final List<int> powers;
  final int selectedPower;
  final ValueChanged<int> onChanged;

  const PowerSelector({
    super.key,
    required this.powers,
    required this.selectedPower,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daya Tersambung',
          style: TextStyle(
            fontSize: 16,
            color: Colors.amber.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: powers.map((power) {
            final isSelected = power == selectedPower;
            return ChoiceChip(
              label: Text('$power VA'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onChanged(power);
              },
              selectedColor: Colors.amber.shade200,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black87 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
