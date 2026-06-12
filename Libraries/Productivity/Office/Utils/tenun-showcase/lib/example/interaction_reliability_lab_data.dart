import 'dart:math' as math;

import 'package:tenun_pro/tenun_pro.dart';

class InteractionReliabilitySeries {
  const InteractionReliabilitySeries({
    required this.signal,
    required this.volume,
  });

  final List<double> signal;
  final List<double> volume;
}

InteractionReliabilitySeries buildInteractionReliabilitySeries(int points) {
  final signal = List.generate(points, (i) {
    final x = i.toDouble();
    final seasonal = 70 + 21 * math.sin(x * 0.014) + 9 * math.sin(x * 0.22);
    final localPulse = 5 * math.sin(x * 0.63);
    final drift = (i % 120) * 0.035;
    return (seasonal + localPulse + drift).toDouble();
  }, growable: false);

  final volume = List.generate(points, (i) {
    final x = i.toDouble();
    final base = 45 + 15 * math.cos(x * 0.018) + 7 * math.sin(x * 0.07);
    final periodic = (i % 30) * 0.6;
    return (base + periodic).abs().toDouble();
  }, growable: false);

  return InteractionReliabilitySeries(signal: signal, volume: volume);
}

List<double> extractInteractionDrillData(DrillDownLevel level) {
  final raw = level.data;
  if (raw is List<double>) {
    return raw;
  }
  if (raw is List) {
    return raw
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList(growable: false);
  }
  return const <double>[];
}

List<double> aggregateInteractionReliabilityData(
  List<double> source, {
  required int buckets,
}) {
  if (source.isEmpty || buckets <= 0) return const <double>[];

  final result = <double>[];
  final len = source.length;
  final step = math.max(1, (len / buckets).ceil());

  for (int i = 0; i < len; i += step) {
    final end = math.min(i + step, len);
    double sum = 0;
    for (int j = i; j < end; j++) {
      sum += source[j];
    }
    result.add(sum / (end - i));
  }

  return result;
}

List<double> trimInteractionReliabilityData(
  List<double> source, {
  required int maxPoints,
}) {
  if (source.length <= maxPoints) return source;
  final step = math.max(1, (source.length / maxPoints).ceil());
  final output = <double>[];
  for (int i = 0; i < source.length; i += step) {
    output.add(source[i]);
  }
  return output;
}
