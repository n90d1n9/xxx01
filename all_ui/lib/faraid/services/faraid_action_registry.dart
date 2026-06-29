// faraid/faraid_action_registry.dart
import '../qonun/new/action_registry.dart';
import '../qonun/new/core.dart';

class FaraidActionRegistry extends ActionRegistry {
  FaraidActionRegistry() {
    _registerFaraidActions();
  }

  void _registerFaraidActions() {
    // Essential: set action for global variables
    register('set', (args, ctx, env) async {
      args.forEach((key, value) {
        ctx.setGlobal(key.toString(), value);
        ctx.log('set: $key = $value');
      });
    });

    // Essential: log action
    register('log', (args, ctx, env) async {
      final message = args['message'] ?? args['value'] ?? '';
      ctx.log('LOG: $message');
    });

    // assignShare
    register('assignFixedShare', (args, ctx, env) async {
      final heir = args['heir']?.toString();
      final rawShare = args['share'];
      if (heir == null || rawShare == null) return;

      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      final map = Map<String, dynamic>.from(shares);
      final remainingShare = ctx.getGlobal('remainingShare') ?? 1.0;

      final shareVal = _normalizeShare(rawShare, ctx);

      // Only assign if there's enough remaining share
      if (remainingShare >= shareVal) {
        // Accumulate with existing share
        final current = (map[heir] ?? 0.0);
        map[heir] = current + shareVal;
        ctx.setGlobal('shares', map);

        // Update remaining share
        final newRemaining = remainingShare - shareVal;
        ctx.setGlobal('remainingShare', newRemaining > 0 ? newRemaining : 0.0);

        ctx.log(
          'assignFixedShare: $heir -> $shareVal (total: ${map[heir]}), remaining: ${ctx.getGlobal('remainingShare')}',
        );
      } else {
        ctx.log(
          'assignFixedShare: Skipped $heir -> $shareVal (insufficient remaining: $remainingShare)',
        );
      }
    });

    // assignRemainingShare - ONLY for remaining share distribution
    register('assignRemainingShare', (args, ctx, env) async {
      final heir = args['heir']?.toString();
      if (heir == null) return;

      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      final map = Map<String, dynamic>.from(shares);
      final remainingShare = ctx.getGlobal('remainingShare') ?? 0.0;

      if (remainingShare > 0) {
        // For remaining share, REPLACE any existing value (don't accumulate)
        map[heir] = remainingShare;
        ctx.setGlobal('shares', map);
        ctx.setGlobal('remainingShare', 0.0);
        ctx.log('assignRemainingShare: $heir -> $remainingShare');
      }
    });

    register('computeRemaining', (args, ctx, env) async {
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};

      double total = 0.0;
      if (shares is Map) {
        shares.forEach((k, v) {
          if (v is num) {
            total += v.toDouble();
          }
        });
      }

      final remaining = 1.0 - total;
      ctx.setGlobal('remainingShare', remaining > 0 ? remaining : 0.0);
      ctx.log('computeRemaining: total=$total, remainingShare=$remaining');
    });

    // applyAwl - when total > 1.0
    register('applyAwl', (args, ctx, env) async {
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};
      double total = 0.0;
      if (shares is Map) {
        shares.forEach((k, v) {
          if (v is num) total += v.toDouble();
        });
      }

      if (total > 1.0 && shares is Map) {
        final normalized = <String, dynamic>{};
        shares.forEach((k, v) {
          if (v is num) {
            normalized[k] = (v.toDouble() / total);
          } else {
            normalized[k] = v;
          }
        });
        ctx.setGlobal('shares', normalized);
        ctx.setGlobal('remainingShare', 0.0);
        ctx.log('applyAwl: normalized shares (AWL) applied');
      }
    });

    // applyRadd - when remaining > 0 and no residuary heirs
    register('applyRadd', (args, ctx, env) async {
      final remaining = ctx.getGlobal('remainingShare') ?? 0.0;
      final shares = ctx.getGlobal('shares') ?? <String, dynamic>{};

      if (remaining > 0 && shares is Map) {
        double totalAssigned = 0.0;
        shares.forEach((k, v) {
          if (v is num) totalAssigned += v.toDouble();
        });

        if (totalAssigned > 0) {
          final multiplier = (totalAssigned + remaining) / totalAssigned;
          final newShares = <String, dynamic>{};
          shares.forEach((k, v) {
            if (v is num) {
              newShares[k] = v * multiplier;
            } else {
              newShares[k] = v;
            }
          });
          ctx.setGlobal('shares', newShares);
          ctx.setGlobal('remainingShare', 0.0);
          ctx.log('applyRadd: Radd applied with multiplier $multiplier');
        }
      }
    });
  }

  double _normalizeShare(dynamic rawShare, RuleContext ctx) {
    if (rawShare is num) return rawShare.toDouble();

    if (rawShare is String) {
      if (rawShare.contains('/')) {
        final parts = rawShare.split('/');
        if (parts.length == 2) {
          final n = double.tryParse(parts[0]);
          final d = double.tryParse(parts[1]);
          if (n != null && d != null && d != 0) return n / d;
        }
      }
      return double.tryParse(rawShare) ?? 0.0;
    }

    return 0.0;
  }
}
