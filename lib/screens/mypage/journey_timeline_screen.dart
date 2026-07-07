import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme.dart';

class JourneyTimelineScreen extends StatelessWidget {
  const JourneyTimelineScreen({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final milestones = <_Milestone>[
      _Milestone('첫 만남', pet.anniversary),
      _Milestone('함께한 100일', pet.anniversary.add(const Duration(days: 100))),
      _Milestone('함께한 365일', pet.anniversary.add(const Duration(days: 365))),
      _Milestone('함께한 500일', pet.anniversary.add(const Duration(days: 500))),
      _Milestone('함께한 1000일', pet.anniversary.add(const Duration(days: 1000))),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('${pet.name}와 함께한 시간')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final m in milestones) _TimelineNode(milestone: m, reached: !m.date.isAfter(now)),
          _TimelineNode(milestone: _Milestone('오늘', now), reached: true, isLast: true),
        ],
      ),
    );
  }
}

class _Milestone {
  const _Milestone(this.label, this.date);

  final String label;
  final DateTime date;
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.milestone, required this.reached, this.isLast = false});

  final _Milestone milestone;
  final bool reached;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = reached ? AppColors.primaryDark : Colors.black26;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.cardBorder)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.label,
                    style: TextStyle(fontWeight: FontWeight.w700, color: reached ? AppColors.textDark : Colors.black38),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${milestone.date.year}.${milestone.date.month.toString().padLeft(2, '0')}.${milestone.date.day.toString().padLeft(2, '0')}'
                    '${reached ? '' : ' (예정)'}',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
