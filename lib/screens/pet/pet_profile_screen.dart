import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/pet_avatar.dart';
import 'pet_detail_screen.dart';
import 'pet_form_screen.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({
    super.key,
    required this.pets,
    required this.diaryEntries,
    required this.onAddPet,
    required this.onDeletePet,
    this.showSwipeHint = false,
    this.onSwipeHintShown,
  });

  final List<Pet> pets;
  final List<DiaryEntry> diaryEntries;
  final ValueChanged<Pet> onAddPet;

  /// Deletes [pet] and returns a callback that undoes the deletion.
  final VoidCallback Function(Pet pet) onDeletePet;

  /// Whether to show the one-time "swipe to delete" onboarding hint.
  final bool showSwipeHint;
  final VoidCallback? onSwipeHintShown;

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _hintController;
  late final Animation<double> _hintOffset;

  @override
  void initState() {
    super.initState();
    _hintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _hintOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -16.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -16.0, end: 4.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 1),
    ]).animate(_hintController);

    if (widget.showSwipeHint && widget.pets.isNotEmpty) {
      _playHintAnimation();
    }
  }

  Future<void> _playHintAnimation() async {
    for (var i = 0; i < 2 && mounted; i++) {
      await _hintController.forward(from: 0);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onSwipeHintShown?.call();
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _openAdd(BuildContext context) async {
    final pet = await Navigator.of(context).push<Pet>(
      MaterialPageRoute(builder: (_) => const PetFormScreen()),
    );
    if (pet != null) widget.onAddPet(pet);
  }

  Future<bool> _confirmDelete(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pet.name} 삭제할까요?'),
        content: const Text('반려동물을 삭제하면 관련된 일기도 함께 삭제돼요.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _handleDismissed(BuildContext context, Pet pet) {
    final undo = widget.onDeletePet(pet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('펫 프로필이 삭제되었습니다.'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: '실행취소', onPressed: undo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pets = widget.pets;
    final showHint = widget.showSwipeHint && pets.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('펫 프로필'),
        actions: [
          IconButton(
            onPressed: () => _openAdd(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('등록된 반려동물이 없어요'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _openAdd(context),
                    child: const Text('반려동물 등록하기'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (showHint)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.textDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '← 밀어서 삭제',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: pets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      final tile = Dismissible(
                        key: ValueKey(pet.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _confirmDelete(context, pet),
                        onDismissed: (_) => _handleDismissed(context, pet),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PetDetailScreen(pet: pet, diaryEntries: widget.diaryEntries),
                            ),
                          ),
                          child: AppCard(
                            child: Row(
                              children: [
                                PetAvatar(color: pet.color, imagePath: pet.photoPath, radius: 32, emojiSize: 26),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${pet.breed} · 함께한 지 ${pet.daysTogether}일',
                                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        children: pet.traits
                                            .map((t) => Text(
                                                  '#$t',
                                                  style: const TextStyle(
                                                    color: AppColors.primaryDark,
                                                    fontSize: 12,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                      );

                      if (index != 0 || !showHint) return tile;

                      return AnimatedBuilder(
                        animation: _hintOffset,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(_hintOffset.value, 0),
                          child: child,
                        ),
                        child: tile,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
