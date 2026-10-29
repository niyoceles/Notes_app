import 'dart:convert';

class Note {
  final String id;
  String title;
  String body;
  DateTime date;

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        date: DateTime.parse(json['date']),
      );
}