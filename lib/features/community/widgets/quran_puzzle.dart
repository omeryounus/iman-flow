import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

/// Quran Puzzle Widget - Gamified verse learning
class QuranPuzzle extends StatefulWidget {
  final bool womenMode;

  const QuranPuzzle({super.key, this.womenMode = false});

  @override
  State<QuranPuzzle> createState() => _QuranPuzzleState();
}

class _QuranPuzzleState extends State<QuranPuzzle> {
  int _currentQuestion = 0;
  int _score = 0;
  bool _showResult = false;
  bool _answered = false;
  int? _selectedAnswer;

  List<QuizQuestion> get _questions => widget.womenMode
      ? _womenQuestions
      : _generalQuestions;

  // Questions remain same
  final List<QuizQuestion> _generalQuestions = [
    QuizQuestion(question: 'Which Surah is known as the "Heart of the Quran"?', options: ['Al-Fatiha', 'Ya-Sin', 'Al-Baqarah', 'Al-Ikhlas'], correctIndex: 1, explanation: 'Surah Ya-Sin is called the Heart of the Quran due to its emphasis on core Islamic teachings.'),
    QuizQuestion(question: 'How many verses are in Surah Al-Fatiha?', options: ['5', '6', '7', '8'], correctIndex: 2, explanation: 'Al-Fatiha has 7 verses and is recited in every unit of prayer.'),
    QuizQuestion(question: 'Which verse is called "Ayatul Kursi"?', options: ['2:255', '2:256', '3:18', '112:1'], correctIndex: 0, explanation: 'Ayatul Kursi is verse 255 of Surah Al-Baqarah, describing Allah\'s throne.'),
    QuizQuestion(question: 'What is the longest Surah in the Quran?', options: ['Al-Imran', 'An-Nisa', 'Al-Baqarah', 'Al-Maidah'], correctIndex: 2, explanation: 'Al-Baqarah has 286 verses, making it the longest Surah.'),
    QuizQuestion(question: 'Which Surah begins with "Bismillah"?', options: ['All except At-Tawbah', 'All Surahs', 'Only Meccan Surahs', 'Only Al-Fatiha'], correctIndex: 0, explanation: 'All Surahs begin with Bismillah except Surah At-Tawbah (Chapter 9).'),
  ];

  final List<QuizQuestion> _womenQuestions = [
    QuizQuestion(question: 'Which Surah is named after a woman?', options: ['Al-Nisa', 'Maryam', 'Al-Ahzab', 'Both Maryam and Al-Nisa'], correctIndex: 1, explanation: 'Surah Maryam (Chapter 19) is named after Mary, mother of Jesus (peace be upon him).'),
    QuizQuestion(question: 'Who was the first person to accept Islam?', options: ['Abu Bakr', 'Khadijah', 'Ali', 'Umar'], correctIndex: 1, explanation: 'Khadijah (RA), the Prophet\'s wife, was the first person to accept Islam.'),
    QuizQuestion(question: 'Which woman is mentioned by name in the Quran?', options: ['Aisha', 'Khadijah', 'Maryam', 'Fatimah'], correctIndex: 2, explanation: 'Maryam (Mary) is the only woman mentioned by name in the Quran.'),
    QuizQuestion(question: 'Who narrated the most Hadith among women?', options: ['Khadijah', 'Fatimah', 'Aisha', 'Hafsa'], correctIndex: 2, explanation: 'Aisha (RA) narrated over 2,200 Hadith, the most among all women.'),
    QuizQuestion(question: 'The story of which queen is mentioned in Surah An-Naml?', options: ['Queen of Egypt', 'Queen of Sheba (Bilqis)', 'Queen of Persia', 'Queen of Rome'], correctIndex: 1, explanation: 'The Queen of Sheba (Bilqis) and her encounter with Prophet Sulaiman is in Surah An-Naml.'),
  ];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQuestion].correctIndex) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  void _restartQuiz() {
    setState(() { _currentQuestion = 0; _score = 0; _showResult = false; _answered = false; _selectedAnswer = null; });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResultView();
    final question = _questions[_currentQuestion];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.womenMode ? '👩 Women Quiz' : '📖 Quran Quiz', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              const Spacer(),
              Text('Q${_currentQuestion + 1}/${_questions.length}', style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: (_currentQuestion + 1) / _questions.length, backgroundColor: Colors.white10, color: ImanFlowTheme.gold, minHeight: 6, borderRadius: BorderRadius.circular(4)),

          const SizedBox(height: 24),

          Glass(
            radius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(color: ImanFlowTheme.gold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                   child: Text('Question ${_currentQuestion + 1}', style: const TextStyle(color: ImanFlowTheme.gold, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(height: 16),
                Text(question.question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, height: 1.4)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == index;
            final isCorrect = index == question.correctIndex;
            
            Color? bgColor;
            Color? borderColor;
            
            if (_answered) {
               if (isCorrect) { bgColor = ImanFlowTheme.success.withOpacity(0.2); borderColor = ImanFlowTheme.success; }
               else if (isSelected) { bgColor = Colors.redAccent.withOpacity(0.2); borderColor = Colors.redAccent; }
            } else if (isSelected) {
               bgColor = ImanFlowTheme.emeraldGlow.withOpacity(0.2); borderColor = ImanFlowTheme.emeraldGlow;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectAnswer(index),
                child: Glass(
                  radius: 12,
                  padding: const EdgeInsets.all(16),
                  color: bgColor,
                  border: borderColor != null ? Border.all(color: borderColor) : null,
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? (borderColor ?? ImanFlowTheme.emeraldGlow) : Colors.white10,
                        ),
                        child: Center(child: Text(String.fromCharCode(65 + index), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.white))),
                      if (_answered && isCorrect) const Icon(Icons.check_circle, color: ImanFlowTheme.success),
                      if (_answered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent),
                    ],
                  ),
                ),
              ),
            );
          }),

          if (_answered) ...[
             const SizedBox(height: 16),
             Glass(
                radius: 12,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: ImanFlowTheme.gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(question.explanation, style: const TextStyle(color: Colors.white70))),
                  ],
                ),
             ),
             const SizedBox(height: 20),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: _nextQuestion,
                 style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
                 child: Text(_currentQuestion < _questions.length - 1 ? 'Next Question' : 'See Results'),
               ),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text('Quiz Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Text('You scored', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          Text('$_score/${_questions.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: ImanFlowTheme.gold)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(backgroundColor: ImanFlowTheme.gold, foregroundColor: Colors.black),
            icon: const Icon(Icons.refresh),
            label: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  QuizQuestion({required this.question, required this.options, required this.correctIndex, required this.explanation});
}
