import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);
    if (!required) return Text(text, style: style);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('* ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.red)),
        Text(text, style: style),
      ],
    );
  }
}
