import 'dart:convert';
import 'package:notes_app/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _key = 'notes_list';

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Note.fromJson(item)).toList();
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}