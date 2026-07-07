import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';

class DiaryViewerScreen extends StatefulWidget {
  const DiaryViewerScreen({super.key, required this.entry, required this.pets});

  final DiaryEntry entry;
  final List<Pet> pets;

  @override
  State<DiaryViewerScreen> createState() => _DiaryViewerScreenState();
}

class _DiaryViewerScreenState extends State<DiaryViewerScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _petNames => widget.pets
      .where((p) => widget.entry.petIds.contains(p.id))
      .map((p) => p.name)
      .join(', ');

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final photos = entry.photoPaths;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${entry.date.year}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.day.toString().padLeft(2, '0')}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (photos.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: photos.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) => Image.file(
                    File(photos[index]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            if (photos.length > 1) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 8 : 6,
                    height: i == _page ? 8 : 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? AppColors.primaryDark : AppColors.cardBorder,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          Text(
            _petNames,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(entry.memo, style: const TextStyle(fontSize: 15, height: 1.5)),
          if (entry.petComment != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.petComment!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
