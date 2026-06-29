import 'dart:math' as math;
import 'dart:ui';

import 'bone.dart';

class InverseKinematics {
  static void solve(Bone endEffector, Offset target, int iterations) {
    for (var i = 0; i < iterations; i++) {
      _solveIteration(endEffector, target);
    }
  }

  static void _solveIteration(Bone bone, Offset target) {
    if (bone.parent == null) return;

    final currentPos = bone.worldPosition;
    final parentPos = bone.parent!.worldPosition;

    // Calculate angles
    final toTarget = target - parentPos;
    final toCurrent = currentPos - parentPos;

    final angleToTarget = math.atan2(toTarget.dy, toTarget.dx);
    final angleToCurrent = math.atan2(toCurrent.dy, toCurrent.dx);

    // Apply rotation
    bone.parent!.rotation += angleToTarget - angleToCurrent;

    // Recurse up the chain
    _solveIteration(bone.parent!, target);
  }
}
