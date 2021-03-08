import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class QuestionFormWidget extends StatefulWidget {
  final Function saveElement;

  QuestionFormWidget({this.saveElement});

  @override
  _QuestionFormWidgetState createState() => _QuestionFormWidgetState();
}

class _QuestionFormWidgetState extends State<QuestionFormWidget> {
  final _formKey = new GlobalKey<FormState>();
  Survey _survey = new Survey();
  Function eq = const ListEquality().equals;

  checkAnswers(List<bool> answers) {
    if (eq(answers, Survey.A4)) return 4;
    if (eq(answers, Survey.A16)) return 16;
    if (eq(answers, Survey.A25)) return 25;
    if (eq(answers, Survey.A36)) return 36;
    if (eq(answers, Survey.A45)) return 45;
    if (eq(answers, Survey.A90)) return 90;
    if (answers[0] == true)
      return 4;
    else
      return 36;
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) _survey.answers[i] = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Autovalutazione',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD0CCD0),
          ),
        ),
        backgroundColor: Color(0xFF274156),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFD0CCD0),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Builder(
            builder: (context) => Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Text(
                      'Rispondi a qualche domanda per capire il tuo stato generale di salute.\n'
                      'Le tue risposte verranno valutate da un algoritmo sul tuo cellulare.\n'
                      'Il risultato sarà un numero su una scala da uno a tre che indicherà il tuo grado di contagiosità.',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  ),
                  CheckboxListTile(
                      dense: true,
                      title: const Text(
                        Survey.Q1,
                        textAlign: TextAlign.left,
                      ),
                      activeColor: Color(0xFF274156),
                      checkColor: Color(0xFFD0CCD0),
                      value: _survey.answers[0],
                      onChanged: (val) {
                        setState(() => _survey.answers[0] = val);
                      }),
                  CheckboxListTile(
                      dense: true,
                      title: const Text(
                        Survey.Q2,
                        textAlign: TextAlign.left,
                      ),
                      activeColor: Color(0xFF274156),
                      checkColor: Color(0xFFD0CCD0),
                      value: _survey.answers[1],
                      onChanged: (val) {
                        setState(() => _survey.answers[1] = val);
                      }),
                  CheckboxListTile(
                      dense: true,
                      title: const Text(
                        Survey.Q3,
                        textAlign: TextAlign.left,
                      ),
                      activeColor: Color(0xFF274156),
                      checkColor: Color(0xFFD0CCD0),
                      value: _survey.answers[2],
                      onChanged: (val) {
                        setState(() => _survey.answers[2] = val);
                      }),
                  CheckboxListTile(
                      dense: true,
                      title: const Text(
                        Survey.Q4,
                        textAlign: TextAlign.left,
                      ),
                      activeColor: Color(0xFF274156),
                      checkColor: Color(0xFFD0CCD0),
                      value: _survey.answers[3],
                      onChanged: (val) {
                        setState(() => _survey.answers[3] = val);
                      }),
                  Container(
                    color: Color(0xFFD0CCD0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 64.0, horizontal: 16.0),
                    child: RaisedButton(
                      onPressed: () {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          widget.saveElement(checkAnswers(_survey.answers));
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'SALVA',
                        style: TextStyle(
                            color: Color(0xFF274156),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Submitting form')));
  }
}

class Survey {
  static const String Q1 = 'Non sono MAI uscito di casa negli ultimi 5 giorni';
  static const String Q2 = 'Ho SEMPRE usato la mascherina';
  static const String Q3 = 'Ho SEMPRE usato i guanti protettivi';
  static const String Q4 =
      'Non ho starnutito o tossito mentre ero in un luogo pubblico';

  static const List<bool> A4 = [true, true, true, true];
  static const List<bool> A16 = [false, true, true, true];
  static const List<bool> A25 = [false, true, false, true];
  static const List<bool> A36 = [false, false, true, false];
  static const List<bool> A45 = [false, false, false, true];
  static const List<bool> A90 = [false, false, false, false];

  List<bool> answers;

  Survey() {
    answers = new List(4);
  }

  bool newsletter = false;
}
