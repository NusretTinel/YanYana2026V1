import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/widgets/community_board_section.dart';

/// Full-screen community board with mock feed (no Firebase).
class CommunityBoardPage extends StatelessWidget {
  const CommunityBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        leading: Semantics(
          label: 'Geri dön',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: YanYanaColors.textDark,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Geri',
          ),
        ),
        title: Semantics(
          header: true,
          child: const Text(
            'Topluluk Panosu',
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: CommunityBoardSection(),
        ),
      ),
    );
  }
}
