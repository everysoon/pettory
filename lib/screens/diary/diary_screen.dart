import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/photo_placeholder.dart';
import 'diary_write_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.pets,
    required this.diaryEntries,
    required this.onSaveEntry,
  });

  final List<Pet> pets;
  final List<DiaryEntry> diaryEntries;

  /// Called with a newly created entry, or an edited one (same id) to replace.
  final ValueChanged<DiaryEntry> onSaveEntry;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

enum _RangePreset { all, m1, m3, m6, y1, custom }

class _DiaryScreenState extends State<DiaryScreen> {
  String? _selectedPetId;
  _RangePreset _rangePreset = _RangePreset.all;
  DateTimeRange? _customRange;

  String _petNames(List<String> ids) => widget.pets
      .where((p) => ids.contains(p.id))
      .map((p) => p.name)
      .join(', ');

  DateTimeRange? get _activeRange {
    final now = DateTime.now();
    switch (_rangePreset) {
      case _RangePreset.all:
        return null;
      case _RangePreset.m1:
        return DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
      case _RangePreset.m3:
        return DateTimeRange(start: now.subtract(const Duration(days: 90)), end: now);
      case _RangePreset.m6:
        return DateTimeRange(start: now.subtract(const Duration(days: 180)), end: now);
      case _RangePreset.y1:
        return DateTimeRange(start: now.subtract(const Duration(days: 365)), end: now);
      case _RangePreset.custom:
        return _customRange;
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _customRange,
    );
    if (picked == null) return;
    setState(() {
      _rangePreset = _RangePreset.custom;
      _customRange = picked;
    });
  }

  List<DiaryEntry> get _visibleEntries {
    var list = widget.diaryEntries;
    final petId = _selectedPetId;
    if (petId != null) {
      list = list.where((e) => e.petIds.contains(petId)).toList();
    }
    final range = _activeRange;
    if (range != null) {
      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      list = list.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
    }
    return list;
  }

  Future<void> _openWrite(BuildContext context) async {
    final entry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(builder: (_) => DiaryWriteScreen(pets: widget.pets)),
    );
    if (entry != null) widget.onSaveEntry(entry);
  }

  Future<void> _openEdit(BuildContext context, DiaryEntry entry) async {
    final updated = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(builder: (_) => DiaryWriteScreen(pets: widget.pets, initialEntry: entry)),
    );
    if (updated != null) widget.onSaveEntry(updated);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;

    return Scaffold(
      appBar: AppBar(title: const Text('다이어리')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWrite(context),
        backgroundColor: AppColors.textDark,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('일기 쓰기', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          if (widget.pets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.pets.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ChoiceChip(
                        label: const Text('전체'),
                        selected: _selectedPetId == null,
                        onSelected: (_) => setState(() => _selectedPetId = null),
                      );
                    }
                    final pet = widget.pets[index - 1];
                    return ChoiceChip(
                      label: Text(pet.name),
                      selected: _selectedPetId == pet.id,
                      onSelected: (_) => setState(() => _selectedPetId = pet.id),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('전체'),
                    selected: _rangePreset == _RangePreset.all,
                    onSelected: (_) => setState(() => _rangePreset = _RangePreset.all),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('1개월'),
                    selected: _rangePreset == _RangePreset.m1,
                    onSelected: (_) => setState(() => _rangePreset = _RangePreset.m1),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('3개월'),
                    selected: _rangePreset == _RangePreset.m3,
                    onSelected: (_) => setState(() => _rangePreset = _RangePreset.m3),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('6개월'),
                    selected: _rangePreset == _RangePreset.m6,
                    onSelected: (_) => setState(() => _rangePreset = _RangePreset.m6),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('1년'),
                    selected: _rangePreset == _RangePreset.y1,
                    onSelected: (_) => setState(() => _rangePreset = _RangePreset.y1),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(
                      _rangePreset == _RangePreset.custom && _customRange != null
                          ? '${_customRange!.start.month}/${_customRange!.start.day}~${_customRange!.end.month}/${_customRange!.end.day}'
                          : '기간 설정',
                    ),
                    selected: _rangePreset == _RangePreset.custom,
                    onSelected: (_) => _pickCustomRange(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(
                    child: Text(
                      '아직 다른 날의 기록이 없어요',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${entry.date.year}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _petNames(entry.petIds),
                                    style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _openEdit(context, entry),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.edit_outlined, size: 18, color: Colors.black45),
                                  ),
                                ),
                              ],
                            ),
                            if (entry.photoPaths.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 64,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: entry.photoPaths.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                                  itemBuilder: (context, index) => PhotoPlaceholder(
                                    imagePath: entry.photoPaths[index],
                                    size: 64,
                                    borderRadius: 10,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(entry.memo),
                            if (entry.petComment != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('🐾', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(entry.petComment!, style: const TextStyle(fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
