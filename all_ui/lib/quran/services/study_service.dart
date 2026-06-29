import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/surah.dart';

class StudyService {
  static const String _annotationsKey = 'study_annotations';

  Future<List<Tafsir>> getTafsir(int surahNumber, int ayahNumber) async {
    try {
      final List<Tafsir> tafsirs = [];

      try {
        final response = await http.get(
          Uri.parse(
            'https://api.quran.com/api/v4/quran/tafsirs/169?verse_key=$surahNumber:$ayahNumber',
          ),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['tafsirs'] != null && (data['tafsirs'] as List).isNotEmpty) {
            tafsirs.add(
              Tafsir(
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                source: 'Tafsir al-Jalalayn',
                text: data['tafsirs'][0]['text'] ?? '',
                language: 'en',
              ),
            );
          }
        }
      } catch (e) {
        // Continue
      }

      return tafsirs;
    } catch (e) {
      return [];
    }
  }

  Future<List<Annotation>> getAnnotations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? annotationsJson = prefs.getString(_annotationsKey);
    if (annotationsJson == null) return [];

    final List decoded = json.decode(annotationsJson);
    return decoded.map((a) => Annotation.fromJson(a)).toList();
  }

  Future<void> addAnnotation(Annotation annotation) async {
    final annotations = await getAnnotations();
    annotations.add(annotation);
    await _saveAnnotations(annotations);
  }

  Future<void> updateAnnotation(Annotation annotation) async {
    final annotations = await getAnnotations();
    final index = annotations.indexWhere((a) => a.id == annotation.id);
    if (index != -1) {
      annotations[index] = annotation;
      await _saveAnnotations(annotations);
    }
  }

  Future<void> deleteAnnotation(String id) async {
    final annotations = await getAnnotations();
    annotations.removeWhere((a) => a.id == id);
    await _saveAnnotations(annotations);
  }

  Future<List<Annotation>> getAnnotationsForAyah(
    int surahNumber,
    int ayahNumber,
  ) async {
    final annotations = await getAnnotations();
    return annotations
        .where(
          (a) => a.surahNumber == surahNumber && a.ayahNumber == ayahNumber,
        )
        .toList();
  }

  Future<void> _saveAnnotations(List<Annotation> annotations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _annotationsKey,
      json.encode(annotations.map((a) => a.toJson()).toList()),
    );
  }

  Future<String> exportAnnotations() async {
    final annotations = await getAnnotations();
    final buffer = StringBuffer();

    buffer.writeln('# My Quran Study Notes');
    buffer.writeln('Exported on: ${DateTime.now()}');
    buffer.writeln('');

    for (var annotation in annotations) {
      buffer.writeln('## ${annotation.surahNumber}:${annotation.ayahNumber}');
      buffer.writeln(annotation.text);
      if (annotation.tags.isNotEmpty) {
        buffer.writeln('Tags: ${annotation.tags.join(", ")}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
