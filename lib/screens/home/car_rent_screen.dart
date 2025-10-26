import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../vehicle/vehicle_details_screen.dart';

class CarRentScreen extends StatefulWidget {
  const CarRentScreen({super.key});

  @override
  State<CarRentScreen> createState() => _CarRentScreenState();
}

class _CarRentScreenState extends State<CarRentScreen> {
  GoogleMapController? _mapController;
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;
  bool _showMap = true;

  final LatLng _initialPosition = const LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('vehicles')
          .select('''
            *,
            vehicle_photos(photo_url, order_index),
            users!vehicles_owner_id_fkey(full_name, rating)
          ''')
          .eq('type', 'car')
          .eq('listing_type', 'rent')
          .eq('is_available', true)
          .order('created_at', ascending: false);

      final vehicles = (response as List).map((json) {
        final vehicleData = Map<String, dynamic>.from(json);

        if (vehicleData['vehicle_photos'] != null) {
          final photos = vehicleData['vehicle_photos'] as List;
          vehicleData['photo_urls'] = photos.map((p) => p['photo_url']).toList();
        }

        if (vehicleData['users'] != null) {
          final owner = vehicleData['users'];
          vehicleData['owner_name'] = owner['full_name'];
          vehicleData['owner_rating'] = owner['rating'];
        }

        return VehicleModel.fromJson(vehicleData);
      }).toList();

      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading vehicles: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rent'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMap
                    ? _buildMapView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final markers = _vehicles.map((vehicle) {
      return Marker(
        markerId: MarkerId(vehicle.id),
        position: LatLng(vehicle.locationLat, vehicle.locationLng),
        onTap: () {
          _showVehicleBottomSheet(vehicle);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 12,
          ),
          markers: markers,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                return _buildVehicleCard(_vehicles[index], isHorizontal: true);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_vehicles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_rental, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No cars available for rent',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        return _buildVehicleCard(_vehicles[index]);
      },
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle, {bool isHorizontal = false}) {
    return Card(
      margin: isHorizontal
          ? const EdgeInsets.only(right: 12)
          : const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: isHorizontal ? 300 : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: vehicle.photoUrls.isNotEmpty
                    ? Image.network(
                        vehicle.photoUrls.first,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: AppColors.border,
                          child: const Icon(Icons.directions_car, size: 48),
                        ),
                      )
                    : Container(
                        height: 150,
                        color: AppColors.border,
                        child: const Icon(Icons.directions_car, size: 48),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.rating.toStringAsFixed(1)} (${vehicle.totalBookings} trips)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (vehicle.hourlyRate != null) ...[
                              Text(
                                '৳${vehicle.hourlyRate!.toStringAsFixed(0)}/hr',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            if (vehicle.dailyRate != null) ...[
                              Text(
                                '৳${vehicle.dailyRate!.toStringAsFixed(0)}/day',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (vehicle.insuranceAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Insurance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVehicleBottomSheet(VehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${vehicle.brand} ${vehicle.model}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '৳${vehicle.hourlyRate}/hr • ৳${vehicle.dailyRate}/day',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                  ),
                );
              },
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
