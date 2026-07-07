import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/pet_avatar.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.pet, required this.diaryEntries});

  final Pet pet;
  final List<DiaryEntry> diaryEntries;

  @override
  Widget build(BuildContext context) {
    final photoPaths = diaryEntries
        .where((e) => e.petIds.contains(pet.id))
        .expand((e) => e.photoPaths)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(pet.name)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  PetAvatar(color: pet.color, imagePath: pet.photoPath, radius: 44, emojiSize: 34),
                  const SizedBox(height: 12),
                  Text(pet.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.breed} · 함께한 지 ${pet.daysTogether}일',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: pet.traits
                        .map((t) => Chip(
                              label: Text('#$t'),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: Colors.black45,
              indicatorColor: AppColors.primaryDark,
              tabs: [Tab(text: '갤러리'), Tab(text: '정보')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _GalleryTab(photoPaths: photoPaths),
                  _InfoTab(pet: pet),
                ],
              ),
            ),
          ],
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
    final totalCount = photoPaths.length < _minSlots ? _minSlots : photoPaths.length;

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

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.pet});

  final Pet pet;

  static String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoRow(label: '종류', value: pet.species),
        _InfoRow(label: '품종', value: pet.breed),
        _InfoRow(label: '함께한 날', value: _formatDate(pet.anniversary)),
        if (pet.birthday != null)
          _InfoRow(label: '생일', value: _formatDate(pet.birthday!)),
        if (pet.lastCheckupDate != null)
          _InfoRow(label: '건강검진날', value: _formatDate(pet.lastCheckupDate!)),
        _InfoRow(label: '성격 태그', value: pet.traits.join(', ')),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
