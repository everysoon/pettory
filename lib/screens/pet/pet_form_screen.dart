import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/photo_service.dart';
import '../../theme.dart';
import '../../widgets/section_title.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.photoService = const LocalPhotoService()});

  final PhotoService photoService;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  static const _customSpecies = '직접입력';

  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _customSpeciesController = TextEditingController();
  final _traitInputController = TextEditingController();

  String _species = '강아지';
  DateTime _anniversary = DateTime.now();
  DateTime? _birthday;
  DateTime? _lastCheckupDate;
  String? _photoPath;
  final List<String> _traits = [];

  static const _colors = [
    Color(0xFFFFC988),
    Color(0xFFB9D8FF),
    Color(0xFFC9E8C0),
    Color(0xFFE3C9F5),
  ];

  static const _suggestedTraits = ['활발', '애교', '낯가림', '호기심', '도도', '느긋'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _customSpeciesController.dispose();
    _traitInputController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await widget.photoService.pickFromLibrary();
    if (picked == null) return;
    final saved = await widget.photoService.save(picked);
    if (!mounted) return;
    setState(() => _photoPath = saved);
  }

  Future<void> _pickAnniversary() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anniversary,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _anniversary = picked);
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _pickLastCheckupDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastCheckupDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _lastCheckupDate = picked);
  }

  void _addTrait(String value) {
    final trait = value.trim().replaceFirst(RegExp(r'^#+'), '');
    if (trait.isEmpty) return;
    setState(() {
      if (!_traits.contains(trait)) _traits.add(trait);
      _traitInputController.clear();
    });
  }

  void _removeTrait(String trait) {
    setState(() => _traits.remove(trait));
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    final species = _species == _customSpecies
        ? (_customSpeciesController.text.trim().isEmpty ? '기타' : _customSpeciesController.text.trim())
        : _species;
    final pet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      species: species,
      breed: _breedController.text.trim().isEmpty ? '믹스' : _breedController.text.trim(),
      anniversary: _anniversary,
      birthday: _birthday,
      lastCheckupDate: _lastCheckupDate,
      traits: _traits,
      color: _colors[_traits.length % _colors.length],
      photoPath: _photoPath,
    );
    Navigator.of(context).pop(pet);
  }

  String _formatDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('반려동물 등록')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.cardBorder,
                    backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                    child: _photoPath == null
                        ? const Icon(Icons.camera_alt_rounded, color: AppColors.primaryDark, size: 28)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _photoPath == null ? '대표사진을 등록해주세요' : '사진을 눌러 변경할 수 있어요',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('종류'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('🐶 강아지'),
                selected: _species == '강아지',
                onSelected: (_) => setState(() => _species = '강아지'),
              ),
              ChoiceChip(
                label: const Text('🐱 고양이'),
                selected: _species == '고양이',
                onSelected: (_) => setState(() => _species = '고양이'),
              ),
              ChoiceChip(
                label: const Text('직접입력'),
                selected: _species == _customSpecies,
                onSelected: (_) => setState(() => _species = _customSpecies),
              ),
            ],
          ),
          if (_species == _customSpecies) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _customSpeciesController,
              decoration: InputDecoration(
                hintText: '예) 페럿',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '예) 몽이',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _breedController,
            decoration: InputDecoration(
              labelText: '품종',
              hintText: '예) 포메라니안',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('함께한 날'),
            subtitle: Text(_formatDate(_anniversary)),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: _pickAnniversary,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('생일'),
            subtitle: Text(_birthday != null ? _formatDate(_birthday!) : '선택 안 함'),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: _pickBirthday,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('건강검진날'),
            subtitle: Text(_lastCheckupDate != null ? _formatDate(_lastCheckupDate!) : '선택 안 함'),
            trailing: const Icon(Icons.calendar_today_rounded, size: 18),
            onTap: _pickLastCheckupDate,
          ),
          const SizedBox(height: 14),
          const SectionTitle('성격 태그'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedTraits
                .where((t) => !_traits.contains(t))
                .map((t) => ActionChip(
                      label: Text('#$t'),
                      onPressed: () => _addTrait(t),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _traitInputController,
            onSubmitted: _addTrait,
            decoration: InputDecoration(
              hintText: '직접 입력 후 엔터',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_traits.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _traits
                  .map((t) => Chip(
                        label: Text('#$t'),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        onDeleted: () => _removeTrait(t),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _submit, child: const Text('등록하고 시작하기')),
        ],
      ),
    );
  }
}
