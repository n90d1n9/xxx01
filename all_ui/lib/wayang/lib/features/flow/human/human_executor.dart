import 'model/human_approval_request.dart';
import 'model/human_approval_status.dart';
import 'model/human_loop_definition.dart';

class HumanInLoopNodeExecutor {
  final HumanInLoopNodeDefinition definition;

  HumanInLoopNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    Future<HumanApprovalRequest> Function(HumanApprovalRequest) waitForApproval,
  ) async {
    // Create approval request
    final request = HumanApprovalRequest(
      id: 'approval_${DateTime.now().millisecondsSinceEpoch}',
      definition: definition,
      inputData: input,
      createdAt: DateTime.now(),
      expiresAt: definition.timeout != null
          ? DateTime.now().add(definition.timeout!)
          : null,
    );

    // Wait for human response
    try {
      final response = await waitForApproval(request);

      // Check for timeout
      if (response.isExpired && response.isPending) {
        return {
          'status': 'timeout',
          'output_port': 'timeout',
          'request_id': response.id,
          'data': input,
        };
      }

      // Process response based on approval type
      return _processResponse(response, input);
    } catch (e) {
      return {'status': 'error', 'error': e.toString(), 'data': input};
    }
  }

  Map<String, dynamic> _processResponse(
    HumanApprovalRequest response,
    Map<String, dynamic> input,
  ) {
    final result = {
      'request_id': response.id,
      'approved_by': response.approvedBy,
      'responded_at': response.respondedAt?.toIso8601String(),
      'comment': response.comment,
      'data': input,
    };

    switch (definition.approvalType) {
      case HumanApprovalType.binary:
        result['status'] = response.status.name;
        result['output_port'] = response.status.name;
        break;

      case HumanApprovalType.choice:
        result['status'] = 'completed';
        result['output_port'] = response.selectedOption;
        result['selected_option'] = response.selectedOption;
        break;

      case HumanApprovalType.multiChoice:
        result['status'] = 'completed';
        result['output_port'] = 'completed';
        result['selected_options'] = response.selectedOptions;
        break;

      case HumanApprovalType.text:
        result['status'] = 'completed';
        result['output_port'] = 'completed';
        result['text_response'] = response.textResponse;
        break;
    }

    return result;
  }
}
