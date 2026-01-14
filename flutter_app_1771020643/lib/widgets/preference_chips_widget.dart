// lib/widgets/preference_chips_widget.dart
import 'package:flutter/material.dart';

class PreferenceChipsWidget extends StatelessWidget {
  final List<String> allPreferences;
  final List<String> selectedPreferences;
  final Function(List<String>) onSelectionChanged;

  const PreferenceChipsWidget({
    super.key,
    required this.allPreferences,
    required this.selectedPreferences,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allPreferences.map((preference) {
        final isSelected = selectedPreferences.contains(preference);
        
        String displayText = preference;
        IconData? icon;
        
        // Map preference to display text and icon
        switch (preference) {
          case 'vegetarian':
            displayText = 'Ăn chay';
            icon = Icons.eco;
            break;
          case 'spicy':
            displayText = 'Đồ cay';
            icon = Icons.local_fire_department;
            break;
          case 'seafood':
            displayText = 'Hải sản';
            icon = Icons.set_meal;
            break;
        }

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16),
                const SizedBox(width: 4),
              ],
              Text(displayText),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = List<String>.from(selectedPreferences);
            if (selected) {
              newSelection.add(preference);
            } else {
              newSelection.remove(preference);
            }
            onSelectionChanged(newSelection);
          },
          selectedColor: Colors.orange.withOpacity(0.2),
          checkmarkColor: Colors.orange,
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? Colors.orange : Colors.grey[300]!,
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}