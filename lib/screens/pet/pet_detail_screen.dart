import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/pet_avatar.dart';
import '../memory_book/memory_book_list_screen.dart';
import 'family_management_tab.dart';
import 'pet_form_screen.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({
    super.key,
    required this.pet,
    required this.diaryEntries,
    required this.onEditPet,
    required this.onDeletePet,
  });

  final Pet pet;
  final List<DiaryEntry> diaryEntries;
  final ValueChanged<Pet> onEditPet;

  /// Deletes [pet] and returns a callback that undoes the deletion.
  final VoidCallback Function(Pet pet) onDeletePet;

  static String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  Future<void> _openEdit(BuildContext context) async {
    final updated = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => PetFormScreen(initialPet: pet)),
    );
    if (updated != null) onEditPet(updated);
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${pet.name} 삭제할까요?'),
        content: const Text('반려동물을 삭제하면 관련된 일기도 함께 삭제돼요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _openMoreSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('프로필 수정'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openEdit(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded),
              title: const Text('가족 관리'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                DefaultTabController.of(context).animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: Text(
                '${pet.name} 삭제',
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final confirmed = await _confirmDelete(context);
                if (!confirmed || !context.mounted) return;
                final messenger = ScaffoldMessenger.of(context);
                final undo = onDeletePet(pet);
                Navigator.of(context).pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('${pet.name} 프로필이 삭제되었습니다.'),
                    duration: const Duration(seconds: 10),
                    action: SnackBarAction(label: '실행취소', onPressed: undo),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Center(child: Text('취소')),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoPaths = diaryEntries
        .where((e) => e.petIds.contains(pet.id))
        .expand((e) => e.photoPaths)
        .toList();

    const tabBar = TabBar(
      labelColor: AppColors.primaryDark,
      unselectedLabelColor: Colors.black45,
      indicatorColor: AppColors.primaryDark,
      tabs: [
        Tab(text: '갤러리'),
        Tab(text: '요약'),
        Tab(text: '가족 관리'),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(pet.name),
            actions: [
              IconButton(
                onPressed: () => _openMoreSheet(context),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          body: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    children: [
                      PetAvatar(
                        color: pet.color,
                        imagePath: pet.photoPath,
                        radius: 44,
                        emojiSize: 34,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.breed} · 함께한 지 ${pet.daysTogether}일',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        children: pet.traits
                            .map(
                              (t) => Chip(
                                label: Text('#$t'),
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(label: '종류', value: pet.species),
                            _InfoRow(label: '품종', value: pet.breed),
                            _InfoRow(
                              label: '함께한 날',
                              value: _formatDate(pet.anniversary),
                            ),
                            if (pet.birthday != null)
                              _InfoRow(
                                label: '생일',
                                value: _formatDate(pet.birthday!),
                              ),
                            if (pet.lastCheckupDate != null)
                              _InfoRow(
                                label: '건강검진날',
                                value: _formatDate(pet.lastCheckupDate!),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MemoryBookListScreen(),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Text('📖', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  '추억북 보러가기',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              tabBar,
              Expanded(
                child: TabBarView(
                  children: [
                    _GalleryTab(photoPaths: photoPaths),
                    _SummaryTab(pet: pet),
                    FamilyManagementTab(pet: pet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab({required this.photoPaths});

  final List<String> photoPaths;

  static const _minSlots = 9;

  @override
  Widget build(BuildContext context) {
    final totalCount = photoPaths.length < _minSlots
        ? _minSlots
        : photoPaths.length;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < photoPaths.length) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(File(photoPaths[index]), fit: BoxFit.cover),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${pet.name}의 주간/월간 요약이\n곧 준비될 예정이에요 🐾',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black45),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
