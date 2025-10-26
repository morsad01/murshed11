import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../vehicle/vehicle_details_screen.dart';

class CarBuySellScreen extends StatefulWidget {
  const CarBuySellScreen({super.key});

  @override
  State<CarBuySellScreen> createState() => _CarBuySellScreenState();
}

class _CarBuySellScreenState extends State<CarBuySellScreen> {
  List<VehicleModel> _vehicles = [];
  bool _isLoading = true;

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
          .eq('listing_type', 'sell')
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Cars'),
        actions: [
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
              decoration: const InputDecoration(
                hintText: 'Search cars...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _vehicles.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.car_rental, size: 64, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text(
                              'No cars for sale',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = _vehicles[index];
                          return _buildVehicleCard(vehicle);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: vehicle.photoUrls.isNotEmpty
                    ? Image.network(
                        vehicle.photoUrls.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.border,
                          child: const Icon(Icons.directions_car, size: 48),
                        ),
                      )
                    : Container(
                        color: AppColors.border,
                        child: const Icon(Icons.directions_car, size: 48),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${vehicle.salePrice?.toStringAsFixed(0) ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          vehicle.locationAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
