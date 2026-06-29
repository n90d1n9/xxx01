import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  double? _distance;

  // Function to get current location
 /*  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  } */

  // Function to get route details from Google Maps Directions API
  Future<void> _getRoute() async {
    if (_currentPosition != null && _destination != null) {
      // Build API URL
      final String apiUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY';

      // Fetch data from Google Maps API
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract route points
        final routes = data['routes'];
        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'];
          final steps = legs[0]['steps'];
          _routePoints = [];
          for (final step in steps) {
            final startLocation = step['start_location'];
            final endLocation = step['end_location'];
            _routePoints.add(LatLng(startLocation['lat'], startLocation['lng']));
            _routePoints.add(LatLng(endLocation['lat'], endLocation['lng']));
          }

          // Calculate total distance
          _distance = routes[0]['legs'][0]['distance']['value'] / 1000;

          setState(() {});
        }
      } else {
        // Handle API request error
        print('Error: ${response.statusCode}');
      }
    }
  }

  // Function to handle map tap events
  void _onMapTap(LatLng point) {
    setState(() {
      _destination = point;
      _getRoute();
    });
  }

  @override
  void initState() {
    super.initState();
    //_getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Maps Route'),
      ),
      body: _currentPosition != null
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: _onMapTap,
                  markers: {
                    // Current location marker
                    if (_currentPosition != null)
                      Marker(
                        markerId: MarkerId('current_location'),
                        position: _currentPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                      ),
                    // Destination marker
                    if (_destination != null)
                      Marker(
                        markerId: MarkerId('destination'),
                        position: _destination!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                  },
                  polylines: {
                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      Polyline(
                        polylineId: PolylineId('route'),
                        color: Colors.blue,
                        width: 5,
                        points: _routePoints,
                      ),
                  },
                ),
                // Distance display
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _distance != null
                          ? 'Distance: $_distance km'
                          : 'Tap on the map to set a destination',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}