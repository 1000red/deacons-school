import 'package:flutter/material.dart';
import '../models/models.dart';

class CurriculumLevels {
  CurriculumLevels._();

  static const levels = <Level>[
    Level(
      id: 'preparatory',
      name: 'المستوى تمهيدي',
      subtitle: 'سنة دراسية واحدة',
      icon: Icons.auto_awesome,
      color: Color(0xFF0D9488),
      yearsCount: 1, // 0
    ),
    Level(
      id: 'first',
      name: 'المستوى الأول',
      subtitle: '٣ سنوات دراسية',
      icon: Icons.looks_one,
      color: Color(0xFF2563EB),
      yearsCount: 3, // 0, 1, 2
    ),
    Level(
      id: 'second',
      name: 'المستوى الثاني',
      subtitle: '٣ سنوات دراسية',
      icon: Icons.looks_two,
      color: Color(0xFF7C3AED),
      yearsCount: 3,
    ),
    Level(
      id: 'third',
      name: 'المستوى الثالث',
      subtitle: '٣ سنوات دراسية',
      icon: Icons.looks_3,
      color: Color(0xFFB45309),
      yearsCount: 3,
    ),
  ];

  static const yearNames = ['السنة الأولى', 'السنة الثانية', 'السنة الثالثة'];
  static const termNames = ['الترم الأول', 'الترم الثاني', 'الترم الثالث'];

  static List<YearLevel> yearsOf(Level level) {
    return List.generate(
      level.yearsCount,
      (i) => YearLevel(
          id: '${level.id}_y${i + 1}',
          name: level.yearsCount == 1 ? 'المستوى تمهيدي' : yearNames[i]),
    );
  }

  static List<Term> terms() {
    return List.generate(3, (i) => Term(id: 't${i + 1}', name: termNames[i]));
  }
}
