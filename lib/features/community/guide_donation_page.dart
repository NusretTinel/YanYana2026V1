import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/donation/screens/donation_home_screen.dart';
import 'package:yanyana_p/features/guide/screens/guide_home_screen.dart';

class GuideDonationPage extends StatelessWidget {
  const GuideDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rehber ve Bağış',
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: YanYanaColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: YanYanaColors.border),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          gradient: supportGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: YanYanaShadows.soft,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: YanYanaColors.textMuted,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Rehber'),
                          Tab(text: 'Bağış'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TabBarView(
                  children: [
                    GuideHomeScreen(),
                    DonationHomeScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
