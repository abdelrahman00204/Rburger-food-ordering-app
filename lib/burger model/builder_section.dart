import 'package:flutter/material.dart';
import 'package:rburger/burger%20model/builder_option_chip.dart';
import 'package:rburger/burger%20model/burger_selection.dart';

class BuilderSection extends StatelessWidget {
  final String title;
  final String? hint;
  final List<BurgerIngredient> options;
  final bool Function(BurgerIngredient option) isSelected;
  final void Function(BurgerIngredient option) onSelect;

  const BuilderSection({
    super.key,
    required this.title,
    required this.options,
    required this.isSelected,
    required this.onSelect,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            children: [
              TextSpan(text: title),
              if (hint != null)
                TextSpan(
                  text: ' ($hint)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options
              .map(
                (option) => BuilderOptionChip(
                  label: option.chipLabel,
                  selected: isSelected(option),
                  onTap: () => onSelect(option),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
