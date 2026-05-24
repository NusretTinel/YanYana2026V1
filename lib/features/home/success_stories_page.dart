import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/success_story.dart';

class SuccessStoriesPage extends StatefulWidget {
  const SuccessStoriesPage({super.key, this.openShareOnStart = false});

  final bool openShareOnStart;

  @override
  State<SuccessStoriesPage> createState() => _SuccessStoriesPageState();
}

class _SuccessStoriesPageState extends State<SuccessStoriesPage> {
  final _backend = BackendOrchestrator.instance;

  @override
  void initState() {
    super.initState();
    if (widget.openShareOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showShareForm());
    }
  }

  Future<void> _showShareForm() async {
    final data = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: const _ShareStorySheet(),
      ),
    );

    if (data == null || !mounted) return;

    try {
      await _backend.addSuccessStory(
        title: data['title']!,
        content: data['content']!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hikayen başarıyla paylaşıldı.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hikaye paylaşılamadı: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Başarı Hikayeleri',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showShareForm,
        backgroundColor: YanYanaColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'Hikaye Paylaş',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<SuccessStory>>(
          stream: _backend.streamSuccessStories(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Hikayeler yüklenemedi: ${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final stories = snap.data ?? const [];
            if (stories.isEmpty) {
              return _EmptyStories(onShare: _showShareForm);
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _StoryTile(story: stories[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ShareStorySheet extends StatefulWidget {
  const _ShareStorySheet();

  @override
  State<_ShareStorySheet> createState() => _ShareStorySheetState();
}

class _ShareStorySheetState extends State<_ShareStorySheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık ve hikaye alanları zorunludur.')),
      );
      return;
    }
    Navigator.pop(context, {'title': title, 'content': body});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: YanYanaShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Hikaye Paylaş',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: YanYanaColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Başlık'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Hikayen'),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Paylaş',
            icon: Icons.send_rounded,
            gradient: supportGradient,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _EmptyStories extends StatelessWidget {
  final VoidCallback onShare;

  const _EmptyStories({required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 56,
              color: YanYanaColors.textLight.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz başarı hikayesi paylaşılmadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: YanYanaColors.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'YanYana deneyimini paylaşarak başka kullanıcılara ilham verebilirsin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Hikaye Paylaş'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryTile extends StatelessWidget {
  final SuccessStory story;

  const _StoryTile({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: YanYanaColors.primaryLight),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.title,
            style: const TextStyle(
              color: YanYanaColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            story.authorName,
            style: const TextStyle(
              color: YanYanaColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            story.content,
            style: const TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
