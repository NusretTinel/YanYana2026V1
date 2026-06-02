import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community_rooms/data/mock_community_rooms_data.dart';

enum CommunityRoomFormMode { create, liveEdit, mockEdit }

enum CommunityRoomCreationType { mock, live }

class CommunityRoomFormData {
  final String name;
  final String description;
  final String category;
  final List<String> accessibilityTags;
  final CommunityRoomCreationType? creationType;

  const CommunityRoomFormData({
    required this.name,
    required this.description,
    required this.category,
    required this.accessibilityTags,
    this.creationType,
  });
}

/// Create / edit bottom sheet for live and mock community rooms.
class CommunityRoomFormSheet extends StatefulWidget {
  final CommunityRoomFormMode mode;
  final CommunityRoomCreationType initialCreationType;
  final String? initialName;
  final String? initialDescription;
  final String? initialCategory;
  final List<String>? initialTags;
  final Future<void> Function(CommunityRoomFormData data)? onSave;

  const CommunityRoomFormSheet({
    super.key,
    required this.mode,
    this.initialCreationType = CommunityRoomCreationType.mock,
    this.initialName,
    this.initialDescription,
    this.initialCategory,
    this.initialTags,
    this.onSave,
  });

  static const accessibilityOptions = [
    'Metin Sohbet',
    'Ses Desteği',
    'Altyazı',
    'Güvenli Alan',
  ];

  static Future<CommunityRoomFormData?> show(
    BuildContext context, {
    required CommunityRoomFormMode mode,
    CommunityRoomCreationType initialCreationType =
        CommunityRoomCreationType.mock,
    String? initialName,
    String? initialDescription,
    String? initialCategory,
    List<String>? initialTags,
    Future<void> Function(CommunityRoomFormData data)? onSave,
  }) {
    return showModalBottomSheet<CommunityRoomFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: CommunityRoomFormSheet(
          mode: mode,
          initialCreationType: initialCreationType,
          initialName: initialName,
          initialDescription: initialDescription,
          initialCategory: initialCategory,
          initialTags: initialTags,
          onSave: onSave,
        ),
      ),
    );
  }

  bool get isCreating => mode == CommunityRoomFormMode.create;

  bool get isEditing =>
      mode == CommunityRoomFormMode.liveEdit ||
      mode == CommunityRoomFormMode.mockEdit;

  String get _title {
    if (isEditing) return 'Odayı Düzenle';
    return 'Yeni Oda Oluştur';
  }

  String _subtitleFor(CommunityRoomCreationType type) {
    if (isEditing) {
      return mode == CommunityRoomFormMode.liveEdit
          ? 'Değişiklikler Firestore\'a kaydedilir.'
          : 'Değişiklikler yalnızca bu cihazda saklanır.';
    }
    return type == CommunityRoomCreationType.live
        ? 'Oda Firestore\'a kaydedilir ve Odalar (Canlı) bölümünde görünür.'
        : 'Oda yalnızca bu cihazda saklanır; Odalar (Örnek) bölümünde görünür.';
  }

  @override
  State<CommunityRoomFormSheet> createState() =>
      _CommunityRoomFormSheetState();
}

class _CommunityRoomFormSheetState extends State<CommunityRoomFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _category;
  late Set<String> _selectedTags;
  late CommunityRoomCreationType _creationType;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _creationType = widget.initialCreationType;
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
    _category = widget.initialCategory ?? 'Destek';
    _selectedTags = Set<String>.from(
      widget.initialTags?.isNotEmpty == true
          ? widget.initialTags!
          : const ['Metin Sohbet'],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final description = _descCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oda adı zorunludur.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oda açıklaması zorunludur.')),
      );
      return;
    }

    final data = CommunityRoomFormData(
      name: name,
      description: description,
      category: _category,
      accessibilityTags: _selectedTags.toList(),
      creationType: widget.isCreating ? _creationType : null,
    );

    if (widget.onSave != null) {
      setState(() => _submitting = true);
      try {
        await widget.onSave!(data);
        if (!mounted) return;
        Navigator.pop(context, data);
      } catch (e) {
        if (mounted) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
      return;
    }

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: YanYanaShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: YanYanaColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget._title,
              style: const TextStyle(
                color: YanYanaColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget._subtitleFor(_creationType),
              style: const TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (widget.isCreating) ...[
              const SizedBox(height: 16),
              Semantics(
                label: 'Oda türü seçimi',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Oda türü',
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 420;
                        final children = [
                          _RoomTypeOption(
                            label: 'Örnek Oda (Yerel)',
                            subtitle: 'Bu cihazda saklanır',
                            icon: Icons.chat_rounded,
                            selected: _creationType == CommunityRoomCreationType.mock,
                            accent: YanYanaColors.primary,
                            enabled: !_submitting,
                            onTap: () => setState(
                              () => _creationType = CommunityRoomCreationType.mock,
                            ),
                          ),
                          _RoomTypeOption(
                            label: 'Canlı Oda (Firestore)',
                            subtitle: 'Gerçek zamanlı paylaşım',
                            icon: Icons.cloud_rounded,
                            selected: _creationType == CommunityRoomCreationType.live,
                            accent: YanYanaColors.secondary,
                            enabled: !_submitting,
                            onTap: () => setState(
                              () => _creationType = CommunityRoomCreationType.live,
                            ),
                          ),
                        ];
                        if (stacked) {
                          return Column(
                            children: [
                              children[0],
                              const SizedBox(height: 10),
                              children[1],
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: children[0]),
                            const SizedBox(width: 10),
                            Expanded(child: children[1]),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              enabled: !_submitting,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration('Oda adı', 'Örn: Destek Sohbeti'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _fieldDecoration('Kategori', null),
              items: MockCommunityRoomsData.categories
                  .where((c) => c != 'Tümü')
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (v) => setState(() => _category = v ?? 'Destek'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              enabled: !_submitting,
              minLines: 2,
              maxLines: 4,
              decoration: _fieldDecoration(
                'Açıklama',
                'Bu odanın amacı nedir?',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erişilebilirlik etiketleri',
              style: TextStyle(
                color: YanYanaColors.textDark,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CommunityRoomFormSheet.accessibilityOptions.map((tag) {
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: _submitting
                      ? null
                      : (v) {
                          setState(() {
                            if (v) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                  selectedColor: YanYanaColors.primaryLight,
                  checkmarkColor: YanYanaColors.primaryDark,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? YanYanaColors.primaryDark
                        : YanYanaColors.textMuted,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.isCreating &&
                          _creationType == CommunityRoomCreationType.live
                      ? YanYanaColors.secondary
                      : YanYanaColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(widget.isEditing ? Icons.save_rounded : Icons.check_rounded),
                label: Text(
                  _submitting
                      ? 'Kaydediliyor…'
                      : widget.isEditing
                          ? 'Kaydet'
                          : 'Oluştur',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static InputDecoration _fieldDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: YanYanaColors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: YanYanaColors.primary, width: 2),
      ),
    );
  }
}

class _RoomTypeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  const _RoomTypeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.12)
                  : YanYanaColors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? accent : YanYanaColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? accent : YanYanaColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? YanYanaColors.textDark
                              : YanYanaColors.textMuted,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: YanYanaColors.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: accent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
