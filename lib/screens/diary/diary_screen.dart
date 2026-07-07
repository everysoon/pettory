import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/photo_placeholder.dart';
import '../../widgets/swipe_hint_overlay.dart';
import 'diary_write_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({
    super.key,
    required this.pets,
    required this.diaryEntries,
    required this.onSaveEntry,
    required this.onDeleteEntry,
  });

  final List<Pet> pets;
  final List<DiaryEntry> diaryEntries;

  /// Called with a newly created entry, or an edited one (same id) to replace.
  final ValueChanged<DiaryEntry> onSaveEntry;

  /// Deletes an entry and returns a callback that undoes the deletion.
  final VoidCallback Function(DiaryEntry entry) onDeleteEntry;

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

enum _RangePreset { all, m1, m3, m6, y1, custom }

String _rangeLabel(_RangePreset preset) {
  switch (preset) {
    case _RangePreset.all:
      return '전체';
    case _RangePreset.m1:
      return '최근 1개월';
    case _RangePreset.m3:
      return '최근 3개월';
    case _RangePreset.m6:
      return '최근 6개월';
    case _RangePreset.y1:
      return '최근 1년';
    case _RangePreset.custom:
      return '직접 선택';
  }
}

class _DiaryScreenState extends State<DiaryScreen> {
  String? _selectedPetId;
  _RangePreset _rangePreset = _RangePreset.all;
  DateTimeRange? _customRange;

  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  bool _showSwipeHint = false;

  @override
  void initState() {
    super.initState();
    _showSwipeHint = widget.diaryEntries.isNotEmpty;
  }

  void _dismissSwipeHint() {
    setState(() => _showSwipeHint = false);
  }

  void _toggleSelecting() {
    setState(() {
      _isSelecting = !_isSelecting;
      _selectedIds.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

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
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case _RangePreset.m3:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case _RangePreset.m6:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 180)),
          end: now,
        );
      case _RangePreset.y1:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 365)),
          end: now,
        );
      case _RangePreset.custom:
        return _customRange;
    }
  }

  List<DiaryEntry> get _visibleEntries {
    var list = widget.diaryEntries;
    final petId = _selectedPetId;
    if (petId != null) {
      list = list.where((e) => e.petIds.contains(petId)).toList();
    }
    final range = _activeRange;
    if (range != null) {
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      );
      list = list
          .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
          .toList();
    }
    return list;
  }

  String get _filterSummary {
    final petLabel = _selectedPetId == null
        ? '전체'
        : widget.pets
              .firstWhere(
                (p) => p.id == _selectedPetId,
                orElse: () => widget.pets.first,
              )
              .name;
    final rangeLabel =
        _rangePreset == _RangePreset.custom && _customRange != null
        ? '${_customRange!.start.month}/${_customRange!.start.day}~${_customRange!.end.month}/${_customRange!.end.day}'
        : _rangeLabel(_rangePreset);
    return '🐾 $petLabel · $rangeLabel';
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    var tempPetId = _selectedPetId;
    var tempPreset = _rangePreset;
    var tempCustomRange = _customRange;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> pickCustom() async {
              await _pickCustomRangeInSheet(sheetContext, tempCustomRange, (
                preset,
                range,
              ) {
                setSheetState(() {
                  tempPreset = preset;
                  tempCustomRange = range;
                });
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '반려동물',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  RadioGroup<String?>(
                    groupValue: tempPetId,
                    onChanged: (v) => setSheetState(() => tempPetId = v),
                    child: Column(
                      children: [
                        const RadioListTile<String?>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text('전체'),
                          value: null,
                        ),
                        for (final pet in widget.pets)
                          RadioListTile<String?>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(pet.name),
                            value: pet.id,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '기간',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  RadioGroup<_RangePreset>(
                    groupValue: tempPreset,
                    onChanged: (v) {
                      if (v == _RangePreset.custom) {
                        pickCustom();
                      } else if (v != null) {
                        setSheetState(() => tempPreset = v);
                      }
                    },
                    child: Column(
                      children: [
                        for (final preset in [
                          _RangePreset.all,
                          _RangePreset.m1,
                          _RangePreset.m3,
                          _RangePreset.m6,
                          _RangePreset.y1,
                        ])
                          RadioListTile<_RangePreset>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(_rangeLabel(preset)),
                            value: preset,
                          ),
                        RadioListTile<_RangePreset>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            tempPreset == _RangePreset.custom &&
                                    tempCustomRange != null
                                ? '직접 선택 (${tempCustomRange!.start.month}/${tempCustomRange!.start.day}~${tempCustomRange!.end.month}/${tempCustomRange!.end.day})'
                                : '직접 선택',
                          ),
                          value: _RangePreset.custom,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPetId = tempPetId;
                          _rangePreset = tempPreset;
                          _customRange = tempCustomRange;
                        });
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('적용'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickCustomRangeInSheet(
    BuildContext context,
    DateTimeRange? initial,
    void Function(_RangePreset, DateTimeRange?) onPicked,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: initial,
    );
    if (picked != null) onPicked(_RangePreset.custom, picked);
  }

  Future<void> _openWrite(BuildContext context) async {
    final entry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(builder: (_) => DiaryWriteScreen(pets: widget.pets)),
    );
    if (entry != null) widget.onSaveEntry(entry);
  }

  Future<void> _openEdit(BuildContext context, DiaryEntry entry) async {
    final updated = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (_) =>
            DiaryWriteScreen(pets: widget.pets, initialEntry: entry),
      ),
    );
    if (updated != null) widget.onSaveEntry(updated);
  }

  void _handleDismissed(BuildContext context, DiaryEntry entry) {
    final undo = widget.onDeleteEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('일기가 삭제되었습니다.'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: '실행취소', onPressed: undo),
      ),
    );
  }

  Future<void> _openCardMenu(BuildContext context, DiaryEntry entry) async {
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
              title: const Text('일기 수정'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _openEdit(context, entry);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
              title: const Text('일기 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _handleDismissed(context, entry);
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

  Future<void> _bulkDelete(BuildContext context) async {
    if (_selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${_selectedIds.length}개의 일기를 삭제할까요?'),
        content: const Text('이 작업은 되돌릴 수 없어요.'),
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
    if (confirmed != true) return;

    final toDelete = widget.diaryEntries
        .where((e) => _selectedIds.contains(e.id))
        .toList();
    final undos = toDelete.map((e) => widget.onDeleteEntry(e)).toList();
    final count = toDelete.length;

    setState(() {
      _isSelecting = false;
      _selectedIds.clear();
    });

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count개의 일기가 삭제되었습니다.'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: '실행취소',
          onPressed: () {
            for (final undo in undos) {
              undo();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DiaryEntry entry, {
    bool isHintTarget = false,
  }) {
    final selected = _selectedIds.contains(entry.id);

    final card = AppCard(
      padding: const EdgeInsets.all(20),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isSelecting) ...[
                Checkbox(
                  value: selected,
                  onChanged: (_) => _toggleSelected(entry.id),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🐾 ${_petNames(entry.petIds)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.date.year}.${entry.date.month.toString().padLeft(2, '0')}.${entry.date.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isSelecting)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openCardMenu(context, entry),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
          if (entry.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.photoPaths.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) => PhotoPlaceholder(
                  imagePath: entry.photoPaths[index],
                  size: 82,
                  borderRadius: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(entry.memo),
          if (entry.petComment != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(
                    color: AppColors.primaryDark.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🐾 ${_petNames(entry.petIds)}가 말했어요',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.petComment!,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (_isSelecting) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleSelected(entry.id),
        child: card,
      );
    }

    final background = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );

    if (isHintTarget) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SwipeHintBubble(),
          ),
          SwipeHintCard(
            key: ValueKey(entry.id),
            background: background,
            onFinished: _dismissSwipeHint,
            child: card,
          ),
        ],
      );
    }

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _handleDismissed(context, entry),
      background: background,
      child: card,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _visibleEntries;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelecting ? '${_selectedIds.length}개 선택' : '다이어리'),
        actions: [
          if (_isSelecting) ...[
            IconButton(
              onPressed: _selectedIds.isEmpty
                  ? null
                  : () => _bulkDelete(context),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            TextButton(onPressed: _toggleSelecting, child: const Text('취소')),
          ] else if (widget.diaryEntries.isNotEmpty)
            TextButton(onPressed: _toggleSelecting, child: const Text('편집')),
        ],
      ),
      floatingActionButton: _isSelecting
          ? null
          : FloatingActionButton(
              onPressed: () => _openWrite(context),
              backgroundColor: AppColors.textDark,
              tooltip: '일기 쓰기',
              child: const Icon(Icons.edit_rounded, color: Colors.white),
            ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              height: 60,
              child: Container(
                color: AppColors.cream,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openFilterSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _filterSummary,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.expand_more_rounded,
                          size: 18,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🐾', style: TextStyle(fontSize: 32)),
                      const SizedBox(height: 12),
                      const Text(
                        '아직 이 기간에는 추억이 없어요.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '새로운 추억을 남겨볼까요?',
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  if (i.isOdd) return const SizedBox(height: 16);
                  final index = i ~/ 2;
                  final entry = entries[index];
                  final isHintTarget =
                      !_isSelecting && _showSwipeHint && index == 0;
                  return _buildCard(context, entry, isHintTarget: isHintTarget);
                }, childCount: entries.length * 2 - 1),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => true;
}
