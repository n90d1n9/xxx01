import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_bench_check_in_provider.dart';
import 'incoming_talent_succession_bench_check_in_form_fields.dart';

class IncomingTalentSuccessionBenchCheckInForm extends ConsumerStatefulWidget {
  const IncomingTalentSuccessionBenchCheckInForm({super.key});

  @override
  ConsumerState<IncomingTalentSuccessionBenchCheckInForm> createState() =>
      _IncomingTalentSuccessionBenchCheckInFormState();
}

class _IncomingTalentSuccessionBenchCheckInFormState
    extends ConsumerState<IncomingTalentSuccessionBenchCheckInForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ownerController;
  late final TextEditingController _blockerController;
  late final TextEditingController _supportController;
  late final TextEditingController _actionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentSuccessionBenchCheckInDraftProvider);
    _ownerController = TextEditingController(text: draft.ownerName);
    _blockerController = TextEditingController(text: draft.blockerSummary);
    _supportController = TextEditingController(text: draft.leadershipSupport);
    _actionController = TextEditingController(text: draft.nextAction);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _blockerController.dispose();
    _supportController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(incomingTalentSuccessionBenchCheckInDraftProvider);
    final plans = ref.watch(checkInReadySuccessionBenchReplenishmentsProvider);

    _sync(_ownerController, draft.ownerName);
    _sync(_blockerController, draft.blockerSummary);
    _sync(_supportController, draft.leadershipSupport);
    _sync(_actionController, draft.nextAction);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(
              'succession-bench-check-in-${draft.benchReplenishmentId}',
            ),
            initialValue:
                _planExists(plans, draft.benchReplenishmentId)
                    ? draft.benchReplenishmentId
                    : null,
            decoration: const InputDecoration(
              labelText: 'Open bench plan',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
            items:
                plans
                    .map(
                      (plan) => DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.role} - ${plan.priority.label}'),
                      ),
                    )
                    .toList(),
            onChanged: plans.isEmpty ? null : _selectPlan,
            validator:
                (value) =>
                    IncomingTalentSuccessionBenchCheckInDraft.validateRequired(
                      value,
                      'an open bench plan',
                    ),
          ),
          const SizedBox(height: 12),
          if (plans.isEmpty)
            const HrisListSurface(
              child: Text('No open bench replenishments need check-in today.'),
            )
          else ...[
            IncomingTalentSuccessionBenchCheckInTextInput(
              controller: _ownerController,
              label: 'Check-in owner',
              icon: Icons.badge_outlined,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setOwnerName,
              validator:
                  (value) =>
                      IncomingTalentSuccessionBenchCheckInDraft.validateRequired(
                        value,
                        'a check-in owner',
                      ),
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInDateFields(
              draft: draft,
              onSelectCheckInDate: _selectCheckInDate,
              onSelectNextCheckInDate: _selectNextCheckInDate,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInSignalFields(
              draft: draft,
              onHealthChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setHealth,
              onSuccessorSlateChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setSuccessorSlateCount,
              onReadyNowChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setReadyNowCount,
              onReadinessChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setReadinessScore,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInTextInput(
              controller: _blockerController,
              label: 'Blocker summary',
              icon: Icons.report_problem_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setBlockerSummary,
              validator:
                  IncomingTalentSuccessionBenchCheckInDraft
                      .validateBlockerSummary,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInTextInput(
              controller: _supportController,
              label: 'Leadership support',
              icon: Icons.handshake_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setLeadershipSupport,
              validator:
                  IncomingTalentSuccessionBenchCheckInDraft
                      .validateLeadershipSupport,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInTextInput(
              controller: _actionController,
              label: 'Next action',
              icon: Icons.route_outlined,
              minLines: 3,
              onChanged:
                  ref
                      .read(
                        incomingTalentSuccessionBenchCheckInDraftProvider
                            .notifier,
                      )
                      .setNextAction,
              validator:
                  IncomingTalentSuccessionBenchCheckInDraft.validateNextAction,
            ),
            const SizedBox(height: 12),
            IncomingTalentSuccessionBenchCheckInDraftReadiness(draft: draft),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      ref
                          .read(
                            incomingTalentSuccessionBenchCheckInDraftProvider
                                .notifier,
                          )
                          .clear,
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  key: const Key(
                    'incoming-talent-succession-bench-check-in-submit',
                  ),
                  onPressed: draft.isReadyToSubmit ? _submitCheckIn : null,
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: const Text('Submit check-in'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _selectPlan(String? planId) {
    if (planId == null) return;
    final plans = ref.read(checkInReadySuccessionBenchReplenishmentsProvider);
    final plan = plans.firstWhere((item) => item.id == planId);
    ref
        .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
        .initializeFromReplenishment(plan);
  }

  Future<void> _selectCheckInDate() async {
    final draft = ref.read(incomingTalentSuccessionBenchCheckInDraftProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.checkInDate ?? draft.asOfDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
        .setCheckInDate(picked);
  }

  Future<void> _selectNextCheckInDate() async {
    final draft = ref.read(incomingTalentSuccessionBenchCheckInDraftProvider);
    final checkInDate = draft.checkInDate ?? draft.asOfDate;
    final firstDate = checkInDate.add(const Duration(days: 1));
    final initialDate =
        draft.nextCheckInDate != null &&
                draft.nextCheckInDate!.isAfter(checkInDate)
            ? draft.nextCheckInDate!
            : firstDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
        .setNextCheckInDate(picked);
  }

  void _submitCheckIn() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentSuccessionBenchCheckInDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final checkIn = ref
          .read(incomingTalentSuccessionBenchCheckInsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(incomingTalentSuccessionBenchCheckInDraftProvider.notifier)
          .clear();
      _showMessage('${checkIn.id} submitted for ${checkIn.role}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _planExists(
    List<IncomingTalentSuccessionBenchReplenishment> plans,
    String planId,
  ) {
    return plans.any((plan) => plan.id == planId);
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}
