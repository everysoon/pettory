import 'package:flutter/material.dart';

import '../models/models.dart';

/// Temporary in-memory data source. Replace with a Supabase-backed
/// implementation once the backend is wired up.
class MockDataService {
  const MockDataService();

  List<Pet> loadPets() => [
        Pet(
          id: 'mongi',
          name: '몽이',
          species: '강아지',
          breed: '포메라니안',
          anniversary: DateTime(2025, 5, 20),
          birthday: DateTime(2024, 3, 15),
          lastCheckupDate: DateTime(2026, 4, 10),
          traits: const ['활발', '애교', '호기심'],
          color: const Color(0xFFFFC988),
        ),
        Pet(
          id: 'coco',
          name: '코코',
          species: '고양이',
          breed: '코리안숏헤어',
          anniversary: DateTime(2024, 3, 2),
          birthday: DateTime(2022, 11, 2),
          lastCheckupDate: DateTime(2026, 2, 20),
          traits: const ['도도', '느긋', '애교'],
          color: const Color(0xFFB9D8FF),
        ),
      ];

  List<DiaryEntry> loadDiaryEntries() => [
        DiaryEntry(
          id: 'd1',
          date: DateTime.now().subtract(const Duration(days: 1)),
          petIds: const ['mongi'],
          memo: '한강에서 1시간 산책! 새 친구도 만났다.',
          petComment: '오늘 진짜 신났어! 새 친구랑 뛰어노느라 힘든 줄도 몰랐다니까 🐾',
        ),
        DiaryEntry(
          id: 'd2',
          date: DateTime.now().subtract(const Duration(days: 2)),
          petIds: const ['coco'],
          memo: '오후 내내 낮잠만 잤다.',
          petComment: '햇볕이 너무 따뜻해서 눈을 뜰 수가 없었어. 세상에서 제일 편안한 낮잠이었어.',
        ),
      ];
}
