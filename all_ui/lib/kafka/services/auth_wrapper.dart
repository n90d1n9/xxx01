class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IdentityAccessService.UserPermissions?>(
      stream: _authenticationStream(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return KafkaDashboardScreen(userPermissions: snapshot.data!);
        }

        return LoginScreen();
      },
    );
  }

  Stream<IdentityAccessService.UserPermissions?> _authenticationStream(
    BuildContext context,
  ) {
    final identityService = context.read<IdentityAccessService>();
    final monitoringService =
        context.read<IdentityAccessService.MonitoringService>();

    // Combine authentication and monitoring streams
    return Rx.combineLatest<dynamic, IdentityAccessService.UserPermissions?>([
      // Authentication status stream
      Stream.fromFuture(identityService.authenticateWithOpenID()),
      // Monitoring alerts stream for additional context
      monitoringService.alertsStream,
    ], (values) => values[0]).handleError((error) {
      monitoringService.createAlert(
        type:
            IdentityAccessService
                .MonitoringService
                .AlertType
                .SECURITY_VIOLATION,
        message: 'Authentication failed',
        severity: 5,
        details: error.toString(),
      );
      return null;
    });
  }
}
