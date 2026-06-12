import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/app/states/auth/auth_state.dart';
import 'package:kaysir/routes/redirect_config.dart';

void main() {
  test('loading auth state does not redirect', () {
    expect(
      resolveRedirectPath(AuthenticationState.initial(), dashboardRoute),
      isNull,
    );
  });

  test('unauthenticated users stay on login and are sent there otherwise', () {
    const state = AuthenticationState(isLoading: false);

    expect(resolveRedirectPath(state, loginRoute), isNull);
    expect(resolveRedirectPath(state, '/'), loginRoute);
    expect(resolveRedirectPath(state, dashboardRoute), loginRoute);
    expect(resolveRedirectPath(state, '/inventory'), loginRoute);
  });

  test('authenticated users leave login and can use app routes', () {
    const state = AuthenticationState(isAuthenticated: true, isLoading: false);

    expect(resolveRedirectPath(state, loginRoute), dashboardRoute);
    expect(resolveRedirectPath(state, '/'), isNull);
    expect(resolveRedirectPath(state, dashboardRoute), isNull);
    expect(resolveRedirectPath(state, '/cashier'), isNull);
  });

  test('first-time flag does not redirect to an unregistered route', () {
    const state = AuthenticationState(isFirstTime: true, isLoading: false);

    expect(resolveRedirectPath(state, dashboardRoute), loginRoute);
  });
}
