import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Gallery',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black, elevation: 0),
        colorScheme: ColorScheme.dark(
          primary: Colors.red,
          secondary: Colors.red,
        ),
      ),
      home: YoutubeScreen(),
    );
  }
}

class YoutubeScreen extends StatefulWidget {
  @override
  _YoutubeScreenState createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    VideoGalleryScreen(),
    Center(child: Text('Shorts')),
    Center(child: Text('Create')),
    Center(child: Text('Subscriptions')),
    Center(child: Text('Library')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill),
            label: 'Shorts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined),
            activeIcon: Icon(Icons.subscriptions),
            label: 'Subscriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}

class VideoGalleryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Row(
            children: [
              Image.asset('assets/logo.png', height: 24),
              SizedBox(width: 4),
              Text('Viewfy', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            IconButton(icon: Icon(Icons.cast), onPressed: () {}),
            IconButton(
              icon: Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            SizedBox(width: 16),
          ],
        ),
        SliverToBoxAdapter(child: CategoryChips()),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            // First video is featured
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VideoPlayerScreen(videoIndex: index),
                    ),
                  );
                },
                child: FeaturedVideoCard(index: index),
              );
            }
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(videoIndex: index),
                  ),
                );
              },
              child: VideoCard(index: index),
            );
          }, childCount: 20),
        ),
      ],
    );
  }
}

class CategoryChips extends StatelessWidget {
  final List<String> categories = [
    'All',
    'Music',
    'Gaming',
    'Live',
    'News',
    'Comedy',
    'Nature',
    'Animation',
    'Sports',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Chip(
              backgroundColor: index == 0 ? Colors.white : Colors.grey[800],
              label: Text(
                categories[index],
                style: TextStyle(
                  color: index == 0 ? Colors.black : Colors.white,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }
}

class FeaturedVideoCard extends StatelessWidget {
  final int index;

  const FeaturedVideoCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/1280x720'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '12:45',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amazing Nature Documentary - Featured Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Nature Channel • 1.2M views • 3 days ago',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[900]),
      ],
    );
  }
}

class VideoCard extends StatelessWidget {
  final int index;

  const VideoCard({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/1280x720'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(index + 5).toString()}:${(index * 10).toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Title ${index + 1} - This is a sample video title that might be long',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Channel Name • ${(index + 1) * 100}K views • ${index + 1} days ago',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey[900]),
      ],
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final int videoIndex;

  VideoPlayerScreen({required this.videoIndex});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    // This is just for demonstration. In a real app, you would load actual videos
    _controller = VideoPlayerController.network(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      )
      ..initialize().then((_) {
        setState(() {
          _duration = _controller.value.duration;
        });
        _controller.play();
        _isPlaying = true;
      });

    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
      setState(() {
        _position = _controller.value.position;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String hours =
        duration.inHours > 0
            ? duration.inHours.toString().padLeft(2, '0') + ':'
            : '';
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours$minutes:$seconds';
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isFullScreen
              ? null
              : AppBar(
                title: Text('Video Player'),
                actions: [
                  IconButton(icon: Icon(Icons.cast), onPressed: () {}),
                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
                  IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              color: Colors.black,
              height:
                  _isFullScreen
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.width * 9 / 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  if (_showControls)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.settings),
                                color: Colors.white,
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.skip_previous),
                                color: Colors.white,
                                iconSize: 36,
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                color: Colors.white,
                                iconSize: 48,
                                onPressed: () {
                                  setState(() {
                                    if (_isPlaying) {
                                      _controller.pause();
                                    } else {
                                      _controller.play();
                                    }
                                    _isPlaying = !_isPlaying;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next),
                                color: Colors.white,
                                iconSize: 36,
                                onPressed: () {},
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    thumbColor: Colors.red,
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor: Colors.grey,
                                    trackHeight: 2.0,
                                  ),
                                  child: Slider(
                                    value: _position.inSeconds.toDouble(),
                                    min: 0.0,
                                    max: _duration.inSeconds.toDouble(),
                                    onChanged: (value) {
                                      final newPosition = Duration(
                                        seconds: value.toInt(),
                                      );
                                      _controller.seekTo(newPosition);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            _formatDuration(_duration),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              _isFullScreen
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen,
                                            ),
                                            color: Colors.white,
                                            onPressed: _toggleFullScreen,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!_isFullScreen)
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Video Title ${widget.videoIndex + 1} - Amazing Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(widget.videoIndex + 1) * 100}K views • ${widget.videoIndex + 1} days ago',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(Icons.thumb_up_outlined, 'Like'),
                            _buildActionButton(
                              Icons.thumb_down_outlined,
                              'Dislike',
                            ),
                            _buildActionButton(Icons.share, 'Share'),
                            _buildActionButton(Icons.download, 'Download'),
                            _buildActionButton(Icons.library_add, 'Save'),
                          ],
                        ),
                        Divider(height: 32, thickness: 1),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150',
                              ),
                              radius: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Channel Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${(widget.videoIndex + 1) * 10}M subscribers',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('SUBSCRIBE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 32, thickness: 1),
                        Text(
                          'Comments • 1.2K',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/150',
                              ),
                              radius: 16,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'User Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '2 days ago',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'This is an amazing video! I learned so much from it.',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up_outlined, size: 16),
                                      SizedBox(width: 4),
                                      Text('42'),
                                      SizedBox(width: 16),
                                      Icon(Icons.thumb_down_outlined, size: 16),
                                      SizedBox(width: 16),
                                      Text('REPLY'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, thickness: 8, color: Colors.grey[900]),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Up next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  height: 80,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://via.placeholder.com/300x200',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    '5:${(index * 10).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Related Video ${index + 1} - Watch this amazing content next',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Channel Name',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${(index + 1) * 50}K views • ${index + 2} days ago',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert, size: 16),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
