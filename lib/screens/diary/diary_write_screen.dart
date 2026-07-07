import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/photo_service.dart';
import '../../theme.dart';
import '../../widgets/photo_placeholder.dart';
import '../../widgets/section_title.dart';

class DiaryWriteScreen extends StatefulWidget {
  const DiaryWriteScreen({
    super.key,
    required this.pets,
    this.photoService = const LocalPhotoService(),
    this.initialEntry,
  });

  final List<Pet> pets;
  final PhotoService photoService;

  /// When set, the screen edits this entry in place instead of creating a new one.
  final DiaryEntry? initialEntry;

  @override
  State<DiaryWriteScreen> createState() => _DiaryWriteScreenState();
}

class _DiaryWriteScreenState extends State<DiaryWriteScreen> {
  late final _memoController = TextEditingController(text: widget.initialEntry?.memo ?? '');
  late final Set<String> _selectedPetIds = {...?widget.initialEntry?.petIds};
  late final DateTime _date = widget.initialEntry?.date ?? DateTime.now();
  late final List<String> _photoPaths = List.of(widget.initialEntry?.photoPaths ?? const []);

  bool get _isEditing => widget.initialEntry != null;

  static const _petCommentTemplates = [
    '오늘 진짜 신났어! 이 순간 절대 잊지 못할 거야 🐾',
    '집사랑 함께한 오늘, 세상에서 제일 행복한 하루였어!',
    '헤헤, 오늘도 나 예뻤지? 내일도 같이 놀아줘!',
    '이 순간을 남겨줘서 고마워. 다음에도 또 기록해줘!',
    '오늘 하루도 집사 덕분에 꼬리가 멈추질 않았어 🐾',
  ];

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    if (_selectedPetIds.isEmpty && widget.pets.isNotEmpty) {
      _selectedPetIds.add(widget.pets.first.id);
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  bool get _canUpload =>
      _selectedPetIds.isNotEmpty && _memoController.text.trim().isNotEmpty;

  Future<void> _addPhoto() async {
    if (_photoPaths.length >= 5) return;
    final picked = await widget.photoService.pickFromLibrary();
    if (picked == null) return;
    final saved = await widget.photoService.save(picked);
    if (!mounted) return;
    setState(() => _photoPaths.add(saved));
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  Future<void> _upload() async {
    setState(() => _uploading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final random = Random();
    final entry = DiaryEntry(
      id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: _date,
      petIds: _selectedPetIds.toList(),
      memo: _memoController.text.trim(),
      photoPaths: _photoPaths,
      petComment: widget.initialEntry?.petComment ??
          _petCommentTemplates[random.nextInt(_petCommentTemplates.length)],
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '일기 수정' : '일기 작성')),
      body: SafeArea(child: _buildForm()),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${_date.year}.${_date.month.toString().padLeft(2, '0')}.${_date.day.toString().padLeft(2, '0')}',
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 20),
        const SectionTitle('누구의 이야기인가요?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: widget.pets.map((pet) {
            final selected = _selectedPetIds.contains(pet.id);
            return ChoiceChip(
              label: Text(pet.name),
              selected: selected,
              onSelected: (v) => setState(() {
                if (v) {
                  _selectedPetIds.add(pet.id);
                } else {
                  _selectedPetIds.remove(pet.id);
                }
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const SectionTitle('사진'),
        const SizedBox(height: 10),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoPaths.length + (_photoPaths.length < 5 ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == _photoPaths.length) {
                return GestureDetector(
                  onTap: _addPhoto,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primaryDark),
                  ),
                );
              }
              return PhotoPlaceholder(
                imagePath: _photoPaths[index],
                onRemove: () => _removePhoto(index),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle('오늘 있었던 일', required: true),
        const SizedBox(height: 10),
        TextField(
          controller: _memoController,
          minLines: 6,
          maxLines: null,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: '오늘은 어떤 하루를 보냈나요?',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _canUpload && !_uploading ? _upload : null,
          icon: _uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(_isEditing ? Icons.check_rounded : Icons.upload_rounded),
          label: Text(_uploading ? '업로드 중…' : (_isEditing ? '수정 완료' : '일기 업로드')),
        ),
      ],
    );
  }
}
