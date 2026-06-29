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
  const WaveBeamApp({Key? key}) : super(key: key);

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
      ),
      themeMode: ThemeMode.light,
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
          name: 'Beats FM',
          streamUrl: 'https://streaming.radio.co/s5c5da6a36/listen',
          logoUrl: 'https://i.imgur.com/pDhx0TV.png',
          frequency: '98.5',
          isAnalog: true,
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
          name: 'Jazz Cafe',
          streamUrl: 'https://streaming.radio.co/s774efd19e/listen',
          logoUrl: 'https://i.imgur.com/QHxuUot.png',
          frequency: '0',
          isAnalog: false,
        ),
        RadioStation(
          id: '4',
          name: 'Classical Harmonies',
          streamUrl: 'https://streaming.radio.co/s7d70a8bff/listen',
          logoUrl: 'https://i.imgur.com/aDt2TTb.png',
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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'Favorites'),
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
                StationListView(filter: (station) => station.isFavorite),
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
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.radio, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                filter(
                      (RadioStation(
                        id: '',
                        name: '',
                        streamUrl: '',
                        logoUrl: '',
                        frequency: '',
                        isAnalog: false,
                        isFavorite: true,
                      )),
                    )
                    ? 'No favorite stations yet'
                    : 'No stations available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        )
        : ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            final isPlaying = currentStation?.id == station.id;

            return Dismissible(
              key: Key(station.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Station'),
                        content: Text(
                          'Are you sure you want to delete "${station.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );
              },
              onDismissed: (direction) {
                ref
                    .read(radioStationsProvider.notifier)
                    .removeStation(station.id);

                // Stop playback if the removed station was playing
                if (currentStation?.id == station.id) {
                  ref.read(playerProvider).stop();
                  ref.read(currentStationProvider.notifier).state = null;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${station.name} removed')),
                );
              },
              child: ListTile(
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

                        // Show snackbar feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              station.isFavorite
                                  ? '${station.name} removed from favorites'
                                  : '${station.name} added to favorites',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
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
                onLongPress: () {
                  _showStationOptionsDialog(context, ref, station);
                },
              ),
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

  void _showStationOptionsDialog(
    BuildContext context,
    WidgetRef ref,
    RadioStation station,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Station'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditStationDialog(context, ref, station);
                },
              ),
              ListTile(
                leading: Icon(
                  station.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                title: Text(
                  station.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                ),
                onTap: () {
                  ref
                      .read(radioStationsProvider.notifier)
                      .toggleFavorite(station.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Station',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Delete Station'),
                          content: Text(
                            'Are you sure you want to delete "${station.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true) {
                    // Stop playback if the removed station was playing
                    final currentStation = ref.read(currentStationProvider);
                    if (currentStation?.id == station.id) {
                      ref.read(playerProvider).stop();
                      ref.read(currentStationProvider.notifier).state = null;
                    }

                    ref
                        .read(radioStationsProvider.notifier)
                        .removeStation(station.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${station.name} removed')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditStationDialog(
    BuildContext context,
    WidgetRef ref,
    RadioStation station,
  ) {
    final nameController = TextEditingController(text: station.name);
    final streamUrlController = TextEditingController(text: station.streamUrl);
    final logoUrlController = TextEditingController(text: station.logoUrl);
    final frequencyController = TextEditingController(text: station.frequency);
    bool isAnalog = station.isAnalog;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Station'),
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
                      decoration: const InputDecoration(labelText: 'Logo URL'),
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
                      final updatedStation = RadioStation(
                        id: station.id,
                        name: nameController.text,
                        streamUrl: streamUrlController.text,
                        logoUrl: logoUrlController.text,
                        frequency: isAnalog ? frequencyController.text : '0',
                        isAnalog: isAnalog,
                        isFavorite: station.isFavorite,
                      );

                      ref
                          .read(radioStationsProvider.notifier)
                          .updateStation(updatedStation);

                      // Update current station if it's the one being edited
                      final currentStation = ref.read(currentStationProvider);
                      if (currentStation?.id == station.id) {
                        ref.read(currentStationProvider.notifier).state =
                            updatedStation;
                      }

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${updatedStation.name} updated'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class NowPlayingBar extends ConsumerWidget {
  const NowPlayingBar({Key? key}) : super(key: key);

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
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      currentStation.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: currentStation.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      ref
                          .read(radioStationsProvider.notifier)
                          .toggleFavorite(currentStation.id);
                    },
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

// Empty state for Favorites tab
class EmptyFavoritesState extends StatelessWidget {
  const EmptyFavoritesState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No favorite stations yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on any station to add it to favorites',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
