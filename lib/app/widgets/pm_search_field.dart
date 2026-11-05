import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';

class PmSearchField extends StatelessWidget {
  const PmSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search stations',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (controller.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close),
            );
          },
        ),
      ),
    );
  }
}
