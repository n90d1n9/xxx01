class PollOption {
  final String id;
  final String text;
  final int votes;
  final List<String> voters;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voters = const [],
  });
}
