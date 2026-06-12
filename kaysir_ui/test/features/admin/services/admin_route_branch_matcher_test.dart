import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/admin/services/admin_route_branch_matcher.dart';

void main() {
  test('findBestMatchingBranchPathIndex prefers the most specific branch', () {
    expect(
      findBestMatchingBranchPathIndex('/commerce/orders', [
        '/dashboard',
        '/commerce',
        '/commerce/orders',
      ]),
      2,
    );
  });

  test('findBestMatchingBranchPathIndex handles parent and missing routes', () {
    expect(
      findBestMatchingBranchPathIndex('/commerce', [
        '/dashboard',
        '/commerce',
        '/commerce/orders',
      ]),
      1,
    );
    expect(
      findBestMatchingBranchPathIndex('/commerce-reports', [
        '/dashboard',
        '/commerce',
      ]),
      isNull,
    );
  });

  test('branch default detection keeps nested paths navigable', () {
    expect(adminRouteIsBranchDefaultRequest('/projects', '/projects'), isTrue);
    expect(
      adminRouteIsBranchDefaultRequest(
        '/projects/retail-modernization',
        '/projects',
      ),
      isFalse,
    );
    expect(
      adminRouteIsBranchDefaultRequest(
        '/financial-report-release?focus=evidence',
        '/financial-report-release',
      ),
      isFalse,
    );
  });

  test('branch matching ignores query parameters for shell lookup', () {
    expect(
      findBestMatchingBranchPathIndex(
        '/financial-report-release?focus=evidence',
        ['/dashboard', '/financial-report-release'],
      ),
      1,
    );
  });

  test('location scoring prefers exact query shortcuts over base routes', () {
    final location = '/financial-report-release?focus=evidence';
    final shortcutScore = adminRouteLocationMatchScore(
      location,
      '/financial-report-release?focus=evidence',
    );
    final baseScore = adminRouteLocationMatchScore(
      location,
      '/financial-report-release',
    );

    expect(shortcutScore, greaterThan(baseScore));
    expect(
      adminRouteLocationMatchScore(
        '/financial-report-release',
        '/financial-report-release?focus=evidence',
      ),
      -1,
    );
  });
}
