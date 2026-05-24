import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/place_categories.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';

/// Form data returned from [showPlaceFormDialog].
class PlaceFormResult {
  const PlaceFormResult({
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.wheelchairAccessible,
    required this.hasAccessibleToilet,
    required this.hasElevator,
    required this.hasRamp,
    required this.hearingSupport,
    required this.visualSupport,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String category;
  final String description;
  final double rating;
  final bool wheelchairAccessible;
  final bool hasAccessibleToilet;
  final bool hasElevator;
  final bool hasRamp;
  final bool hearingSupport;
  final bool visualSupport;
  final double latitude;
  final double longitude;
}

Future<PlaceFormResult?> showPlaceFormDialog({
  required BuildContext context,
  required double latitude,
  required double longitude,
  AccessiblePlace? existing,
}) {
  return showDialog<PlaceFormResult>(
    context: context,
    builder: (ctx) => _PlaceFormDialog(
      latitude: latitude,
      longitude: longitude,
      existing: existing,
    ),
  );
}

class _PlaceFormDialog extends StatefulWidget {
  const _PlaceFormDialog({
    required this.latitude,
    required this.longitude,
    this.existing,
  });

  final double latitude;
  final double longitude;
  final AccessiblePlace? existing;

  @override
  State<_PlaceFormDialog> createState() => _PlaceFormDialogState();
}

class _PlaceFormDialogState extends State<_PlaceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _category;
  late double _rating;
  late bool _wheelchair;
  late bool _restroom;
  late bool _elevator;
  late bool _ramp;
  late bool _hearing;
  late bool _visual;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? PlaceCategories.cafe;
    _rating = e?.rating ?? 3;
    if (_rating < 1) _rating = 3;
    _wheelchair = e?.wheelchairAccessible ?? false;
    _restroom = e?.hasAccessibleToilet ?? false;
    _elevator = e?.hasElevator ?? false;
    _ramp = e?.hasRamp ?? false;
    _hearing = e?.hearingSupport ?? false;
    _visual = e?.visualSupport ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      PlaceFormResult(
        name: _nameCtrl.text.trim(),
        category: _category,
        description: _descCtrl.text.trim(),
        rating: _rating,
        wheelchairAccessible: _wheelchair,
        hasAccessibleToilet: _restroom,
        hasElevator: _elevator,
        hasRamp: _ramp,
        hearingSupport: _hearing,
        visualSupport: _visual,
        latitude: widget.existing?.latitude ?? widget.latitude,
        longitude: widget.existing?.longitude ?? widget.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(
        isEdit ? 'Mekanı Düzenle' : 'Erişilebilir Mekan Ekle',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mekan adı *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ad gerekli' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: PlaceCategories.all
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                Text(
                  'Puan: ${_rating.toStringAsFixed(0)} / 5',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _rating.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _rating = v),
                ),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Erişilebilirlik özellikleri',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                _accessSwitch('Tekerlekli sandalye erişimi', _wheelchair,
                    (v) => setState(() => _wheelchair = v)),
                _accessSwitch('Erişilebilir tuvalet', _restroom,
                    (v) => setState(() => _restroom = v)),
                _accessSwitch('Asansör', _elevator,
                    (v) => setState(() => _elevator = v)),
                _accessSwitch('Rampa', _ramp, (v) => setState(() => _ramp = v)),
                _accessSwitch('İşitme desteği', _hearing,
                    (v) => setState(() => _hearing = v)),
                _accessSwitch('Görsel destek', _visual,
                    (v) => setState(() => _visual = v)),
                const SizedBox(height: 4),
                Text(
                  'Konum: ${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: YanYanaColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Kaydet' : 'Ekle'),
        ),
      ],
    );
  }

  Widget _accessSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}
