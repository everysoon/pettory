class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.date,
    required this.petIds,
    required this.memo,
    this.photoPaths = const [],
    this.petComment,
  });

  final String id;
  final DateTime date;
  final List<String> petIds;
  final String memo;
  final List<String> photoPaths;
  final String? petComment;
}
