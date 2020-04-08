import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_pattern/bloc_pattern_test.dart';

import 'package:SILPH_Q/app/home/question-form/questionform_widget.dart';

main() {
  testWidgets('Question-formWidget has message', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(QuestionFormWidget()));
    final textFinder = find.text('Question-form');
    expect(textFinder, findsOneWidget);
  });
}
