import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_colors.dart';
import '../../models/vehicle_model.dart';

class BookingScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const BookingScreen({super.key, required this.vehicle});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _bookingType = 'hourly';
  int _duration = 1;
  bool _addInsurance = false;
  String _paymentMethod = 'bkash';
  bool _isBooking = false;

  double get _baseAmount {
    if (_bookingType == 'hourly') {
      return (widget.vehicle.hourlyRate ?? 0) * _duration;
    } else {
      return (widget.vehicle.dailyRate ?? 0) * _duration;
    }
  }

  double get _insuranceAmount {
    return _addInsurance ? _baseAmount * (widget.vehicle.insuranceRate / 100) : 0;
  }

  double get _totalAmount {
    return _baseAmount + _insuranceAmount;
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final endTime = _bookingType == 'hourly'
          ? now.add(Duration(hours: _duration))
          : now.add(Duration(days: _duration));

      await Supabase.instance.client.from('bookings').insert({
        'vehicle_id': widget.vehicle.id,
        'renter_id': user.id,
        'owner_id': widget.vehicle.ownerId,
        'booking_type': _bookingType,
        'start_time': now.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'duration_hours': _bookingType == 'hourly' ? _duration : _duration * 24,
        'base_amount': _baseAmount,
        'insurance_added': _addInsurance,
        'insurance_amount': _insuranceAmount,
        'total_amount': _totalAmount,
        'payment_method': _paymentMethod,
        'payment_status': 'completed',
        'booking_status': 'active',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Vehicle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.vehicle.photoUrls.isNotEmpty
                          ? Image.network(
                              widget.vehicle.photoUrls.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: AppColors.border,
                              child: const Icon(Icons.directions_car),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.vehicle.brand} ${widget.vehicle.model}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${widget.vehicle.rating.toStringAsFixed(1)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Duration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDurationTypeButton('Hourly', 'hourly'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDurationTypeButton('Daily', 'daily'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_duration > 1) {
                      setState(() => _duration--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Text(
                    '$_duration ${_bookingType == 'hourly' ? 'Hours' : 'Days'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _duration++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (widget.vehicle.insuranceAvailable) ...[
              Card(
                child: SwitchListTile(
                  title: const Text('Add Insurance'),
                  subtitle: Text('${widget.vehicle.insuranceRate}% of base amount'),
                  value: _addInsurance,
                  onChanged: (value) {
                    setState(() => _addInsurance = value);
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodButton('bKash', 'bkash'),
            const SizedBox(height: 12),
            _buildPaymentMethodButton('Nagad', 'nagad'),
            const SizedBox(height: 12),
            _buildPaymentMethodButton('Wallet', 'wallet'),
            const SizedBox(height: 24),
            Card(
              color: AppColors.primary.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildAmountRow('Base Amount', _baseAmount),
                    if (_addInsurance) ...[
                      const SizedBox(height: 8),
                      _buildAmountRow('Insurance Fee', _insuranceAmount),
                    ],
                    const Divider(height: 24),
                    _buildAmountRow('Total Amount', _totalAmount, isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTypeButton(String label, String value) {
    final isSelected = _bookingType == value;
    return OutlinedButton(
      onPressed: () {
        setState(() => _bookingType = value);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : null,
        foregroundColor: isSelected ? Colors.white : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label),
    );
  }

  Widget _buildPaymentMethodButton(String label, String value) {
    final isSelected = _paymentMethod == value;
    return OutlinedButton(
      onPressed: () {
        setState(() => _paymentMethod = value);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
