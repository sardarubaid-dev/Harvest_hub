import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

import '../../theme/app_theme.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({Key? key, this.initialLat, this.initialLng}) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _center;
  String _addressStr = "Drag map to pick location";

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.initialLat ?? 24.8607, widget.initialLng ?? 67.0011); // Default Karachi
    _reverseGeocode(_center);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      Geocoding geocoder = Geocoding();
      List<Placemark> placemarks = await geocoder.placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> parts = [];
        if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
        if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
        if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);
        
        if (mounted) {
          setState(() {
            _addressStr = parts.isNotEmpty ? parts.join(", ") : "Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressStr = "Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}";
        });
      }
    }
  }

  void _onPositionChanged(MapCamera position, bool hasGesture) {
    _center = position.center;
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      _reverseGeocode(_center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.0,
              onPositionChanged: _onPositionChanged,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.techwiz.harvesthub',
              ),
            ],
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), 
              child: Icon(
                Icons.location_on,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Location',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _addressStr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          'latitude': _center.latitude,
                          'longitude': _center.longitude,
                          'address': _addressStr,
                        });
                      },
                      child: const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
