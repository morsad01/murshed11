import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_colors.dart';
import '../home/home_screen.dart';

class KYCVerificationScreen extends StatefulWidget {
  final String userId;

  const KYCVerificationScreen({super.key, required this.userId});

  @override
  State<KYCVerificationScreen> createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  File? _nidImage;
  File? _licenseImage;
  bool _isUploading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(bool isNid) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isNid) {
            _nidImage = File(pickedFile.path);
          } else {
            _licenseImage = File(pickedFile.path);
          }
        });
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_nidImage == null || _licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both NID and License'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final nidPath = 'kyc/${widget.userId}/nid_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final licensePath = 'kyc/${widget.userId}/license_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('documents')
          .upload(nidPath, _nidImage!);

      await Supabase.instance.client.storage
          .from('documents')
          .upload(licensePath, _licenseImage!);

      final nidUrl = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(nidPath);

      final licenseUrl = Supabase.instance.client.storage
          .from('documents')
          .getPublicUrl(licensePath);

      await Supabase.instance.client.from('users').update({
        'nid_card_url': nidUrl,
        'license_url': licenseUrl,
        'kyc_status': 'pending',
        'nid_number': 'NID-${DateTime.now().millisecondsSinceEpoch}',
        'license_number': 'LIC-${DateTime.now().millisecondsSinceEpoch}',
      }).eq('id', widget.userId);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading documents: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verify Your Identity',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload your documents to complete verification',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildUploadCard(
              title: 'National ID Card',
              subtitle: 'Upload clear photo of your NID',
              image: _nidImage,
              onTap: () => _pickImage(true),
            ),
            const SizedBox(height: 20),
            _buildUploadCard(
              title: 'Driving License',
              subtitle: 'Upload clear photo of your license',
              image: _licenseImage,
              onTap: () => _pickImage(false),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitVerification,
              child: _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit for Verification'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    image == null ? Icons.upload_file : Icons.check_circle,
                    color: image == null ? AppColors.textSecondary : AppColors.success,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (image != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
