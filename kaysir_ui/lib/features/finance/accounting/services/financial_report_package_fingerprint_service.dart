import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/financial_close_checklist.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_package_fingerprint.dart';

class FinancialReportPackageFingerprintService {
  static const algorithm = 'SHA-256';

  const FinancialReportPackageFingerprintService();

  FinancialReportPackageFingerprint build({
    required FinancialReportPack pack,
    required FinancialCloseChecklist checklist,
    List<FinancialReportExceptionResolution> exceptionResolutions = const [],
  }) {
    final canonicalJson = jsonEncode({
      'entity': pack.entityName,
      'framework': pack.frameworkName,
      'jurisdiction': pack.jurisdiction,
      'currency': pack.presentationCurrency,
      'taxProfile': {
        'id': pack.taxProfile.id,
        'label': pack.taxProfile.label,
        'rate': _amount(pack.taxProfile.rate),
        'standardReference': pack.taxProfile.standardReference,
        'taxReference': pack.taxProfile.taxReference,
      },
      'period': {
        'label': pack.periodLabel,
        'asOf': pack.asOfLabel,
        'start': pack.periodStart?.toIso8601String(),
        'end': pack.periodEnd?.toIso8601String(),
        'generatedAt': pack.generatedAt.toIso8601String(),
        'comparativeLabel': pack.comparativePeriodLabel,
        'comparativeAsOf': pack.comparativeAsOfLabel,
      },
      'metrics':
          pack.metrics
              .map(
                (metric) => {
                  'label': metric.label,
                  'amount': _amount(metric.amount),
                  'comparative': _amount(metric.comparativeAmount),
                  'helper': metric.helperText,
                },
              )
              .toList(),
      'compliance':
          pack.complianceItems
              .map(
                (item) => {
                  'id': item.id,
                  'title': item.title,
                  'reference': item.standardReference,
                  'satisfied': item.isSatisfied,
                  'variance': _amount(item.variance),
                  'comparativeVariance': _amount(item.comparativeVariance),
                  'materialityThreshold': _amount(item.materialityThreshold),
                  'materialityBasis': item.materialityBasis,
                  'materialVariance': item.isMaterialVariance,
                  'description': item.description,
                },
              )
              .toList(),
      'exceptionResolutions': _exceptionResolutionEvidence(
        exceptionResolutions,
      ),
      'supportingSchedules':
          pack.supportingSchedules
              .map(
                (schedule) => {
                  'kind': schedule.kind.name,
                  'title': schedule.title,
                  'subtitle': schedule.subtitle,
                  'totalLabel': schedule.totalLabel,
                  'references': schedule.standardReferences,
                  'total': _amount(schedule.totalAmount),
                  'comparativeTotal': _amount(schedule.comparativeTotalAmount),
                  'totalOverride': _amount(schedule.totalAmountOverride),
                  'comparativeTotalOverride': _amount(
                    schedule.comparativeTotalAmountOverride,
                  ),
                  'metrics':
                      schedule.metrics
                          .map(
                            (metric) => {
                              'label': metric.label,
                              'value': metric.value,
                              'helper': metric.helperText,
                            },
                          )
                          .toList(),
                  'lines':
                      schedule.lines
                          .map(
                            (line) => {
                              'label': line.label,
                              'amount': _amount(line.amount),
                              'comparative': _amount(line.comparativeAmount),
                              'source': line.sourceCategory,
                              'note': line.noteReference,
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
      'closeChecklist': {
        'periodLabel': checklist.periodLabel,
        'generatedAt': checklist.generatedAt.toIso8601String(),
        'totalDebit': _amount(checklist.totalDebit),
        'totalCredit': _amount(checklist.totalCredit),
        'trialBalanceVariance': _amount(checklist.trialBalanceVariance),
        'items':
            checklist.items
                .map(
                  (item) => {
                    'id': item.id,
                    'title': item.title,
                    'status': item.status.name,
                    'reference': item.reference,
                    'amountLabel': item.amountLabel,
                    'description': item.description,
                  },
                )
                .toList(),
      },
      'statements':
          pack.statements
              .map(
                (statement) => {
                  'kind': statement.kind.name,
                  'title': statement.title,
                  'subtitle': statement.subtitle,
                  'references': statement.standardReferences,
                  'lines':
                      statement.lines
                          .map(
                            (line) => {
                              'label': line.label,
                              'amount': _amount(line.amount),
                              'comparative': _amount(line.comparativeAmount),
                              'type': line.type.name,
                              'indent': line.indentLevel,
                              'note': line.noteReference,
                            },
                          )
                          .toList(),
                },
              )
              .toList(),
      'notes':
          pack.notes
              .map(
                (note) => {
                  'number': note.number,
                  'title': note.title,
                  'body': note.body,
                  'references': note.standardReferences,
                },
              )
              .toList(),
    });

    final digest = sha256.convert(utf8.encode(canonicalJson)).toString();
    return FinancialReportPackageFingerprint(
      algorithm: algorithm,
      hash: digest,
    );
  }

  List<Map<String, Object?>> _exceptionResolutionEvidence(
    List<FinancialReportExceptionResolution> resolutions,
  ) {
    final sorted = [...resolutions]..sort(_compareExceptionResolution);
    return sorted
        .map(
          (resolution) => {
            'exceptionId': resolution.exceptionId,
            'status': resolution.status.name,
            'reviewer': resolution.reviewer,
            'resolvedAt': resolution.resolvedAt.toIso8601String(),
            'note': resolution.note,
            'adjustmentReference': resolution.adjustmentReference,
            'adjustmentPostingId': resolution.adjustmentPostingId,
          },
        )
        .toList();
  }

  int _compareExceptionResolution(
    FinancialReportExceptionResolution left,
    FinancialReportExceptionResolution right,
  ) {
    final exceptionId = left.exceptionId.compareTo(right.exceptionId);
    if (exceptionId != 0) {
      return exceptionId;
    }
    final resolvedAt = left.resolvedAt.compareTo(right.resolvedAt);
    if (resolvedAt != 0) {
      return resolvedAt;
    }
    return left.reviewer.compareTo(right.reviewer);
  }

  String? _amount(double? value) {
    return value?.toStringAsFixed(2);
  }
}
