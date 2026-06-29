// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: WaveBeamApp()));
}

class WaveBeamApp extends StatelessWidget {
  const WaveBeamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaveBeam Radio',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C5CE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFA29BFE),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF6C5CE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFA29BFE),
          brightness: Brightness.dark,
        ),
        //fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

// Models
class RadioStation {
  final String id;
  final String name;
  final String streamUrl;
  final String logoUrl;
  final String frequency;
  final bool isAnalog;
  bool isFavorite;

  RadioStation({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logoUrl,
    required this.frequency,
    required this.isAnalog,
    this.isFavorite = false,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'],
      name: json['name'],
      streamUrl: json['streamUrl'],
      logoUrl: json['logoUrl'],
      frequency: json['frequency'],
      isAnalog: json['isAnalog'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'frequency': frequency,
      'isAnalog': isAnalog,
      'isFavorite': isFavorite,
    };
  }

  RadioStation copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? logoUrl,
    String? frequency,
    bool? isAnalog,
    bool? isFavorite,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      frequency: frequency ?? this.frequency,
      isAnalog: isAnalog ?? this.isAnalog,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Providers
final radioStationsProvider =
    StateNotifierProvider<RadioStationsNotifier, List<RadioStation>>((ref) {
      return RadioStationsNotifier();
    });

final currentStationProvider = StateProvider<RadioStation?>((ref) => null);

final playerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

final playbackStateProvider = StreamProvider<bool>((ref) {
  final player = ref.watch(playerProvider);
  return player.playingStream;
});

final isAnalogModeProvider = StateProvider<bool>((ref) => false);

final volumeProvider = StateProvider<double>((ref) => 0.5);

final favoriteStationsProvider = Provider<List<RadioStation>>((ref) {
  final stations = ref.watch(radioStationsProvider);
  return stations.where((station) => station.isFavorite).toList();
});

// Notifier
class RadioStationsNotifier extends StateNotifier<List<RadioStation>> {
  RadioStationsNotifier() : super([]) {
    _loadStations();
  }

  Future<void> _loadStations() async {
    final prefs = await SharedPreferences.getInstance();
    final stationsJson = prefs.getStringList('stations') ?? [];

    if (stationsJson.isEmpty) {
      // Load default stations if none are saved
      state = [
        RadioStation(
          id: '1',
          name: 'Delta FM',
          streamUrl: 'https://s1.cloudmu.id/listen/delta_fm/radio.mp3',
          logoUrl: 'https://i.imgur.com/aDt2TTb.png',
          frequency: '0',
          isAnalog: false,
        ),

        RadioStation(
          id: '2',
          name: 'Chill Lounge',
          streamUrl: 'https://streaming.radio.co/s3e9c39473/listen',
          logoUrl: 'https://i.imgur.com/WRKG3vL.png',
          frequency: '103.2',
          isAnalog: true,
        ),
        RadioStation(
          id: '3',
          name: 'Oz Radio Bandung',
          streamUrl: 'https://streaming.ozradio.id:8443/ozbandung',
          logoUrl: 'https://i.imgur.com/QHxuUot.png',
          frequency: '0',
          isAnalog: false,
        ),
      ];
    } else {
      state =
          stationsJson
              .map((json) => RadioStation.fromJson(jsonDecode(json)))
              .toList();
    }
  }

  Future<void> _saveStations() async {
    final prefs = await SharedPreferences.getInstance();
    final stationsJson =
        state.map((station) => jsonEncode(station.toJson())).toList();
    await prefs.setStringList('stations', stationsJson);
  }

  void addStation(RadioStation station) {
    state = [...state, station];
    _saveStations();
  }

  void removeStation(String id) {
    state = state.where((station) => station.id != id).toList();
    _saveStations();
  }

  void toggleFavorite(String id) {
    state =
        state.map((station) {
          if (station.id == id) {
            return station.copyWith(isFavorite: !station.isFavorite);
          }
          return station;
        }).toList();
    _saveStations();
  }

  void updateStation(RadioStation updatedStation) {
    state =
        state.map((station) {
          if (station.id == updatedStation.id) {
            return updatedStation;
          }
          return station;
        }).toList();
    _saveStations();
  }
}

// UI Components
class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('WaveBeam Radio'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Analog'),
            Tab(text: 'Digital'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StationListView(filter: (station) => true),
                StationListView(filter: (station) => station.isAnalog),
                StationListView(filter: (station) => !station.isAnalog),
              ],
            ),
          ),
          const NowPlayingBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStationDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddStationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final streamUrlController = TextEditingController();
    final logoUrlController = TextEditingController();
    final frequencyController = TextEditingController();
    bool isAnalog = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Station'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Station Name',
                      ),
                    ),
                    TextField(
                      controller: streamUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Stream URL',
                      ),
                    ),
                    TextField(
                      controller: logoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Logo URL (optional)',
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Analog Station'),
                      value: isAnalog,
                      onChanged: (value) {
                        setState(() {
                          isAnalog = value;
                        });
                      },
                    ),
                    if (isAnalog)
                      TextField(
                        controller: frequencyController,
                        decoration: const InputDecoration(
                          labelText: 'FM Frequency (e.g. 98.5)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        streamUrlController.text.isNotEmpty) {
                      final newStation = RadioStation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        streamUrl: streamUrlController.text,
                        logoUrl:
                            logoUrlController.text.isNotEmpty
                                ? logoUrlController.text
                                : 'https://i.imgur.com/placeholder.png',
                        frequency: isAnalog ? frequencyController.text : '0',
                        isAnalog: isAnalog,
                      );
                      ref
                          .read(radioStationsProvider.notifier)
                          .addStation(newStation);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class StationListView extends ConsumerWidget {
  final bool Function(RadioStation) filter;

  const StationListView({Key? key, required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stations = ref.watch(radioStationsProvider).where(filter).toList();
    final currentStation = ref.watch(currentStationProvider);

    return stations.isEmpty
        ? const Center(child: Text('No stations available'))
        : ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            final isPlaying = currentStation?.id == station.id;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(station.logoUrl),
                backgroundColor: Colors.grey[200],
              ),
              title: Text(station.name),
              subtitle: Text(
                station.isAnalog ? 'FM ${station.frequency}' : 'Streaming',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      station.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: station.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      ref
                          .read(radioStationsProvider.notifier)
                          .toggleFavorite(station.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      _handlePlayPause(ref, station, isPlaying);
                    },
                  ),
                ],
              ),
              onTap: () {
                _handlePlayPause(ref, station, isPlaying);
              },
            );
          },
        );
  }

  void _handlePlayPause(
    WidgetRef ref,
    RadioStation station,
    bool isPlaying,
  ) async {
    final player = ref.read(playerProvider);

    if (isPlaying) {
      await player.pause();
    } else {
      ref.read(currentStationProvider.notifier).state = station;
      await player.setVolume(ref.read(volumeProvider));
      await player.setUrl(station.streamUrl);
      await player.play();
    }
  }
}

class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStation = ref.watch(currentStationProvider);
    final isPlaying = ref.watch(playbackStateProvider).valueOrNull ?? false;
    final volume = ref.watch(volumeProvider);

    if (currentStation == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(currentStation.logoUrl),
                radius: 25,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStation.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      currentStation.isAnalog
                          ? 'FM ${currentStation.frequency}'
                          : 'Digital Stream',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  final player = ref.read(playerProvider);
                  if (isPlaying) {
                    player.pause();
                  } else {
                    player.play();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                volume == 0
                    ? Icons.volume_off
                    : volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    ref.read(volumeProvider.notifier).state = value;
                    ref.read(playerProvider).setVolume(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Favorites Page
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteStationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body:
          favorites.isEmpty
              ? const Center(child: Text('No favorite stations yet'))
              : StationListView(filter: (station) => station.isFavorite),
    );
  }
}
