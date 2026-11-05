import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';

class PmBottomNavigation extends StatelessWidget {
  const PmBottomNavigation({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.alt_route_outlined, Icons.alt_route, 'Plan Journey'),
    (Icons.map_outlined, Icons.map, 'Metro Map'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final primary = AppColors.primary(brightness);
    final muted = AppColors.textSecondary(brightness);
    return Material(
      color: brightness == Brightness.dark ? AppColors.elevatedDark : AppColors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var item = 0; item < _items.length; item++)
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(item),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          duration: const Duration(milliseconds: 180),
                          scale: index == item ? 1.08 : 1,
                          child: Icon(
                            index == item ? _items[item].$2 : _items[item].$1,
                            color: index == item ? primary : muted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[item].$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: index == item ? primary : muted,
                            fontWeight: index == item ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
