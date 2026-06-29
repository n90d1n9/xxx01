import 'poll_option.dart';

class Poll {
  final String question;
  final List<PollOption> options;
  final bool allowMultiple;
  final DateTime? expiresAt;
  final bool isAnonymous;

  Poll({
    required this.question,
    required this.options,
    this.allowMultiple = false,
    this.expiresAt,
    this.isAnonymous = false,
  });
}
