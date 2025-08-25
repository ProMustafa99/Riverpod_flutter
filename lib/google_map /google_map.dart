import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      _showLocationDialog(
        'Location Services Disabled',
        'Please enable location services to use this feature.',
        'Enable Location',
        () => Geolocator.openLocationSettings(),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog(
          'Location Permission Denied',
          'Location permission is required to show your current location.',
          'Grant Permission',
          () => Geolocator.openAppSettings(),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog(
        'Location Permission Permanently Denied',
        'Location permission has been permanently denied. Please enable it in app settings.',
        'Open Settings',
        () => Geolocator.openAppSettings(),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng current = LatLng(position.latitude, position.longitude);
    _setMarker(current);

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(current, 15),
    );
  }

  /// 🔹 Show location permission/service dialog
  void _showLocationDialog(String title, String message, String actionText, VoidCallback onAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction();
              },
              child: Text(actionText),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Centralized function to add/update marker
  void _setMarker(LatLng position) {
    setState(() {
      _currentPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId("current_location"),
          position: position,
          infoWindow: InfoWindow(title: position.toString()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            _setMarker(newPosition);
          },
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-23.5557714, -46.6395571),
          zoom: 12.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
