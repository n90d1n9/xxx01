import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupMaps01 extends StatefulWidget {
  const PickupMaps01({Key? key}) : super(key: key);

  @override
  State<PickupMaps01> createState() => _PickupMaps01State();
}

class _PickupMaps01State extends State<PickupMaps01> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(1.290270, 103.851959);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: const MarkerId('1'),
      position: const LatLng(1.290270, 103.851959),
      infoWindow: const InfoWindow(title: 'TripleOne Somerset'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('2'),
      position: const LatLng(1.290670, 103.851959),
      infoWindow: const InfoWindow(title: 'Somerset Rd Entrance'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('3'),
      position: const LatLng(1.290070, 103.851959),
      infoWindow: const InfoWindow(title: 'Exeter Rd Entrance'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 16.0,
        ),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
            ),
          );
        },
        label: const Text('Reset'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}