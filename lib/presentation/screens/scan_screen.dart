import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/api/gemini_service.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await GeminiService().analyzeMedicineImage(File(image.path));
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('약 정보를 인식하지 못했습니다. 다시 시도해주세요.')),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(medicineInfo: result)),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 스캔'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2e7d32)),
                  SizedBox(height: 20),
                  Text('AI가 약 정보를 분석 중...', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('잠시만 기다려주세요', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.medication, size: 80, color: Color(0xFF4CAF50)),
                  const SizedBox(height: 24),
                  const Text(
                    '약 포장지를 촬영하거나\n갤러리에서 사진을 선택하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: () => _pickAndAnalyze(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라로 촬영'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2e7d32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _pickAndAnalyze(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2e7d32),
                      side: const BorderSide(color: Color(0xFF2e7d32)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
