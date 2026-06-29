import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/human_approval_request.dart';
import '../model/human_approval_status.dart';
import '../states/approval_provider.dart';
import 'human_approval_request_screen.dart';

class PendingApprovalsScreen extends ConsumerWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(approvalRequestsProvider);
    final pendingRequests = requests
        .where((r) => r.isPending && !r.isExpired)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        title: Row(
          children: [
            const Icon(Icons.pending_actions, color: Colors.orange),
            const SizedBox(width: 12),
            const Text(
              'Pending Approvals',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pendingRequests.length}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: pendingRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending approvals',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All caught up!',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) =>
                  _buildApprovalCard(context, ref, pendingRequests[index]),
            ),
    );
  }

  Widget _buildApprovalCard(
    BuildContext context,
    WidgetRef ref,
    HumanApprovalRequest request,
  ) {
    return Card(
      color: const Color(0xFF2D2D2D),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HumanApprovalRequestScreen(
                request: request,
                onRespond: (responded) {
                  // Update state
                  final requests = ref.read(approvalRequestsProvider);
                  final index = requests.indexWhere(
                    (r) => r.id == responded.id,
                  );
                  if (index != -1) {
                    requests[index] = responded;
                    ref.read(approvalRequestsProvider.notifier).state = [
                      ...requests,
                    ];
                  }
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.definition.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.definition.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (request.expiresAt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getUrgencyColor(request).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            color: _getUrgencyColor(request),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeRemaining(request),
                            style: TextStyle(
                              color: _getUrgencyColor(request),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  request.definition.prompt,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    _formatCreatedTime(request),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.category,
                    _getApprovalTypeLabel(request.definition.approvalType),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(HumanApprovalRequest request) {
    if (request.expiresAt == null) return Colors.blue;
    final remaining = request.expiresAt!.difference(DateTime.now());
    if (remaining.inMinutes < 15) return Colors.red;
    if (remaining.inMinutes < 60) return Colors.orange;
    return Colors.yellow;
  }

  String _formatTimeRemaining(HumanApprovalRequest request) {
    if (request.expiresAt == null) return 'No limit';
    final remaining = request.expiresAt!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    if (remaining.inHours > 0)
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}m';
    return '${remaining.inSeconds}s';
  }

  String _formatCreatedTime(HumanApprovalRequest request) {
    final diff = DateTime.now().difference(request.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _getApprovalTypeLabel(HumanApprovalType type) {
    switch (type) {
      case HumanApprovalType.binary:
        return 'Approve/Reject';
      case HumanApprovalType.choice:
        return 'Single Choice';
      case HumanApprovalType.multiChoice:
        return 'Multi Choice';
      case HumanApprovalType.text:
        return 'Text Input';
    }
  }
}
