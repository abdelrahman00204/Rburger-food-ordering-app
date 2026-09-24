import 'package:flutter/material.dart';
import 'package:rburger/app_theme.dart';

class PaymentOption {
  final String id;
  final String label;
  const PaymentOption({required this.id, required this.label});
}

class PaymentMethodToggle extends StatelessWidget {
  final List<PaymentOption> options;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const PaymentMethodToggle({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: _buildOption(options[i])),
        ],
      ],
    );
  }

  Widget _buildOption(PaymentOption option) {
    final selected = option.id == selectedId;
    return GestureDetector(
      onTap: () => onChanged(option.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.maroon950 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.maroon950 : AppColors.maroon800,
            width: 1.2,
          ),
        ),
        child: Text(
          option.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.maroon800,
          ),
        ),
      ),
    );
  }
}