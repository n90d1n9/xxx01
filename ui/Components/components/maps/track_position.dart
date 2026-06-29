import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poiState = ref.watch(poiProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('POI Near Me'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 15,
        ),
        markers: poiState.pois.map((poi) {
          return Marker(
            markerId: MarkerId(poi.name),
            position: LatLng(poi.latitude, poi.longitude),
            infoWindow: InfoWindow(title: poi.name),
          );
        }).toSet(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

final poiProvider = StateNotifierProvider<POINotifier, POIState>((ref) {
  return POINotifier();
});

class POINotifier extends StateNotifier<POIState> {
  POINotifier() : super(POIState(pois: [])) {
    _init();
  }

  Future<void> _init() async {
    await _determinePosition();
    await _fetchPOIs(0.0, 0.0);
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    await _fetchPOIs(position.latitude, position.longitude);
  }

  Future<void> _fetchPOIs(double latitude, double longitude) async {
    final apiKey = 'YOUR_GOOGLE_API_KEY';
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$latitude,$longitude&radius=1500&type=point_of_interest&key=$apiKey';

    final response = await Dio().get(url);

    if (response.statusCode == 200) {
      final data = response.data['results'] as List;
      final pois = data.map((item) {
        return POI(
          name: item['name'],
          latitude: item['geometry']['location']['lat'],
          longitude: item['geometry']['location']['lng'],
        );
      }).toList();

      state = POIState(pois: pois);
    } else {
      throw Exception('Failed to load POIs');
    }
  }
}

class POI {
  final String name;
  final double latitude;
  final double longitude;

  POI({required this.name, required this.latitude, required this.longitude});
}

class POIState {
  final List<POI> pois;

  POIState({required this.pois});
}
