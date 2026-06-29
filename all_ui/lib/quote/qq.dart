import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

class QuotesViewer extends StatefulWidget {
  final List<Quote> quotes;
  final Duration autoPlayDuration;
  final Duration animationDuration;
  final bool autoPlay;

  const QuotesViewer({
    Key? key,
    required this.quotes,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.animationDuration = const Duration(milliseconds: 500),
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<QuotesViewer> createState() => _QuotesViewerState();
}

class _QuotesViewerState extends State<QuotesViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start with fade in
    _fadeController.forward();

    // Auto play functionality
    if (widget.autoPlay && widget.quotes.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _stopAutoPlay(); // Stop any existing timer
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (mounted && !_isAnimating) {
        _nextQuote();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _nextQuote() async {
    if (_isAnimating || widget.quotes.isEmpty) return;

    setState(() {
      _isAnimating = true;
    });

    // Fade out
    await _fadeController.reverse();

    // Change quote
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.quotes.length;
    });

    // Fade in
    await _fadeController.forward();

    setState(() {
      _isAnimating = false;
    });
  }

  void _goToQuote(int index) async {
    if (_isAnimating || index == _currentIndex || widget.quotes.isEmpty) return;

    setState(() {
      _isAnimating = true;
    });

    // Fade out
    await _fadeController.reverse();

    // Change quote
    setState(() {
      _currentIndex = index;
    });

    // Fade in
    await _fadeController.forward();

    setState(() {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quotes.isEmpty) {
      return const Center(child: Text('No quotes available'));
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Quote Content
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Quote Text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '"${widget.quotes[_currentIndex].text}"',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Author
                    Text(
                      '— ${widget.quotes[_currentIndex].author}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              IconButton(
                onPressed:
                    _isAnimating
                        ? null
                        : () {
                          int prevIndex = _currentIndex - 1;
                          if (prevIndex < 0)
                            prevIndex = widget.quotes.length - 1;
                          _goToQuote(prevIndex);
                        },
                icon: const Icon(Icons.chevron_left),
              ),

              const SizedBox(width: 16),

              // Dot Indicators
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.quotes.length,
                  (index) => GestureDetector(
                    onTap: () => _goToQuote(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: _currentIndex == index ? 12.0 : 8.0,
                      height: _currentIndex == index ? 12.0 : 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentIndex == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Next Button
              IconButton(
                onPressed: _isAnimating ? null : _nextQuote,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Example usage widget
class QuotesViewerExample extends StatelessWidget {
  const QuotesViewerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quotes = [
      Quote(
        text: "The only way to do great work is to love what you do.",
        author: "Steve Jobs",
      ),
      Quote(
        text: "Innovation distinguishes between a leader and a follower.",
        author: "Steve Jobs",
      ),
      Quote(
        text:
            "Life is what happens to you while you're busy making other plans.",
        author: "John Lennon",
      ),
      Quote(
        text:
            "The future belongs to those who believe in the beauty of their dreams.",
        author: "Eleanor Roosevelt",
      ),
      Quote(
        text: "In the middle of difficulty lies opportunity.",
        author: "Albert Einstein",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: QuotesViewer(
        quotes: quotes,
        autoPlay: true,
        autoPlayDuration: const Duration(seconds: 5),
        animationDuration: const Duration(milliseconds: 600),
      ),
    );
  }
}

void main(List<String> args) {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuotesViewerExample(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}
