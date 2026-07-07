import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/placeholder_screen.dart';
import 'journey_timeline_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key, required this.pets, required this.diaryEntries});

  final List<Pet> pets;
  final List<DiaryEntry> diaryEntries;

  int get _photoCount => diaryEntries.fold(0, (sum, e) => sum + e.photoPaths.length);
  int get _aiCommentCount => diaryEntries.where((e) => e.petComment != null).length;

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PlaceholderScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainPet = pets.isNotEmpty ? pets.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.cardBorder,
                child: Icon(Icons.person_rounded, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('보호자님', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    if (mainPet != null)
                      Text(
                        '${mainPet.name}와 함께한 ${mainPet.daysTogether}일',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (mainPet != null) ...[
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => JourneyTimelineScreen(pet: mainPet)),
              ),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${mainPet.name}와 함께한 시간 보러가기', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text('우리의 기록', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                _StatRow(label: '일기', value: '${diaryEntries.length}개'),
                _StatRow(label: '사진', value: '$_photoCount장'),
                _StatRow(label: 'AI 댓글', value: '$_aiCommentCount개'),
                const _StatRow(label: '카드', value: '0장'),
                const _StatRow(label: '추억북', value: '0권'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _MenuTile(icon: Icons.notifications_none_rounded, label: '알림 설정', onTap: () => _openPlaceholder(context, '알림 설정')),
          _MenuTile(icon: Icons.star_border_rounded, label: 'Premium', onTap: () => _openPlaceholder(context, 'Premium')),
          _MenuTile(icon: Icons.inventory_2_outlined, label: '데이터 관리', onTap: () => _openPlaceholder(context, '데이터 관리')),
          _MenuTile(icon: Icons.settings_outlined, label: '설정', onTap: () => _openPlaceholder(context, '설정')),
          _MenuTile(icon: Icons.help_outline_rounded, label: '고객센터', onTap: () => _openPlaceholder(context, '고객센터')),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('로그아웃', style: TextStyle(color: Colors.black45)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryDark),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black38),
      onTap: onTap,
    );
  }
}
