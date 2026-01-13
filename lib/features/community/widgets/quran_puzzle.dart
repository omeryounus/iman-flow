import 'package:flutter/material.dart';
import 'dart:math';
import '../../../app/theme.dart';

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

  final List<QuizQuestion> _generalQuestions = [
    QuizQuestion(
      question: 'Which Surah is known as the "Heart of the Quran"?',
      options: ['Al-Fatiha', 'Ya-Sin', 'Al-Baqarah', 'Al-Ikhlas'],
      correctIndex: 1,
      explanation: 'Surah Ya-Sin is called the Heart of the Quran due to its emphasis on core Islamic teachings.',
    ),
    QuizQuestion(
      question: 'How many verses are in Surah Al-Fatiha?',
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
      explanation: 'Al-Fatiha has 7 verses and is recited in every unit of prayer.',
    ),
    QuizQuestion(
      question: 'Which verse is called "Ayatul Kursi"?',
      options: ['2:255', '2:256', '3:18', '112:1'],
      correctIndex: 0,
      explanation: 'Ayatul Kursi is verse 255 of Surah Al-Baqarah, describing Allah\'s throne.',
    ),
    QuizQuestion(
      question: 'What is the longest Surah in the Quran?',
      options: ['Al-Imran', 'An-Nisa', 'Al-Baqarah', 'Al-Maidah'],
      correctIndex: 2,
      explanation: 'Al-Baqarah has 286 verses, making it the longest Surah.',
    ),
    QuizQuestion(
      question: 'Which Surah begins with "Bismillah"?',
      options: ['All except At-Tawbah', 'All Surahs', 'Only Meccan Surahs', 'Only Al-Fatiha'],
      correctIndex: 0,
      explanation: 'All Surahs begin with Bismillah except Surah At-Tawbah (Chapter 9).',
    ),
  ];

  final List<QuizQuestion> _womenQuestions = [
    QuizQuestion(
      question: 'Which Surah is named after a woman?',
      options: ['Al-Nisa', 'Maryam', 'Al-Ahzab', 'Both Maryam and Al-Nisa'],
      correctIndex: 1,
      explanation: 'Surah Maryam (Chapter 19) is named after Mary, mother of Jesus (peace be upon him).',
    ),
    QuizQuestion(
      question: 'Who was the first person to accept Islam?',
      options: ['Abu Bakr', 'Khadijah', 'Ali', 'Umar'],
      correctIndex: 1,
      explanation: 'Khadijah (RA), the Prophet\'s wife, was the first person to accept Islam.',
    ),
    QuizQuestion(
      question: 'Which woman is mentioned by name in the Quran?',
      options: ['Aisha', 'Khadijah', 'Maryam', 'Fatimah'],
      correctIndex: 2,
      explanation: 'Maryam (Mary) is the only woman mentioned by name in the Quran.',
    ),
    QuizQuestion(
      question: 'Who narrated the most Hadith among women?',
      options: ['Khadijah', 'Fatimah', 'Aisha', 'Hafsa'],
      correctIndex: 2,
      explanation: 'Aisha (RA) narrated over 2,200 Hadith, the most among all women.',
    ),
    QuizQuestion(
      question: 'The story of which queen is mentioned in Surah An-Naml?',
      options: ['Queen of Egypt', 'Queen of Sheba (Bilqis)', 'Queen of Persia', 'Queen of Rome'],
      correctIndex: 1,
      explanation: 'The Queen of Sheba (Bilqis) and her encounter with Prophet Sulaiman is in Surah An-Naml.',
    ),
  ];

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentQuestion].correctIndex) {
        _score++;
      }
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
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _showResult = false;
      _answered = false;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultView();
    }

    final question = _questions[_currentQuestion];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text(
                widget.womenMode ? '👩 Women in Islam Quiz' : '📖 Quran Quiz',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Q${_currentQuestion + 1}/${_questions.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(ImanFlowTheme.primaryGreen),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 24),

          // Question Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ImanFlowTheme.accentGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question ${_currentQuestion + 1}',
                    style: TextStyle(
                      color: ImanFlowTheme.accentGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options
          ...question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = _selectedAnswer == index;
            final isCorrect = index == question.correctIndex;

            Color? backgroundColor;
            Color? borderColor;

            if (_answered) {
              if (isCorrect) {
                backgroundColor = ImanFlowTheme.success.withOpacity(0.1);
                borderColor = ImanFlowTheme.success;
              } else if (isSelected && !isCorrect) {
                backgroundColor = ImanFlowTheme.error.withOpacity(0.1);
                borderColor = ImanFlowTheme.error;
              }
            } else if (isSelected) {
              backgroundColor = ImanFlowTheme.primaryGreen.withOpacity(0.1);
              borderColor = ImanFlowTheme.primaryGreen;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _selectAnswer(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor ?? Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor ?? Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (borderColor ?? ImanFlowTheme.primaryGreen)
                              : Colors.grey.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (_answered && isCorrect)
                        Icon(Icons.check_circle, color: ImanFlowTheme.success),
                      if (_answered && isSelected && !isCorrect)
                        Icon(Icons.cancel, color: ImanFlowTheme.error),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explanation (after answering)
          if (_answered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ImanFlowTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ImanFlowTheme.accentGold.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: ImanFlowTheme.accentGold,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestion < _questions.length - 1
                      ? 'Next Question'
                      : 'See Results',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final percentage = (_score / _questions.length * 100).round();
    String message;
    String emoji;

    if (percentage >= 80) {
      message = 'Excellent! MashaAllah! 🌟';
      emoji = '🏆';
    } else if (percentage >= 60) {
      message = 'Good job! Keep learning!';
      emoji = '👍';
    } else {
      message = 'Keep practicing! You got this!';
      emoji = '📚';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              'Quiz Complete!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You scored',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$_score/${_questions.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: ImanFlowTheme.primaryGreen,
              ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Play Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Share result
              },
              child: const Text('Share Result'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
