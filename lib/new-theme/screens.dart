import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class EnterAnim extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const EnterAnim({super.key, required this.child, this.delayMs = 0});
  @override
  State<EnterAnim> createState() => _EnterAnimState();
}

class _EnterAnimState extends State<EnterAnim> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<double>(begin: 12, end: 0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: widget.child,
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  const TopBar({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Glass(
          radius: 18,
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.nights_stay_rounded, color: AppTheme.gold, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
            ],
          ),
        ),
        Glass(
          radius: 18,
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.settings_rounded, color: Colors.white.withOpacity(.85), size: 22),
        ),
      ],
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final bool gold;
  const Pill({super.key, required this.text, this.gold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: gold ? AppTheme.gold.withOpacity(.14) : Colors.black.withOpacity(.18),
        border: Border.all(
          color: gold ? AppTheme.gold.withOpacity(.22) : Colors.white.withOpacity(.12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: gold ? AppTheme.gold : Colors.white.withOpacity(.85),
        ),
      ),
    );
  }
}

class AyahCard extends StatelessWidget {
  final String arabic;
  final String translation;
  const AyahCard({super.key, required this.arabic, required this.translation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black.withOpacity(.14),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        children: [
          Text(
            arabic,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 24,
              height: 1.8,
              color: Colors.white.withOpacity(.94),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(.78), height: 1.4, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBar(title: "Quran AI", subtitle: "Prayer • Dhikr • Tafsir • Duas"),
          const SizedBox(height: 14),
          EnterAnim(
            delayMs: 0,
            child: Glass(
              radius: 28,
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.gold.withOpacity(.10), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Pill(text: "Maghrib in 12 min"),
                        Spacer(),
                        Pill(text: "🔥 7 days", gold: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text("Today’s Reminder",
                        style: TextStyle(fontSize: isTablet ? 22 : 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(
                      "Small consistent deeds build the heart. Keep your dhikr steady and your intention sincere.",
                      style: TextStyle(color: Colors.white.withOpacity(.75), height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const AyahCard(
                      arabic: "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ",
                      translation: "Surely in the remembrance of Allah do hearts find rest.",
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 720;
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: PrayerPreview()),
                        SizedBox(width: 14),
                        Expanded(child: QuickActions()),
                      ],
                    )
                  : const Column(
                      children: [
                        PrayerPreview(),
                        SizedBox(height: 14),
                        QuickActions(),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class PrayerPreview extends StatelessWidget {
  const PrayerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return EnterAnim(
      delayMs: 80,
      child: Glass(
        radius: 26,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Prayer Times", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            SizedBox(height: 10),
            _PrayerRow(name: "Fajr", time: "05:45 AM", next: "Next in 02:30"),
            SizedBox(height: 8),
            _PrayerRow(name: "Dhuhr", time: "12:30 PM", next: "Next in 06:25"),
            SizedBox(height: 8),
            _PrayerRow(name: "Asr", time: "03:15 PM", next: "Next in 09:10"),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name, time, next;
  const _PrayerRow({required this.name, required this.time, required this.next});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(.12),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(next, style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
            ]),
          ),
          Text(time, style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tile(IconData icon, String title, String sub, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(.12),
            border: Border.all(color: Colors.white.withOpacity(.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: [
                    AppTheme.gold.withOpacity(.28),
                    Colors.black.withOpacity(.05),
                  ]),
                  border: Border.all(color: AppTheme.gold.withOpacity(.22)),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(sub, style: TextStyle(color: Colors.white.withOpacity(.65), fontSize: 12)),
                ]),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(.55)),
            ],
          ),
        ),
      );
    }

    return EnterAnim(
      delayMs: 140,
      child: Glass(
        radius: 26,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          tile(Icons.auto_awesome_rounded, "Quran AI", "Ask tafsir & meaning", () => context.go('/quran')),
          tile(Icons.graphic_eq_rounded, "Dhikr Player", "Morning / Evening", () => context.go('/dhikr')),
          tile(Icons.access_time_rounded, "Prayer Times", "Accurate timings", () => context.go('/prayer')),
          tile(Icons.grid_view_rounded, "More", "Qibla • Duas • Tasbeeh", () => context.go('/more')),
        ]),
      ),
    );
  }
}

class QuranAiScreen extends StatefulWidget {
  const QuranAiScreen({super.key});
  @override
  State<QuranAiScreen> createState() => _QuranAiScreenState();
}

class _QuranAiScreenState extends State<QuranAiScreen> {
  final _ctrl = TextEditingController();
  final _messages = <_Msg>[
    _Msg(true, "Explain Surah Al-Fatiha in simple terms."),
    _Msg(false, "Al-Fatiha is a complete dua for guidance: praise, mercy, accountability, then a request for the straight path."),
  ];
  bool _typing = false;

  void _send() async {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(true, t));
      _typing = true;
      _ctrl.clear();
    });

    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _messages.add(_Msg(false, "I can explain meanings, context, and practical lessons. (Demo reply)"));
      _typing = false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        children: [
          const TopBar(title: "Quran AI", subtitle: "Ask about Surahs, meanings & lessons"),
          const SizedBox(height: 14),
          Expanded(
            child: Glass(
              radius: 28,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(children: const [
                    Pill(text: "Explain Surah", gold: true),
                    SizedBox(width: 10),
                    Pill(text: "Give lesson"),
                  ]),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length + (_typing ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_typing && i == _messages.length) return const _TypingBubble();
                        final m = _messages[i];
                        return _ChatBubble(me: m.me, text: m.text);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.black.withOpacity(.16),
                      border: Border.all(color: Colors.white.withOpacity(.10)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            onSubmitted: (_) => _send(),
                            decoration: InputDecoration(
                              hintText: "Ask anything about the Quran…",
                              hintStyle: TextStyle(color: Colors.white.withOpacity(.55)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _send,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.gold.withOpacity(.14),
                              border: Border.all(color: AppTheme.gold.withOpacity(.20)),
                            ),
                            child: Icon(Icons.send_rounded, color: AppTheme.gold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final bool me;
  final String text;
  _Msg(this.me, this.text);
}

class _ChatBubble extends StatelessWidget {
  final bool me;
  final String text;
  const _ChatBubble({required this.me, required this.text});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: me ? AppTheme.gold.withOpacity(.12) : Colors.black.withOpacity(.14),
          border: Border.all(color: me ? AppTheme.gold.withOpacity(.18) : Colors.white.withOpacity(.10)),
        ),
        child: Text(text, style: TextStyle(color: Colors.white.withOpacity(.84), height: 1.35)),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.black.withOpacity(.14),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value * 2 * pi;
            double o(int i) => 0.35 + 0.55 * (0.5 + 0.5 * sin(t + i * 0.9));
            return Row(mainAxisSize: MainAxisSize.min, children: [
              _dot(o(0)), const SizedBox(width: 6),
              _dot(o(1)), const SizedBox(width: 6),
              _dot(o(2)),
            ]);
          },
        ),
      ),
    );
  }

  Widget _dot(double opacity) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: Colors.white.withOpacity(opacity), shape: BoxShape.circle),
      );
}

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TopBar(title: "Prayer Times", subtitle: "Your City • Hijri Date"),
          SizedBox(height: 14),
          // Demo list
        ],
      ),
    );
  }
}

class DhikrScreen extends StatelessWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        children: [
          const TopBar(title: "Dhikr", subtitle: "Morning • Evening • Calm Mode"),
          const SizedBox(height: 14),
          EnterAnim(
            delayMs: 70,
            child: Glass(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [Pill(text: "Morning Dhikr", gold: true), Spacer(), Icon(Icons.notifications_active_rounded)]),
                  const SizedBox(height: 14),
                  const Text("Morning Dhikr for Peace", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text("Start your day with calm remembrance and gratitude.", style: TextStyle(color: Colors.white.withOpacity(.72))),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => context.push('/dhikr/player'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppTheme.gold.withOpacity(.12),
                        border: Border.all(color: AppTheme.gold.withOpacity(.20)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: AppTheme.gold),
                          const SizedBox(width: 10),
                          const Expanded(child: Text("Open Player", style: TextStyle(fontWeight: FontWeight.w900))),
                          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(.65)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DhikrPlayerScreen extends StatefulWidget {
  const DhikrPlayerScreen({super.key});
  @override
  State<DhikrPlayerScreen> createState() => _DhikrPlayerScreenState();
}

class _DhikrPlayerScreenState extends State<DhikrPlayerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool playing = true;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text("Dhikr Player")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Glass(
            radius: 28,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Morning Dhikr for Peace", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Text("Calm Mode • 10:00", style: TextStyle(color: Colors.white.withOpacity(.70))),
                const SizedBox(height: 22),
                Center(
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) {
                      final pulse = 0.85 + 0.18 * (0.5 + 0.5 * sin(_c.value * 2 * pi));
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 170 * pulse,
                            height: 170 * pulse,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.gold.withOpacity(.20),
                                  blurRadius: 60,
                                  spreadRadius: 8,
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => playing = !playing),
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                gradient: LinearGradient(
                                  colors: [AppTheme.gold.withOpacity(.30), Colors.black.withOpacity(.05)],
                                ),
                                border: Border.all(color: AppTheme.gold.withOpacity(.28)),
                              ),
                              child: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 48,
                                color: Colors.white.withOpacity(.95),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const AyahCard(
                  arabic: "أَلَا بِذِكْرِ ٱللَّهِ تَطْمَئِنُّ ٱلْقُلُوبُ",
                  translation: "Surely in the remembrance of Allah do hearts find rest.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _MoreItem(icon: Icons.explore_rounded, title: "AR Qibla"),
      _MoreItem(icon: Icons.fingerprint_rounded, title: "Tasbeeh Counter"),
      _MoreItem(icon: Icons.menu_book_rounded, title: "Daily Duas"),
      _MoreItem(icon: Icons.download_rounded, title: "Offline Downloads"),
      _MoreItem(icon: Icons.favorite_rounded, title: "Favorites"),
      _MoreItem(icon: Icons.settings_rounded, title: "Settings"),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TopBar(title: "More", subtitle: "Tools • Duas • Qibla • Settings"),
          const SizedBox(height: 14),
          EnterAnim(
            delayMs: 80,
            child: Glass(
              radius: 28,
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (_, i) => items[i],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _MoreItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.black.withOpacity(.12),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.gold.withOpacity(.14),
              border: Border.all(color: AppTheme.gold.withOpacity(.20)),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 26),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
