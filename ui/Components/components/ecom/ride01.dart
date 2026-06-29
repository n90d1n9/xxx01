import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideBookingWidget extends StatefulWidget {
  const RideBookingWidget({Key? key}) : super(key: key);

  @override
  State<RideBookingWidget> createState() => _RideBookingWidgetState();
}

class _RideBookingWidgetState extends State<RideBookingWidget> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(1.3521, 103.8198);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: const MarkerId('start'),
      position: const LatLng(1.3521, 103.8198),
      infoWindow: const InfoWindow(title: 'TripleOne Somerset'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('end'),
      position: const LatLng(1.3571, 103.9682),
      infoWindow: const InfoWindow(title: 'Terminal 3 - Changi'),
    ));
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.green,
      points: [
        const LatLng(1.3521, 103.8198),
        const LatLng(1.3571, 103.9682),
      ],
      width: 5,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Ride Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JustGrab',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.person),
                    Text('4'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('8:47AM - 8:56AM drop off'),
                const SizedBox(height: 4),
                const Text('2x large luggage'),
                const SizedBox(height: 16),
                const Text(
                  'GrabCar Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.person),
                    Text('4'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('8:44AM - 8:53AM drop off'),
                const SizedBox(height: 4),
                const Text('2x large luggage'),
                const SizedBox(height: 16),
                const Text(
                  'GrabCar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.person),
                    Text('4'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('8:47AM - 8:56AM drop off'),
                const SizedBox(height: 4),
                const Text('2x large luggage'),
                const SizedBox(height: 16),
                const Text(
                  'GrabCar 6',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.person),
                    Text('6'),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('8:46AM - 8:54AM drop off'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                        ),
                        child: const Text(
                          'Book JustGrab',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                      ),
                      child: const Text(
                        'Cash',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}