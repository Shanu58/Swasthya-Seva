import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_buttons.dart';
import '../medicine/identification_screen.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  bool _isProcessing = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _error = null);
    try {
      final XFile? file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      setState(() => _pickedImage = File(file.path));
      await _submit();
    } catch (e) {
      setState(() => _error = 'Could not access camera/gallery. Please check app permissions.');
    }
  }

  Future<void> _submit() async {
    if (_pickedImage == null) return;
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final medicine =
          await ref.read(identifyMedicineProvider(_pickedImage!).future);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => IdentificationScreen(medicine: medicine)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Medicine')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isProcessing
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Reading strip and verifying...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : _pickedImage != null
                          ? Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity)
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medication_rounded, color: Colors.white54, size: 64),
                                  SizedBox(height: 12),
                                  Text(
                                    'Position the medicine strip\nclearly in frame',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.dangerRed)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PrimaryActionButton(
                      label: 'Open Camera',
                      icon: Icons.camera_alt_rounded,
                      isLoading: _isProcessing,
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryActionButton(
                      label: 'Upload from Gallery',
                      icon: Icons.photo_library_outlined,
                      onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
