import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapTest extends StatefulWidget {
  const GoogleMapTest({super.key});

  @override
  State<GoogleMapTest> createState() => _GoogleMapTestState();
}

class _GoogleMapTestState extends State<GoogleMapTest> {
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(37.7749, -122.4194); // San Francisco
  bool _isMapReady = false;
  String? _errorMessage;
  int _errorCount = 0;

  void _onMapCreated(GoogleMapController controller) {
    print('✅ Google Maps: Map created successfully');
    setState(() {
      _mapController = controller;
      _isMapReady = true;
      _errorMessage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    print('🚀 Google Maps Test: Initializing...');
    print('📍 Center coordinates: $_center');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isMapReady = false;
                _errorMessage = null;
                _errorCount = 0;
              });
            },
            tooltip: 'Refresh Map',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: _isMapReady 
                ? Colors.green.shade100 
                : _errorMessage != null 
                    ? Colors.red.shade100 
                    : Colors.orange.shade100,
            child: Row(
              children: [
                Icon(
                  _isMapReady 
                      ? Icons.check_circle 
                      : _errorMessage != null 
                          ? Icons.error 
                          : Icons.hourglass_empty,
                  color: _isMapReady 
                      ? Colors.green 
                      : _errorMessage != null 
                          ? Colors.red 
                          : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _isMapReady 
                      ? 'Map loaded successfully' 
                      : _errorMessage != null 
                          ? 'Map error: $_errorMessage' 
                          : 'Loading map...',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_errorCount > 0) ...[
                  const Spacer(),
                  Text('Errors: $_errorCount'),
                ],
              ],
            ),
          ),
          
          // Map container
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 10.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  onCameraMove: (CameraPosition position) {
                    print('📍 Camera moved to: ${position.target}');
                  },
                  onCameraIdle: () {
                    print('🛑 Camera idle');
                  },
                ),
                
                // Loading overlay
                if (!_isMapReady && _errorMessage == null)
                  Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Loading Google Maps...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'If this takes too long, check your API key',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Error overlay
                if (_errorMessage != null)
                  Container(
                    color: Colors.white.withOpacity(0.9),
                    child: Center(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Google Maps Error',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Common solutions:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '• Check if API key is valid\n'
                                '• Enable billing in Google Cloud\n'
                                '• Enable Maps SDK for Android/iOS\n'
                                '• Check internet connection',
                                style: TextStyle(fontSize: 11),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = null;
                                    _isMapReady = false;
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isMapReady
          ? FloatingActionButton(
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _center,
                      zoom: 15.0,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
