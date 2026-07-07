import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/mock_data_service.dart';
import 'diary/diary_screen.dart';
import 'home/home_screen.dart';
import 'pet/pet_profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _dataService = MockDataService();

  int _currentIndex = 0;

  late final List<Pet> _pets = _dataService.loadPets();
  late final List<DiaryEntry> _diaryEntries = _dataService.loadDiaryEntries();

  bool _hasShownSwipeHint = false;
  bool _showSwipeHint = false;

  void _addPet(Pet pet) {
    setState(() {
      _pets.add(pet);
      if (!_hasShownSwipeHint) {
        _hasShownSwipeHint = true;
        _showSwipeHint = true;
      }
    });
  }

  void _dismissSwipeHint() {
    setState(() => _showSwipeHint = false);
  }

  /// Deletes [pet] and its diary entries, returning a callback that restores them.
  VoidCallback _deletePet(Pet pet) {
    final petIndex = _pets.indexOf(pet);
    final removedEntries = _diaryEntries.where((e) => e.petIds.contains(pet.id)).toList();

    setState(() {
      _pets.removeWhere((p) => p.id == pet.id);
      _diaryEntries.removeWhere((e) => e.petIds.contains(pet.id));
    });

    return () {
      setState(() {
        if (!_pets.any((p) => p.id == pet.id)) {
          _pets.insert(petIndex.clamp(0, _pets.length), pet);
        }
        for (final entry in removedEntries) {
          if (!_diaryEntries.any((e) => e.id == entry.id)) {
            _diaryEntries.add(entry);
          }
        }
      });
    };
  }

  void _saveDiaryEntry(DiaryEntry entry) {
    setState(() {
      final index = _diaryEntries.indexWhere((e) => e.id == entry.id);
      if (index == -1) {
        _diaryEntries.insert(0, entry);
      } else {
        _diaryEntries[index] = entry;
      }
    });
  }

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = List.of(_diaryEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final screens = [
      HomeScreen(
        pets: _pets,
        diaryEntries: sortedEntries,
        onAddPet: _addPet,
        onWriteDiary: () => _goToTab(1),
        onOpenPets: () => _goToTab(2),
      ),
      DiaryScreen(
        pets: _pets,
        diaryEntries: sortedEntries,
        onSaveEntry: _saveDiaryEntry,
      ),
      PetProfileScreen(
        pets: _pets,
        diaryEntries: sortedEntries,
        onAddPet: _addPet,
        onDeletePet: _deletePet,
        showSwipeHint: _showSwipeHint,
        onSwipeHintShown: _dismissSwipeHint,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: '다이어리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_rounded),
            label: '펫 프로필',
          ),
        ],
      ),
    );
  }
}
