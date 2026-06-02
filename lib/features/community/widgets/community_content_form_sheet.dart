import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/models/community_feed_content_type.dart';

/// Create / edit bottom sheet for community feed content.
class CommunityContentFormSheet extends StatefulWidget {
  final bool isEditing;
  final CommunityFeedContentType? initialType;
  final String? initialTitle;
  final String? initialContent;
  final bool lockType;

  const CommunityContentFormSheet({
    super.key,
    this.isEditing = false,
    this.initialType,
    this.initialTitle,
    this.initialContent,
    this.lockType = false,
  });

  static Future<CommunityContentFormData?> show(
    BuildContext context, {
    bool isEditing = false,
    CommunityFeedContentType? initialType,
    String? initialTitle,
    String? initialContent,
    bool lockType = false,
  }) {
    return showModalBottomSheet<CommunityContentFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: CommunityContentFormSheet(
          isEditing: isEditing,
          initialType: initialType,
          initialTitle: initialTitle,
          initialContent: initialContent,
          lockType: lockType,
        ),
      ),
    );
  }

  @override
  State<CommunityContentFormSheet> createState() =>
      _CommunityContentFormSheetState();
}

class _CommunityContentFormSheetState extends State<CommunityContentFormSheet> {
  late CommunityFeedContentType _type;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? CommunityFeedContentType.communityPost;
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _contentCtrl = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String get _titleLabel {
    switch (_type) {
      case CommunityFeedContentType.dailyQuote:
        return 'Başlık (isteğe bağlı)';
      case CommunityFeedContentType.communityPost:
        return 'Başlık';
      case CommunityFeedContentType.successStory:
        return 'Hikaye başlığı';
    }
  }

  String get _contentLabel {
    switch (_type) {
      case CommunityFeedContentType.dailyQuote:
        return 'Günün sözü';
      case CommunityFeedContentType.communityPost:
        return 'İçerik';
      case CommunityFeedContentType.successStory:
        return 'Hikaye';
    }
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (_type != CommunityFeedContentType.dailyQuote && title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık zorunludur.')),
      );
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İçerik zorunludur.')),
      );
      return;
    }

    Navigator.pop(
      context,
      CommunityContentFormData(
        type: _type,
        title: title,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final types = widget.lockType
        ? [_type]
        : CommunityFeedContentType.values;

    return Container(
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: YanYanaShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEditing ? 'Paylaşımı Düzenle' : 'Yeni Paylaşım',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: YanYanaColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (!widget.lockType) ...[
              DropdownButtonFormField<CommunityFeedContentType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tür'),
                items: types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.label),
                      ),
                    )
                    .toList(),
                onChanged: widget.isEditing
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _type = value);
                      },
              ),
              const SizedBox(height: 12),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _type.label,
                  style: const TextStyle(
                    color: YanYanaColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: _titleLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(labelText: _contentLabel),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: Icon(widget.isEditing ? Icons.save_rounded : Icons.send_rounded),
              label: Text(widget.isEditing ? 'Kaydet' : 'Paylaş'),
              style: FilledButton.styleFrom(
                backgroundColor: YanYanaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
