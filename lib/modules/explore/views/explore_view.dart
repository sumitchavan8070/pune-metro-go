import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/routes/app_routes.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/theme/app_radius.dart';
import 'package:pune_metro_guide/app/theme/app_text_styles.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/line_color.dart';
import 'package:pune_metro_guide/app/widgets/pm_search_field.dart';
import 'package:pune_metro_guide/modules/explore/controllers/explore_controller.dart';
import 'package:pune_metro_guide/modules/explore/data/explore_catalog.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(brightness);
    final showBack = ModalRoute.of(context)?.settings.name == AppRoutes.explore;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: const Text('Explore Pune'),
      ),
      body: Obx(() {
        final places = controller.visible;
        final showPopular = controller.query.value.trim().isEmpty && controller.category.value == ExploreCategory.all;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _ExploreBanner(),
            const SizedBox(height: 16),
            PmSearchField(
              controller: controller.searchController,
              hint: 'Search places or stations',
              onChanged: (value) => controller.query.value = value,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ExploreCategory.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = ExploreCategory.values[index];
                  final selected = controller.category.value == item;
                  return FilterChip(
                    label: Text(exploreCategoryLabel(item)),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) => controller.category.value = item,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Sort', style: AppTextStyles.bodySmall.copyWith(color: muted)),
                const SizedBox(width: 8),
                DropdownButton<ExploreSort>(
                  value: controller.sort.value,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: ExploreSort.featured, child: Text('Featured')),
                    DropdownMenuItem(value: ExploreSort.distance, child: Text('Distance')),
                    DropdownMenuItem(value: ExploreSort.station, child: Text('Nearest station')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.sort.value = value;
                    }
                  },
                ),
              ],
            ),
            if (showPopular) ...[
              const SizedBox(height: 8),
              Text('Popular places', style: AppTextStyles.titleLarge),
              const SizedBox(height: 10),
              SizedBox(
                height: 248,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.popular.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final place = controller.popular[index];
                    return _PopularCard(place: place, link: controller.linkFor(place));
                  },
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              showPopular ? 'All places' : 'Places',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 10),
            if (places.isEmpty)
              Text(
                'No places match this search.',
                style: AppTextStyles.bodyMedium.copyWith(color: muted),
              )
            else
              for (var index = 0; index < places.length; index++)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 260 + index * 40),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, (1 - value) * 10), child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DestinationCard(place: places[index], link: controller.linkFor(places[index])),
                  ),
                ),
          ],
        );
      }),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        gradient: const LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.secondaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore Pune', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white)),
          const SizedBox(height: 6),
          Text(
            'Discover amazing places around Pune Metro.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withValues(alpha: 0.92)),
          ),
        ],
      ),
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.place, required this.link});

  final ExplorePlace place;
  final ExploreStationLink? link;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: _DestinationCard(place: place, link: link, compact: true),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.place, required this.link, this.compact = false});

  final ExplorePlace place;
  final ExploreStationLink? link;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final muted = AppColors.textSecondary(brightness);
    final station = link?.station;
    final line = link?.line;
    return Material(
      color: AppColors.surface(brightness),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: AppColors.border(brightness)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.explorePlace.replaceFirst(':id', place.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: compact ? 88 : 150,
              width: double.infinity,
              child: _PlaceImage(asset: place.imageAsset),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exploreCategoryLabel(place.category), style: AppTextStyles.caption.copyWith(color: AppColors.primary(brightness))),
                  const SizedBox(height: 2),
                  Text(place.name, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(place.summary, style: AppTextStyles.bodySmall.copyWith(color: muted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    station == null ? 'Nearest station not confirmed' : station.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (line != null)
                    Text(line.name, style: AppTextStyles.caption.copyWith(color: lineColor(line.color))),
                  if (place.straightLineMetres != null && station != null)
                    Text(
                      '${formatDistanceMetres(place.straightLineMetres!.toDouble())} in a straight line',
                      style: AppTextStyles.caption.copyWith(color: muted),
                    ),
                  if (place.roughWalkMinutes != null)
                    Text(
                      'About ${place.roughWalkMinutes} min, rough guide',
                      style: AppTextStyles.caption.copyWith(color: muted),
                    ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.explorePlace.replaceFirst(':id', place.id)),
                        child: const Text('View details'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceImage extends StatelessWidget {
  const _PlaceImage({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.primaryPurpleLight,
        child: Center(child: Icon(Icons.photo_outlined, color: AppColors.primaryPurple)),
      ),
    );
  }
}
