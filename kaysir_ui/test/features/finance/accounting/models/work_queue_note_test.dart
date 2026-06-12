import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_note.dart';

void main() {
  test('creates and serializes accounting work queue notes', () {
    final note = AccountingWorkspaceWorkQueueNote.create(
      id: 'note-1',
      queueId: ' auditor-evidence-gaps ',
      authorLabel: ' Auditor ',
      body: ' Owner confirmed signed release manifest. ',
      createdAt: DateTime(2026, 6, 9, 10, 15),
      type: AccountingWorkspaceWorkQueueNoteType.evidence,
    );

    expect(note.queueId, 'auditor-evidence-gaps');
    expect(note.authorLabel, 'Auditor');
    expect(note.body, 'Owner confirmed signed release manifest.');
    expect(note.typeLabel, 'Evidence');
    expect(note.isPersistable, isTrue);
    expect(note.toJson(), {
      'id': 'note-1',
      'queueId': 'auditor-evidence-gaps',
      'authorLabel': 'Auditor',
      'body': 'Owner confirmed signed release manifest.',
      'createdAt': '2026-06-09T10:15:00.000',
      'type': 'evidence',
    });
  });

  test('restores valid notes and rejects malformed persisted notes', () {
    final restored = accountingWorkspaceWorkQueueNoteFromJson({
      'id': 'note-1',
      'queueId': 'auditor-evidence-gaps',
      'authorLabel': '',
      'body': 'Controller returned the support list.',
      'createdAt': '2026-06-09T11:00:00.000',
      'type': 'owner-handoff',
    });
    final rejected = accountingWorkspaceWorkQueueNoteFromJson({
      'id': 'note-2',
      'queueId': '',
      'body': 'Missing queue id',
    });

    expect(restored, isNotNull);
    expect(restored!.type, AccountingWorkspaceWorkQueueNoteType.handoff);
    expect(restored.authorDisplayLabel, 'Accounting workspace');
    expect(restored.timeLabel, '2026-06-09 11:00');
    expect(rejected, isNull);
  });

  test('formats execution note audit brief newest first', () {
    final brief = accountingWorkspaceWorkQueueNotesBrief(
      queueTitle: 'Audit evidence gaps',
      notes: [
        AccountingWorkspaceWorkQueueNote.create(
          id: 'note-1',
          queueId: 'auditor-evidence-gaps',
          authorLabel: 'Auditor',
          body: 'Older owner response.',
          createdAt: DateTime(2026, 6, 9, 9),
        ),
        AccountingWorkspaceWorkQueueNote.create(
          id: 'note-2',
          queueId: 'auditor-evidence-gaps',
          authorLabel: 'Controller',
          body: 'Latest reviewer decision.',
          createdAt: DateTime(2026, 6, 9, 12),
          type: AccountingWorkspaceWorkQueueNoteType.decision,
        ),
      ],
    );

    expect(brief, contains('Execution notes: Audit evidence gaps'));
    expect(
      brief.indexOf('Latest reviewer decision.'),
      lessThan(brief.indexOf('Older owner response.')),
    );
    expect(brief, contains('Decision: Latest reviewer decision.'));
  });
}
