import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
        frequency: json['frequency'] is int ? json['frequency'] : int.tryParse('${json['frequency'] ?? ''}'),
        durationDays: json['duration_days'] is int ? json['duration_days'] : int.tryParse('${json['duration_days'] ?? ''}'),
        timing: json['timing'],
        cautions: json['cautions'],
      );
}

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  String _apiKey = '';
  // v1 endpoint로 최신 모델 사용
  static const _model = 'gemini-1.5-flash';
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1/models';

  void init() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  }

  Future<MedicineInfo?> analyzeMedicineImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''
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

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API 오류 (${response.statusCode}): ${response.body}');
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    final text = responseJson['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null) return null;

    final jsonStr = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
    return MedicineInfo.fromJson(parsed);
  }
}
