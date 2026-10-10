import 'package:ccpocket/features/chat_session/question_answer_transcript.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('questionAnswerTranscript', () {
    test('preserves every option, description, header and selected choice', () {
      final transcript = questionAnswerTranscript(
        input: const {
          'questions': [
            {
              'id': 'sound',
              'question': 'Which sound should the garden use?',
              'header': 'Garden sound',
              'options': [
                {'label': 'Forest birdsong', 'description': 'Morning birds'},
                {'label': 'Rainfall', 'description': 'Soft rain'},
              ],
            },
          ],
        },
        result: 'Forest birdsong',
      );

      expect(transcript, isNotNull);
      final question = transcript!.questions.single;
      expect(question.header, 'Garden sound');
      expect(question.question, 'Which sound should the garden use?');
      expect(question.options, hasLength(2));
      expect(question.options[0].label, 'Forest birdsong');
      expect(question.options[0].description, 'Morning birds');
      expect(question.options[0].selected, isTrue);
      expect(question.options[1].label, 'Rainfall');
      expect(question.options[1].description, 'Soft rain');
      expect(question.options[1].selected, isFalse);
    });

    test('shows free-text answers alongside selected multi-select options', () {
      final transcript = questionAnswerTranscript(
        input: const {
          'questions': [
            {
              'id': 'zones',
              'question': 'Which zones?',
              'multiSelect': true,
              'options': [
                {'label': 'Forest', 'description': 'Wooded area'},
                {'label': 'Desert', 'description': 'Dry area'},
              ],
            },
          ],
        },
        result: '{"answers":{"zones":["Forest", "A hidden cave"]}}',
      );

      final question = transcript!.questions.single;
      expect(question.options.first.selected, isTrue);
      expect(question.options.last.selected, isFalse);
      expect(question.freeTextAnswer, 'A hidden cave');
      expect(transcript.plainText, contains('Forest, A hidden cave'));
    });

    test('maps submitted option values to their displayed labels', () {
      final transcript = questionAnswerTranscript(
        input: const {
          'questions': [
            {
              'id': 'sound',
              'question': 'Which sound should the garden use?',
              'options': [
                {
                  'label': 'Forest birdsong',
                  'value': 'forest-birds',
                  'description': 'Morning birds',
                },
              ],
            },
          ],
        },
        result: '{"answers":{"sound":" forest-birds "}}',
      );

      expect(transcript, isNotNull);
      final question = transcript!.questions.single;
      expect(question.options.single.label, 'Forest birdsong');
      expect(question.options.single.selected, isTrue);
      expect(question.freeTextAnswer, isNull);
      expect(transcript.plainText, contains('Answer: Forest birdsong'));
    });
  });

  test('does not retain or display secret answers', () {
    const secret = 'top-secret-value';
    final transcript = questionAnswerTranscript(
      input: const {
        'questions': [
          {
            'id': 'password',
            'question': 'What is the access token?',
            'isSecret': true,
          },
        ],
      },
      result: secret,
    );

    expect(transcript, isNotNull);
    expect(transcript!.plainText, isNot(contains(secret)));
    expect(transcript.plainText, contains('[hidden]'));
    expect(transcript.questions.single.answerHidden, isTrue);
    expect(transcript.questions.single.freeTextAnswer, isNull);
  });
}
