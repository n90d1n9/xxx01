enum ParallelWaitStrategy {
  all, // Wait for all branches
  any, // Wait for any branch
  n, // Wait for n branches
  race, // First to complete wins
}

class ParallelExecutionNodeDefinition {
  final String id;
  final String name;
  final String description;
  final int parallelBranches;
  final ParallelWaitStrategy waitStrategy;
  final int waitForN; // Used when strategy is 'n'
  final Duration? branchTimeout;
  final bool continueOnError;
  final Map<String, dynamic> metadata;

  ParallelExecutionNodeDefinition({
    required this.id,
    required this.name,
    required this.description,
    this.parallelBranches = 2,
    this.waitStrategy = ParallelWaitStrategy.all,
    this.waitForN = 1,
    this.branchTimeout,
    this.continueOnError = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'parallelBranches': parallelBranches,
    'waitStrategy': waitStrategy.name,
    'waitForN': waitForN,
    'branchTimeout': branchTimeout?.inMilliseconds,
    'continueOnError': continueOnError,
    'metadata': metadata,
  };

  factory ParallelExecutionNodeDefinition.fromJson(Map<String, dynamic> json) =>
      ParallelExecutionNodeDefinition(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        parallelBranches: json['parallelBranches'] ?? 2,
        waitStrategy: ParallelWaitStrategy.values.firstWhere(
          (e) => e.name == json['waitStrategy'],
          orElse: () => ParallelWaitStrategy.all,
        ),
        waitForN: json['waitForN'] ?? 1,
        branchTimeout: json['branchTimeout'] != null
            ? Duration(milliseconds: json['branchTimeout'])
            : null,
        continueOnError: json['continueOnError'] ?? false,
        metadata: json['metadata'] ?? {},
      );
}

// Continue with ParallelExecutionEditorScreen in n

class ParallelExecutionNodeExecutor {
  final ParallelExecutionNodeDefinition definition;

  ParallelExecutionNodeExecutor(this.definition);

  Future<Map<String, dynamic>> execute(
    Map<String, dynamic> input,
    List<Future<Map<String, dynamic>> Function(Map<String, dynamic>)> branches,
  ) async {
    final results = <String, dynamic>{};
    final errors = <String, dynamic>{};
    final completedBranches = <int>[];

    try {
      final futures = branches.asMap().entries.map((entry) {
        return _executeBranch(entry.key, entry.value, input).then((result) {
          if (result['success']) {
            results['branch_${entry.key}'] = result['data'];
            completedBranches.add(entry.key);
          } else {
            errors['branch_${entry.key}'] = result['error'];
            if (!definition.continueOnError) {
              throw Exception('Branch ${entry.key} failed: ${result['error']}');
            }
          }
          return result;
        });
      }).toList();

      switch (definition.waitStrategy) {
        case ParallelWaitStrategy.all:
          await Future.wait(futures);
          break;
        case ParallelWaitStrategy.any:
          await Future.any(futures);
          break;
        case ParallelWaitStrategy.n:
          // Wait for n branches to complete
          var completed = 0;
          await Future.wait(
            futures.map(
              (f) => f.then((_) {
                completed++;
                if (completed >= definition.waitForN) {
                  return;
                }
              }),
            ),
          );
          break;
        case ParallelWaitStrategy.race:
          await Future.any(futures);
          break;
      }

      return {
        'success': true,
        'output_port': 'success',
        'results': results,
        'errors': errors,
        'completed_branches': completedBranches,
        'total_branches': branches.length,
      };
    } catch (e) {
      return {
        'success': false,
        'output_port': 'error',
        'results': results,
        'errors': errors,
        'error': e.toString(),
        'completed_branches': completedBranches,
        'total_branches': branches.length,
      };
    }
  }

  Future<Map<String, dynamic>> _executeBranch(
    int branchIndex,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>) branch,
    Map<String, dynamic> input,
  ) async {
    try {
      if (definition.branchTimeout != null) {
        final result = await branch(input).timeout(definition.branchTimeout!);
        return {'success': true, 'data': result};
      } else {
        final result = await branch(input);
        return {'success': true, 'data': result};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
