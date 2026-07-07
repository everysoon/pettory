import 'package:flutter/material.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.anniversary,
    required this.traits,
    required this.color,
    this.photoPath,
    this.birthday,
    this.lastCheckupDate,
  });

  final String id;
  final String name;
  final String species; // '강아지' | '고양이' | 직접입력 값
  final String breed;
  final DateTime anniversary;
  final List<String> traits;
  final Color color;
  final String? photoPath;
  final DateTime? birthday;
  final DateTime? lastCheckupDate;

  int get daysTogether => DateTime.now().difference(anniversary).inDays + 1;
}
