import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_note.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_note_components.dart';

void main() {
  testWidgets('renders notes and copies execution note brief', (tester) async {
    var copied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueNotesPanel(
            notes: [
              AccountingWorkspaceWorkQueueNote.create(
                id: 'note-1',
                queueId: 'auditor-evidence-gaps',
                authorLabel: 'Auditor',
                body: 'Controller confirmed owner handoff.',
                createdAt: DateTime(2026, 6, 9, 10, 15),
                type: AccountingWorkspaceWorkQueueNoteType.handoff,
              ),
            ],
            onNoteAdded: (_) {},
            onCopyNotes: () => copied = true,
          ),
        ),
      ),
    );

    expect(find.text('Execution notes'), findsOneWidget);
    expect(find.text('1 note'), findsOneWidget);
    expect(find.text('Handoff'), findsOneWidget);
    expect(find.text('Controller confirmed owner handoff.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-notes-copy')),
    );
    await tester.pump();

    expect(copied, isTrue);
  });

  testWidgets('composes a note draft from the add note dialog', (tester) async {
    AccountingWorkspaceWorkQueueNoteDraft? capturedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueNotesPanel(
            notes: const [],
            onNoteAdded: (draft) => capturedDraft = draft,
            onCopyNotes: () {},
          ),
        ),
      ),
    );

    expect(find.text('No execution notes yet.'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-notes-add')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('accounting-work-queue-note-body-field')),
      'Owner promised release support before noon.',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-note-save')),
    );
    await tester.pumpAndSettle();

    expect(capturedDraft, isNotNull);
    expect(capturedDraft!.body, 'Owner promised release support before noon.');
    expect(capturedDraft!.type, AccountingWorkspaceWorkQueueNoteType.note);
  });
}
