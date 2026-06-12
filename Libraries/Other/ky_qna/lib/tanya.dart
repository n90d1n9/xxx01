import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'answer.dart';
import 'answer_detail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Islamic Q&A',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E6F5C),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E6F5C),
          elevation: 0,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1E6F5C),
          secondary: const Color(0xFF29BB89),
        ),
      ),
      home: const QAScreen(),
    );
  }
}

class QAScreen extends StatefulWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final List<QAItem> _qaItems = [
    QAItem(
      id: '1',
      question: "Is it permissible to pray while wearing shoes?",
      askedBy: "Ahmad",
      date: "April 9, 2025",
      answer:
          "Yes, it is permissible to pray while wearing shoes as long as they are clean and free from impurities (najasah). This is based on numerous authentic hadiths where the Prophet Muhammad ﷺ prayed with his shoes on. However, one should be mindful of the cleanliness of the shoes and the prayer area, especially in mosques where carpets are used. In many mosques today, it's customary to remove shoes as a matter of respect and cleanliness.",
      ustadh: "Ustadh Ibrahim Khan",
      ustadhTitle: "Professor of Islamic Jurisprudence",
      answerDate: "April 9, 2025",
      likes: 145,
      bookmarked: true,
    ),
    QAItem(
      id: '2',
      question:
          "What is the ruling on digital currencies like Bitcoin from an Islamic perspective?",
      askedBy: "Fatima",
      date: "April 8, 2025",
      answer:
          "Digital currencies present a contemporary issue that requires careful analysis. From an Islamic finance perspective, cryptocurrencies like Bitcoin may be permissible for trading if they avoid elements of excessive uncertainty (gharar), gambling (maysir), and interest (riba). However, scholars differ in their opinions. Some consider them acceptable as a medium of exchange and store of value, while others express concerns about their speculative nature and potential for misuse. I recommend consulting with Islamic finance experts for specific situations and following the guidance of recognized fiqh councils on this evolving topic.",
      ustadh: "Ustadh Yusuf Ali",
      ustadhTitle: "Islamic Finance Specialist",
      answerDate: "April 9, 2025",
      likes: 89,
      bookmarked: false,
    ),
    QAItem(
      id: '3',
      question: "How can I improve my focus during prayer (khushu in salah)?",
      askedBy: "Maryam",
      date: "April 7, 2025",
      answer:
          "Improving khushu (focus and concentration) in prayer is a common challenge many Muslims face. Some practical tips include: 1) Prepare properly by performing wudu mindfully and finding a quiet place. 2) Understand the meaning of what you're reciting in prayer. 3) Pray as if it's your last prayer. 4) Focus on each movement and utterance. 5) Remember you are standing before Allah. 6) Minimize distractions before prayer. 7) Practice regular dhikr (remembrance) outside of prayer times. 8) Be patient with yourself - building khushu is a gradual process that improves with sincerity and practice.",
      ustadh: "Ustadha Aisha Rahman",
      ustadhTitle: "Spiritual Development Counselor",
      answerDate: "April 8, 2025",
      likes: 237,
      bookmarked: true,
    ),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Islamic Guidance',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip('Recent', 0),
                _buildFilterChip('Popular', 1),
                _buildFilterChip('Bookmarked', 2),
                _buildFilterChip('My Questions', 3),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _qaItems.length,
              itemBuilder: (context, index) {
                return _buildQACard(_qaItems[index]);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'answerBtn',
            backgroundColor: Colors.orange,
            child: const Icon(Icons.question_answer, color: Colors.white),
            onPressed: () {
              // Show a list of unanswered questions or go to a specific one
              _openUstadhAnswerScreen(_qaItems[0]);
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'askBtn',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.question_mark_rounded, color: Colors.white),
            onPressed: () {
              _showAskQuestionModal(context);
            },
          ),
        ],
      ),
      /* 

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.question_mark_rounded, color: Colors.white),
        onPressed: () {
          _showAskQuestionModal(context);
        },
      ), */
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildQACard(QAItem item) {
    return InkWell(
      onTap: () {
        _openDetailAnswerScreen(item);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.question_mark, color: Color(0xFF1E6F5C)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Asked by ${item.askedBy} • ${item.date}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      item.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color:
                          item.bookmarked
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        item.bookmarked = !item.bookmarked;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E6F5C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.person, color: Color(0xFF1E6F5C)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.ustadh!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.ustadhTitle!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item.answerDate!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.answer!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        item.likes += 1;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.likes}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Comments',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAskQuestionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ask a Question',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type your question here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Add tags (optional)',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your question has been submitted'),
                        backgroundColor: Color(0xFF29BB89),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Question',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _openUstadhAnswerScreen(QAItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UstadhAnswerScreen(question: item),
      ),
    );
  }

  void _openDetailAnswerScreen(QAItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailAnswerScreen(qaItem: item)),
    );
  }
}

class QAItem {
  final String id;
  final String question;
  final String askedBy;
  final String date;
  final String? answer;
  final String? ustadh;
  final String? ustadhTitle;
  final String? answerDate;
  int likes;
  bool bookmarked;

  QAItem({
    required this.id,
    required this.question,
    required this.askedBy,
    required this.date,
    required this.answer,
    required this.ustadh,
    this.ustadhTitle = '',
    required this.answerDate,
    required this.likes,
    required this.bookmarked,
  });
}
