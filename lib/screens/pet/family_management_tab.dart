import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/models.dart';
import '../../theme.dart';

/// Per-pet family management (v4 plan: moved from My Page to Pet Detail —
/// family membership is scoped to a pet, not the account).
class FamilyManagementTab extends StatelessWidget {
  const FamilyManagementTab({super.key, required this.pet});

  final Pet pet;

  String get _inviteCode {
    final hash = pet.id.hashCode.toRadixString(36).toUpperCase();
    return hash.length >= 6 ? hash.substring(0, 6) : hash.padRight(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('현재 가족', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Icon(Icons.person_rounded)),
          title: Text('나'),
          trailing: Text('Owner', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 20),
        const Text('초대 코드', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(_inviteCode, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('초대 코드가 복사되었어요')),
                  );
                },
                child: const Text('복사'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
