import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/pet_avatar.dart';
import '../../widgets/section_title.dart';
import '../diary/diary_viewer_screen.dart';
import '../pet/pet_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.pets,
    required this.diaryEntries,
    required this.onWriteDiary,
    required this.onOpenPets,
    required this.onAddPet,
  });

  final List<Pet> pets;
  final List<DiaryEntry> diaryEntries;
  final VoidCallback onWriteDiary;
  final VoidCallback onOpenPets;
  final ValueChanged<Pet> onAddPet;

  Future<void> _openAddPet(BuildContext context) async {
    final pet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => const PetFormScreen()),
    );
    if (pet != null) onAddPet(pet);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _hasTodayEntry =>
      diaryEntries.any((e) => _isSameDay(e.date, DateTime.now()));

  String _petNames(List<String> ids) => pets
      .where((p) => ids.contains(p.id))
      .map((p) => p.name)
      .join(', ');

  @override
  Widget build(BuildContext context) {
    final recent = diaryEntries.take(5).toList();
    final now = DateTime.now();
    final yearAgoEntries = diaryEntries
        .where((e) =>
            e.date.year == now.year - 1 &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '안녕, 보호자님 👋',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Icon(Icons.notifications_none_rounded, color: AppColors.textDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pets.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == pets.length) {
                  return GestureDetector(
                    onTap: () => _openAddPet(context),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.cardBorder, width: 1.5),
                          ),
                          child: const Icon(Icons.add, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 6),
                        const Text('추가', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                }
                final pet = pets[index];
                return GestureDetector(
                  onTap: onOpenPets,
                  child: Column(
                    children: [
                      PetAvatar(color: pet.color, imagePath: pet.photoPath),
                      const SizedBox(height: 6),
                      Text(pet.name, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('오늘의 한 컷'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onWriteDiary,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasTodayEntry ? '오늘의 카드가 저장되었어요' : '오늘의 카드 만들기',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasTodayEntry ? '내일 다시 새로운 순간을 남겨보세요' : '사진을 올리고 추억을 남겨보세요',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _hasTodayEntry ? Icons.check_rounded : Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionTitle('최근 일기'),
              TextButton(onPressed: onWriteDiary, child: const Text('더보기')),
            ],
          ),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('아직 작성된 일기가 없어요', style: TextStyle(color: Colors.black45)),
            )
          else
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final entry = recent[index];
                  final hasPhoto = entry.photoPaths.isNotEmpty;
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiaryViewerScreen(entry: entry, pets: pets),
                      ),
                    ),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.date.month}/${entry.date.day}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.black38),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _petNames(entry.petIds),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 6),
                          if (hasPhoto) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(entry.photoPaths.first),
                                width: double.infinity,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Expanded(
                            child: Text(
                              entry.memo,
                              maxLines: hasPhoto ? 2 : 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (yearAgoEntries.isNotEmpty) ...[
            const SizedBox(height: 28),
            const SectionTitle('1년 전 오늘'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '작년 오늘, ${_petNames(yearAgoEntries.first.petIds)}와의 기록',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
