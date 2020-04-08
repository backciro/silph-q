import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_pattern/bloc_pattern_test.dart';

import 'package:SILPH_Q/app/home/question-form/questionform_bloc.dart';
import 'package:SILPH_Q/app/home/home_module.dart';

void main() {

  initModule(HomeModule());
  QuestionFormBloc bloc;
  
  setUp(() {
      bloc = HomeModule.to.bloc<QuestionFormBloc>();
  });

  group('QuestionFormBloc Test', () {
    test("First Test", () {
      expect(bloc, isInstanceOf<QuestionFormBloc>());
    });
  });

}
  