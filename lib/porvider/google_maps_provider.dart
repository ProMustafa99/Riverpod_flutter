import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/location_permission_handler.dart';

// Provider for current location
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  } catch (e) {
    throw Exception('Failed to get location: $e');
  }
});

// Provider for map controller
final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);

// Provider for map camera position
final cameraPositionProvider = StateProvider<CameraPosition>((ref) {
  return const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default to San Francisco
    zoom: 14.0,
  );
});

// Provider for markers
final markersProvider = StateProvider<Set<Marker>>((ref) => {});

// Provider for current location marker
final currentLocationMarkerProvider = Provider<Marker>((ref) {
  final location = ref.watch(currentLocationProvider);
  
  return location.when(
    data: (position) => Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(position!.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: 'Current Location',
        snippet: 'You are here',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
    loading: () => const Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(37.7749, -122.4194),
    ),
    error: (error, stack) => const Marker(
      markerId: MarkerId('current_location'),
      position: LatLng(37.7749, -122.4194),
    ),
  );
});

// Provider for address from coordinates
final addressProvider = FutureProvider.family<String, LatLng>((ref, latLng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return '${place.street}, ${place.locality}, ${place.administrativeArea}';
    }
    return 'Unknown location';
  } catch (e) {
    return 'Error getting address';
  }
});

// Provider for search locations
final searchLocationsProvider = FutureProvider.family<List<Location>, String>((ref, query) async {
  try {
    List<Location> locations = await locationFromAddress(query);
    return locations;
  } catch (e) {
    return [];
  }
});
