import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../shared/widgets/glass_widgets.dart';
import '../../shared/widgets/premium_background.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/dua_audio.dart';
import '../community/models/challenge.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = getIt<AdminService>();
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PremiumBackgroundWithParticles(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            leading: const BackButton(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () async {
                  try {
                    await _adminService.seedInitialData();
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Initial data seeded successfully! 🚀')));
                  } catch (e) {
                    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Seed failed: $e', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: ImanFlowTheme.error,
                    ));
                  }
                },
                icon: const Icon(Icons.auto_awesome, color: ImanFlowTheme.gold),
                tooltip: 'Seed Initial Data',
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Glass(
                  radius: 99,
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildTabItem(0, 'Verse', Icons.menu_book),
                      _buildTabItem(1, 'Audio', Icons.audiotrack),
                      _buildTabItem(2, 'Challenge', Icons.emoji_events),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: isSelected ? ImanFlowTheme.gold : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white60),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? Colors.black : Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0: return _buildVerseManager();
      case 1: return _buildAudioManager();
      case 2: return _buildChallengeManager();
      default: return const Center(child: Text('Select a tab'));
    }
  }

  // --- Verse Manager ---
  final _verseFormKey = GlobalKey<FormState>();
  final _verseKeyController = TextEditingController();
  final _arabicController = TextEditingController();
  final _translationController = TextEditingController();
  DateTime _targetDate = DateTime.now();

  Widget _buildVerseManager() {
    return SingleChildScrollView(
      child: Glass(
        radius: 20,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _verseFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Daily Verse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Target Date', style: TextStyle(color: Colors.white70)),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_targetDate), style: const TextStyle(color: ImanFlowTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.calendar_today, color: ImanFlowTheme.gold),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setState(() => _targetDate = picked);
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_verseKeyController, 'Verse Key (e.g. 2:255)', 'Verse Key'),
              const SizedBox(height: 16),
              _buildTextField(_arabicController, 'Arabic Text', 'Arabic Text', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_translationController, 'Translation', 'Translation', maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveDailyVerse,
                  style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                  child: const Text('Save Daily Content'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _saveDailyVerse() async {
    if (!_verseFormKey.currentState!.validate()) return;
    
    try {
      await _adminService.setDailyVerse(
        dateId: DateFormat('yyyy-MM-dd').format(_targetDate),
        verseKey: _verseKeyController.text.trim(),
        textArabic: _arabicController.text.trim(),
        translation: _translationController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Daily verse saved successfully!')));
        _verseKeyController.clear();
        _arabicController.clear();
        _translationController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: ImanFlowTheme.error,
      ));
    }
  }

  // --- Audio Manager ---
  final _audioFormKey = GlobalKey<FormState>();
  final _audioNameController = TextEditingController();
  final _audioArabicController = TextEditingController();
  final _audioUrlController = TextEditingController();
  final _audioDurationController = TextEditingController();
  String _audioCategory = 'morning';
  bool _isPremiumAudio = false;

  Widget _buildAudioManager() {
    return SingleChildScrollView(
      child: Glass(
        radius: 20,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _audioFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add New Audio Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildTextField(_audioNameController, 'Name (English)', 'e.g. Morning Adhkar'),
              const SizedBox(height: 16),
              _buildTextField(_audioArabicController, 'Name (Arabic)', 'e.g. أذكار الصباح'),
              const SizedBox(height: 16),
              _buildTextField(_audioUrlController, 'Audio URL', 'https://...'),
              const SizedBox(height: 16),
              _buildTextField(_audioDurationController, 'Duration (Seconds)', 'e.g. 300', isNumeric: true),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _audioCategory,
                dropdownColor: ImanFlowTheme.bgMid,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white60),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                ),
                items: ['morning', 'evening', 'sleep', 'general'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _audioCategory = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Premium Only', style: TextStyle(color: Colors.white)),
                value: _isPremiumAudio,
                activeColor: ImanFlowTheme.gold,
                onChanged: (v) => setState(() => _isPremiumAudio = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAudioContent,
                  style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                  child: const Text('Add Audio Content'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAudioContent() async {
    if (!_audioFormKey.currentState!.validate()) return;
    
    try {
      await _adminService.addAudioContent(DuaAudio(
        id: '', // Firestore will generate
        name: _audioNameController.text.trim(),
        nameArabic: _audioArabicController.text.trim(),
        category: _audioCategory,
        audioUrl: _audioUrlController.text.trim(),
        duration: Duration(seconds: int.parse(_audioDurationController.text.trim())),
        isPremium: _isPremiumAudio,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio content added!')));
        _audioNameController.clear();
        _audioArabicController.clear();
        _audioUrlController.clear();
        _audioDurationController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: ImanFlowTheme.error,
      ));
    }
  }

  // --- Challenge Manager ---
  final _challengeFormKey = GlobalKey<FormState>();
  final _challengeTitleController = TextEditingController();
  final _challengeDescController = TextEditingController();
  final _challengeIconController = TextEditingController(text: '🌙');
  final _challengeDaysController = TextEditingController(text: '30');
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isWomenOnly = false;

  Widget _buildChallengeManager() {
    return SingleChildScrollView(
      child: Glass(
        radius: 20,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _challengeFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create New Challenge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildTextField(_challengeTitleController, 'Title', 'e.g. 30-Day Quran Challenge'),
              const SizedBox(height: 16),
              _buildTextField(_challengeDescController, 'Description', 'What to do...', maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField(_challengeIconController, 'Icon Emoji', '🌙'),
              const SizedBox(height: 16),
              _buildTextField(_challengeDaysController, 'Total Days', '30', isNumeric: true),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Date', style: TextStyle(fontSize: 12, color: Colors.white60)),
                      subtitle: Text(DateFormat('MM/dd').format(_startDate), style: const TextStyle(color: ImanFlowTheme.gold)),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 90)));
                        if (picked != null) setState(() => _startDate = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Date', style: TextStyle(fontSize: 12, color: Colors.white60)),
                      subtitle: Text(DateFormat('MM/dd').format(_endDate), style: const TextStyle(color: ImanFlowTheme.gold)),
                      onTap: () async {
                        final picked = await showDatePicker(context: context, initialDate: _endDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 180)));
                        if (picked != null) setState(() => _endDate = picked);
                      },
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Women Only', style: TextStyle(color: Colors.white)),
                value: _isWomenOnly,
                activeColor: ImanFlowTheme.gold,
                onChanged: (v) => setState(() => _isWomenOnly = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChallenge,
                  style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
                  child: const Text('Create Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveChallenge() async {
    if (!_challengeFormKey.currentState!.validate()) return;
    
    try {
      await _adminService.addChallenge(Challenge(
        id: '',
        title: _challengeTitleController.text.trim(),
        description: _challengeDescController.text.trim(),
        icon: _challengeIconController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        totalDays: int.parse(_challengeDaysController.text.trim()),
        participantCount: 0,
        isWomenOnly: _isWomenOnly,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Challenge created!')));
        _challengeTitleController.clear();
        _challengeDescController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: ImanFlowTheme.error,
      ));
    }
  }

  // Helper for text fields
  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ImanFlowTheme.gold), borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (isNumeric && int.tryParse(v) == null) return 'Must be a number';
        return null;
      },
    );
  }
}
