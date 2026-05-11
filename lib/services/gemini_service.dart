import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MedicineInfo {
  final String name;
  final String? dosage;
  final int? frequency;
  final int? durationDays;
  final String? timing;
  final String? cautions;

  MedicineInfo({
    required this.name,
    this.dosage,
    this.frequency,
    this.durationDays,
    this.timing,
    this.cautions,
  });

  factory MedicineInfo.fromJson(Map<String, dynamic> json) => MedicineInfo(
        name: json['name'] ?? '알 수 없음',
        dosage: json['dosage'],
        frequency: json['frequency'],
        durationDays: json['duration_days'],
        timing: json['timing'],
        cautions: json['cautions'],
      );
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;

  void init() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<MedicineInfo?> analyzeMedicineImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final prompt = '''
당신은 약학 전문가입니다.
첨부된 약 포장지 이미지를 분석하여 아래 JSON 형식으로 정보를 추출하세요.
이미지에서 확인할 수 없는 항목은 null로 반환하세요.

{
  "name": "약 이름",
  "dosage": "1회 복용량 (예: 500mg, 1정)",
  "frequency": 1일 복용 횟수 (숫자),
  "duration_days": 복용 기간 (숫자, 일 단위, 없으면 null),
  "timing": "복용 시점 (예: 식후 30분, 취침 전)",
  "cautions": "주요 주의사항 3줄 이내 요약"
}

JSON 형식 외 다른 텍스트는 출력하지 마세요.
''';

    final response = await _model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ]),
    ]);

    final text = response.text;
    if (text == null) return null;

    final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return MedicineInfo.fromJson(json);
  }
}
