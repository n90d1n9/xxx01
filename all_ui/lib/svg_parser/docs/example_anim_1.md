
// ============================================================================
// ANIMATION CONTROLS WIDGET
// ============================================================================

// ============================================================================
// EXAMPLE USAGE & DEMO APP
// ============================================================================

/*
void main() {
  runApp(const SvgAnimationStudioApp());
}

class SvgAnimationStudioApp extends StatelessWidget {
  const SvgAnimationStudioApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SVG Animation Studio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AnimationStudioHome(),
    );
  }
}

class AnimationStudioHome extends StatefulWidget {
  const AnimationStudioHome({Key? key}) : super(key: key);
  
  @override
  State<AnimationStudioHome> createState() => _AnimationStudioHomeState();
}

class _AnimationStudioHomeState extends State<AnimationStudioHome> {
  final _playerKey = GlobalKey<SvgAnimationPlayerState>();
  late SvgAnimationDefinition _currentAnimation;
  
  @override
  void initState() {
    super.initState();
    _currentAnimation = AnimationBuilder.rotate(
      id: 'demo_rotate',
      name: 'Rotating Square',
      duration: 2.0,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Animation Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: SvgAnimationPlayer(
                  key: _playerKey,
                  animation: _currentAnimation,
                  autoPlay: false,
                  onProgress: (progress) {
                    // Update UI if needed
                  },
                  onComplete: () {
                    debugPrint('Animation completed!');
                  },
                ),
              ),
            ),
          ),
          AnimationControls(
            playerKey: _playerKey,
            animation: _currentAnimation,
          ),
          _buildPresetButtons(),
        ],
      ),
    );
  }
  
  Widget _buildPresetButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.fade(
              id: 'fade',
              name: 'Fade In',
            )),
            child: const Text('Fade'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.slide(
              id: 'slide',
              name: 'Slide',
            )),
            child: const Text('Slide'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.rotate(
              id: 'rotate',
              name: 'Rotate',
            )),
            child: const Text('Rotate'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.scale(
              id: 'scale',
              name: 'Scale',
            )),
            child: const Text('Scale'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.bounce(
              id: 'bounce',
              name: 'Bounce',
            )),
            child: const Text('Bounce'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.pulse(
              id: 'pulse',
              name: 'Pulse',
            )),
            child: const Text('Pulse'),
          ),
          ElevatedButton(
            onPressed: () => _loadAnimation(AnimationBuilder.spinner(
              id: 'spinner',
              name: 'Loading Spinner',
            )),
            child: const Text('Spinner'),
          ),
        ],
      ),
    );
  }
  
  void _loadAnimation(SvgAnimationDefinition animation) {
    setState(() {
      _currentAnimation = animation;
    });
  }
  
  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SVG Animation Studio'),
        content: const Text(
          'Production-ready animation system with:\n\n'
          '✓ High-performance runtime player\n'
          '✓ Export to Lottie & Rive formats\n'
          '✓ Keyframe-based animations\n'
          '✓ Multiple easing functions\n'
          '✓ Layer hierarchy support\n'
          '✓ Path caching for performance\n'
          '✓ Transform animations\n'
          '✓ Opacity animations\n\n'
          'Select a preset or create custom animations!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
*/