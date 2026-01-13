import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/prayer_service.dart';
import 'widgets/prayer_times_card.dart';
import 'widgets/qibla_compass.dart';
import 'widgets/dua_section.dart';

/// Prayer Screen - Main prayer tab with times, Qibla, and Duas
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PrayerService _prayerService = getIt<PrayerService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Prayer'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              ImanFlowTheme.primaryGreenDark,
                              ImanFlowTheme.primaryGreen,
                            ]
                          : [
                              ImanFlowTheme.primaryGreen,
                              ImanFlowTheme.primaryGreenLight,
                            ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.mosque,
                          size: 48,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Establish Prayer',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.access_time), text: 'Times'),
                  Tab(icon: Icon(Icons.explore), text: 'Qibla'),
                  Tab(icon: Icon(Icons.headphones), text: 'Duas'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            PrayerTimesCard(),
            QiblaCompass(),
            DuaSection(),
          ],
        ),
      ),
    );
  }
}
