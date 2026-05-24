import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/accessibility_review.dart';
import 'package:yanyana_p/shared/models/accessible_place.dart';

typedef PlaceDetailsAction = Future<void> Function();

Future<void> showPlaceDetailsSheet({
  required BuildContext context,
  required AccessiblePlace place,
  required List<AccessibilityReview> reviews,
  required VoidCallback onEdit,
  required Future<void> Function() onDelete,
  required Future<void> Function(String comment, double rating) onAddReview,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: YanYanaColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _PlaceDetailsSheet(
      place: place,
      reviews: reviews,
      onEdit: onEdit,
      onDelete: onDelete,
      onAddReview: onAddReview,
    ),
  );
}

class _PlaceDetailsSheet extends StatefulWidget {
  const _PlaceDetailsSheet({
    required this.place,
    required this.reviews,
    required this.onEdit,
    required this.onDelete,
    required this.onAddReview,
  });

  final AccessiblePlace place;
  final List<AccessibilityReview> reviews;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function(String comment, double rating) onAddReview;

  @override
  State<_PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<_PlaceDetailsSheet> {
  final _reviewCtrl = TextEditingController();
  double _reviewRating = 4;
  bool _savingReview = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Mekanı sil'),
        content: Text(
          '"${widget.place.name}" silinsin mi? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: YanYanaColors.sos),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.onDelete();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _submitReview() async {
    if (_reviewCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kısa bir yorum yazın.')),
      );
      return;
    }
    setState(() => _savingReview = true);
    try {
      await widget.onAddReview(_reviewCtrl.text.trim(), _reviewRating);
      _reviewCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumunuz kaydedildi.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _savingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final features = p.accessibilityLabels;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: YanYanaColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              p.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: YanYanaColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 18, color: YanYanaColors.textMuted),
                const SizedBox(width: 6),
                Text(p.category, style: const TextStyle(fontSize: 15)),
                const Spacer(),
                const Icon(Icons.star_rounded,
                    color: YanYanaColors.warning, size: 20),
                Text(
                  p.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            if (p.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                p.description,
                style: const TextStyle(
                  color: YanYanaColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (features.isEmpty)
              const Text(
                'Erişilebilirlik özelliği işaretlenmemiş.',
                style: TextStyle(color: YanYanaColors.textMuted),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features
                    .map(
                      (f) => Chip(
                        label: Text(f),
                        backgroundColor: YanYanaColors.primaryLight,
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'Yorumlar',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (widget.reviews.isEmpty)
              const Text(
                'Henüz yorum yok. İlk yorumu siz ekleyebilirsiniz.',
                style: TextStyle(color: YanYanaColors.textMuted),
              )
            else
              ...widget.reviews.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: YanYanaColors.warning,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(r.comment),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Kısa yorum ekle',
                border: OutlineInputBorder(),
              ),
            ),
            Slider(
              value: _reviewRating,
              min: 1,
              max: 5,
              divisions: 4,
              label: _reviewRating.toStringAsFixed(0),
              onChanged: (v) => setState(() => _reviewRating = v),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savingReview ? null : _submitReview,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Yorumu Kaydet'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onEdit();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Düzenle'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: YanYanaColors.sos,
                    ),
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Sil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
