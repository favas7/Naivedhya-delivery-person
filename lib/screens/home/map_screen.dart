// lib/screens/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/delivery_provider.dart';
import 'package:naivedhya_delivery_app/service/location_service.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  final String? orderId;
  
  const MapScreen({super.key, this.orderId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  
  // ignore: unused_field
  bool _isMapReady = false;
  bool _isLocationPermissionGranted = false;
  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  
  // Tracking state
  bool _isTracking = false;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Initialize location service
    _isLocationPermissionGranted = await _locationService.initialize();
    
    if (_isLocationPermissionGranted && mounted) {
      await _getCurrentLocation();
      _setupLocationUpdates();
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = _locationService.currentPosition;
    if (position != null && mounted) {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMarkers();
    }
  }

  void _setupLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        // Check if widget is still mounted and tracking is active
        if (mounted && _isTracking) {
          _getCurrentLocation();
        }
      },
    );
  }

  void _updateMarkers() {
    // Always check if widget is mounted before calling setState
    if (!mounted) return;
    
    Set<Marker> markers = {};

    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current delivery partner location',
          ),
        ),
      );
    }

    // Add destination marker if available
    if (_destinationLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Destination',
            snippet: 'Delivery destination',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mounted) return;
    
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });

    // Move camera to current location if available
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
      );
    }
  }

  Future<void> _startLocationTracking() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      final success = await _locationService.startTracking(
        authProvider.user!.id,
        orderId: widget.orderId,
      );
      
      if (mounted && success) {
        setState(() {
          _isTracking = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location tracking started'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start location tracking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopLocationTracking() {
    if (!mounted) return;
    
    _locationService.stopTracking();
    setState(() {
      _isTracking = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location tracking stopped'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_currentLocation != null && _mapController != null && mounted) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
      );
    }
  }

  Widget _buildTrackingButton() {
    return FloatingActionButton.extended(
      onPressed: _isTracking ? _stopLocationTracking : _startLocationTracking,
      backgroundColor: _isTracking ? Colors.red : AppColors.primary,
      icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
      label: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
    );
  }

  Widget _buildLocationButton() {
    return FloatingActionButton(
      onPressed: _centerOnCurrentLocation,
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.my_location,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_isTracking ? AppColors.success : AppColors.warning).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isTracking ? Icons.location_on : Icons.location_off,
                  color: _isTracking ? AppColors.success : AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isTracking ? 'Location Sharing Active' : 'Location Sharing Inactive',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _isTracking 
                          ? 'Your location is being shared with customers'
                          : 'Start tracking to share your location',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_currentLocation != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_pin,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          Consumer<DeliveryProvider>(
            builder: (context, deliveryProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: deliveryProvider.isAvailable 
                      ? AppColors.success.withAlpha(26)
                      : Colors.grey.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: deliveryProvider.isAvailable 
                            ? AppColors.success 
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      deliveryProvider.isAvailable ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: deliveryProvider.isAvailable 
                            ? AppColors.success 
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLocationPermissionGranted
          ? Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(10.0261, 76.3105), // Default to Kochi
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  trafficEnabled: true,
                ),
                
                // Status Card
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildStatusCard(),
                ),
                
                // Location Button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: _buildLocationButton(),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Location Permission Required',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable location permissions to use the map',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _initializeMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            ),
      floatingActionButton: _isLocationPermissionGranted ? _buildTrackingButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}