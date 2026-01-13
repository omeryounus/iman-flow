import 'package:flutter/material.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/quran_service.dart';

/// Surah List Widget - Displays all 114 Surahs
class SurahList extends StatelessWidget {
  final List<Surah> surahs;
  final Function(Surah) onSurahTap;

  const SurahList({
    super.key,
    required this.surahs,
    required this.onSurahTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text('${surah.id}'),
          ),
          title: Text(surah.nameSimple),
          subtitle: Text(surah.nameTranslated),
          trailing: Text(
            surah.nameArabic,
            style: const TextStyle(fontFamily: 'Amiri', fontSize: 18),
          ),
          onTap: () => onSurahTap(surah),
        );
      },
    );
  }
}
