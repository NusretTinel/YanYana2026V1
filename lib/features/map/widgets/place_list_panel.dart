import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';

enum PlaceListSort { name, rating }

/// Draggable bottom panel listing saved accessible places.
class PlaceListPanel extends StatelessWidget {
  const PlaceListPanel({
    super.key,
    required this.places,
    required this.scrollController,
    required this.sort,
    required this.onSortChanged,
    required this.onPlaceSelected,
    required this.hasAnyPlaces,
    required this.bottomPadding,
    this.onAddPlace,
    this.selectedPlaceId,
  });

  final List<AccessiblePlace> places;
  final ScrollController scrollController;
  final PlaceListSort sort;
  final ValueChanged<PlaceListSort> onSortChanged;
  final void Function(AccessiblePlace place) onPlaceSelected;
  final bool hasAnyPlaces;
  final double bottomPadding;
  final VoidCallback? onAddPlace;
  final String? selectedPlaceId;

  @override
  Widget build(BuildContext context) {
    final isEmpty = places.isEmpty;

    return Material(
      elevation: 8,
      shadowColor: Colors.black12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      color: YanYanaColors.surface,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _PanelHeader(sort: sort, isEmpty: isEmpty, onSortChanged: onSortChanged)),
            if (!isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    '${places.length} mekan · ${sort == PlaceListSort.name ? 'İsme göre' : 'Puana göre'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: YanYanaColors.textMuted,
                    ),
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: Divider(height: 1, thickness: 1, color: YanYanaColors.border),
            ),
            if (isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: PlaceListEmptyMessage(
                  hasAnyPlaces: hasAnyPlaces,
                  onAddPlace: onAddPlace,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomPadding),
                sliver: SliverList.separated(
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return _PlaceListTile(
                      place: place,
                      selected: place.id == selectedPlaceId,
                      onTap: () => onPlaceSelected(place),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.sort,
    required this.isEmpty,
    required this.onSortChanged,
  });

  final PlaceListSort sort;
  final bool isEmpty;
  final ValueChanged<PlaceListSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: YanYanaColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_rounded,
                color: YanYanaColors.primary.withValues(alpha: 0.85),
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kayıtlı Mekanlar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: YanYanaColors.textDark.withValues(alpha: 0.95),
                  ),
                ),
              ),
              if (!isEmpty)
                PopupMenuButton<PlaceListSort>(
                  tooltip: 'Sırala',
                  initialValue: sort,
                  onSelected: onSortChanged,
                  icon: const Icon(Icons.sort_rounded, size: 22),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: PlaceListSort.name,
                      child: Text('İsme göre (A–Z)', style: TextStyle(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: PlaceListSort.rating,
                      child: Text('Puana göre (yüksek)', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlaceListEmptyMessage extends StatelessWidget {
  const PlaceListEmptyMessage({
    super.key,
    required this.hasAnyPlaces,
    this.onAddPlace,
  });

  final bool hasAnyPlaces;
  final VoidCallback? onAddPlace;

  @override
  Widget build(BuildContext context) {
    if (!hasAnyPlaces) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 36,
              color: YanYanaColors.textLight.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 10),
            const Text(
              'Henüz kayıtlı mekan yok.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: YanYanaColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'İlk erişilebilir mekanı ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: YanYanaColors.textMuted,
                height: 1.35,
              ),
            ),
            if (onAddPlace != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onAddPlace,
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text(
                  'Mekan Ekle',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  backgroundColor: YanYanaColors.primaryLight,
                  foregroundColor: YanYanaColors.primaryDark,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: YanYanaColors.textLight.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          const Text(
            'Filtreye uygun mekan yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: YanYanaColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Filtreleri değiştirmeyi deneyin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: YanYanaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceListTile extends StatelessWidget {
  const _PlaceListTile({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final AccessiblePlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final features = place.accessibilityLabels;

    return Material(
      color: selected
          ? YanYanaColors.primaryLight.withValues(alpha: 0.35)
          : YanYanaColors.surface,
      elevation: selected ? 0 : 0.5,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? YanYanaColors.primary.withValues(alpha: 0.4)
                  : YanYanaColors.border,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: place.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.place_rounded,
                  color: place.color.withValues(alpha: 0.9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: YanYanaColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: YanYanaColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: YanYanaColors.warning.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          place.rating > 0
                              ? place.rating.toStringAsFixed(1)
                              : '—',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: YanYanaColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (features.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: features.take(3).map(_chip).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: YanYanaColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: YanYanaColors.surfaceSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: YanYanaColors.border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: YanYanaColors.textMuted,
        ),
      ),
    );
  }
}

List<AccessiblePlace> sortPlacesForList(
  List<AccessiblePlace> places,
  PlaceListSort sort,
) {
  final list = List<AccessiblePlace>.from(places);
  switch (sort) {
    case PlaceListSort.name:
      list.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      break;
    case PlaceListSort.rating:
      list.sort((a, b) {
        final r = b.rating.compareTo(a.rating);
        if (r != 0) return r;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      break;
  }
  return list;
}
