import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/outage.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/location_provider.dart';

class OutageMapScreen extends ConsumerStatefulWidget {
  const OutageMapScreen({super.key});

  @override
  ConsumerState<OutageMapScreen> createState() => _OutageMapScreenState();
}

class _OutageMapScreenState extends ConsumerState<OutageMapScreen> {
  GoogleMapController? _mapController;
  final Set<Circle> _circles = {};
  final Set<Marker> _markers = {};

  // Default position (will be updated with user location)
  static const LatLng _defaultPosition = LatLng(18.1096, -77.2975); // Jamaica

  @override
  Widget build(BuildContext context) {
    final outages = ref.watch(outagesProvider);
    final locationAsync = ref.watch(currentLocationProvider);

    // Update circles when outages change
    _updateOutageCircles(outages);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outage Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToMyLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(currentLocationProvider);
              ref.invalidate(outagesProvider);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: locationAsync.when(
                data: (loc) => loc != null
                    ? LatLng(loc.latitude, loc.longitude)
                    : _defaultPosition,
                loading: () => _defaultPosition,
                error: (_, __) => _defaultPosition,
              ),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              // Go to user location when map is ready
              _goToMyLocation();
            },
            circles: _circles,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildLegend(),
          ),
          // Outage count
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildOutageInfo(outages),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reportOutage,
        icon: const Icon(Icons.report_problem),
        label: const Text('Report Outage'),
      ),
    );
  }

  void _updateOutageCircles(List<Outage> outages) {
    _circles.clear();
    _markers.clear();

    for (final outage in outages.where((o) => o.isActive)) {
      // Add circle for affected area
      _circles.add(
        Circle(
          circleId: CircleId(outage.id),
          center: LatLng(outage.latitude, outage.longitude),
          radius: outage.radiusKm * 1000, // Convert km to meters
          fillColor: _getSeverityColor(outage.severity).withValues(alpha: 0.3),
          strokeColor: _getSeverityColor(outage.severity),
          strokeWidth: 2,
        ),
      );

      // Add marker at center
      _markers.add(
        Marker(
          markerId: MarkerId(outage.id),
          position: LatLng(outage.latitude, outage.longitude),
          infoWindow: InfoWindow(
            title: outage.title,
            snippet: '${outage.area} - ${outage.telecomProvider}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getSeverityHue(outage.severity),
          ),
        ),
      );
    }
  }

  Color _getSeverityColor(OutageSeverity severity) {
    switch (severity) {
      case OutageSeverity.minor:
        return AppColors.warning;
      case OutageSeverity.moderate:
        return Colors.orange;
      case OutageSeverity.major:
        return AppColors.offline;
      case OutageSeverity.critical:
        return Colors.purple;
    }
  }

  double _getSeverityHue(OutageSeverity severity) {
    switch (severity) {
      case OutageSeverity.minor:
        return BitmapDescriptor.hueYellow;
      case OutageSeverity.moderate:
        return BitmapDescriptor.hueOrange;
      case OutageSeverity.major:
        return BitmapDescriptor.hueRed;
      case OutageSeverity.critical:
        return BitmapDescriptor.hueViolet;
    }
  }

  Widget _buildLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Severity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildLegendItem(AppColors.warning, 'Minor'),
            _buildLegendItem(Colors.orange, 'Moderate'),
            _buildLegendItem(AppColors.offline, 'Major'),
            _buildLegendItem(Colors.purple, 'Critical'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOutageInfo(List<Outage> outages) {
    final activeCount = outages.where((o) => o.isActive).length;

    if (activeCount == 0) {
      return Card(
        color: AppColors.online.withValues(alpha: 0.9),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'No active outages in your area',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.offline.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '$activeCount active outage${activeCount > 1 ? 's' : ''} detected',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    final location = ref.read(currentLocationProvider).valueOrNull;
    if (location != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude, location.longitude),
          14,
        ),
      );
    }
  }

  void _reportOutage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report an Outage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you experiencing a service outage? Report it to help others in your area.',
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Submit outage report via FirebaseService
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Outage reported. Thank you!'),
                      backgroundColor: AppColors.online,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.offline,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Report'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
