import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';
import 'package:rburger/driver%20folder/driver_order_tab.dart';


class DriverOrderTabs extends StatelessWidget {
  final DriverOrderTab selected;
  final ValueChanged<DriverOrderTab> onChanged;

  const DriverOrderTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: DriverOrderTab.values.map((tab) {
        final isSelected = tab == selected;
        return GestureDetector(
          onTap: () => onChanged(tab),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.maroon950 : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.maroon950 : AppColors.maroon800,
                width: 1.2,
              ),
            ),
            child: Text(
              tab.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.maroon800,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
