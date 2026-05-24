import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/place_service.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';

/// Scrollable filter bottom sheet for the map page.
class MapFilterSheet extends StatefulWidget {
  const MapFilterSheet({
    super.key,
    required this.initialCategory,
    required this.initialAccessibilityFilters,
    required this.accessFilterOptions,
    required this.onApply,
  });

  final String initialCategory;
  final Set<String> initialAccessibilityFilters;
  final List<MapEntry<String, String>> accessFilterOptions;
  final void Function(String category, Set<String> accessibilityFilters) onApply;

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late String _category;
  late Set<String> _filters;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _filters = Set<String>.from(widget.initialAccessibilityFilters);
  }

  void _clear() {
    setState(() {
      _category = 'Tümü';
      _filters.clear();
    });
  }

  void _apply() {
    widget.onApply(_category, _filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: YanYanaColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: YanYanaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text(
                    'Filtrele',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: YanYanaColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: YanYanaColors.textDark,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: YanYanaColors.surfaceSoft,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: YanYanaColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: YanYanaColors.border),
                      ),
                    ),
                    items: PlaceService.categoryFilters
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Erişilebilirlik',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: YanYanaColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...widget.accessFilterOptions.map(
                    (e) => SizedBox(
                      height: 48,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: _filters.contains(e.key),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _filters.add(e.key);
                            } else {
                              _filters.remove(e.key);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottom),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Temizle',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: YanYanaColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Uygula',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMapFilterSheet({
  required BuildContext context,
  required String initialCategory,
  required Set<String> initialAccessibilityFilters,
  required List<MapEntry<String, String>> accessFilterOptions,
  required void Function(String category, Set<String> filters) onApply,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final screenH = MediaQuery.sizeOf(ctx).height;
      final sheetH = screenH * 0.72;
      return Padding(
        padding: EdgeInsets.only(top: screenH * 0.1),
        child: SizedBox(
          height: sheetH,
          child: MapFilterSheet(
            initialCategory: initialCategory,
            initialAccessibilityFilters: initialAccessibilityFilters,
            accessFilterOptions: accessFilterOptions,
            onApply: onApply,
          ),
        ),
      );
    },
  );
}
