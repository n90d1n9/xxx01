import '../models/reservation_qr_session_section_plan.dart';
import '../models/reservation_qr_session_state.dart';

/// Builds the ordered section plan for a reservation QR session panel.
class RestaurantReservationQrSessionSectionPresenter {
  const RestaurantReservationQrSessionSectionPresenter();

  RestaurantReservationQrSessionSectionPlan build(
    RestaurantReservationQrSessionState state, {
    bool showActivityTrail = true,
  }) {
    return RestaurantReservationQrSessionSectionPlan(
      sections: [
        if (!state.isIdle) RestaurantReservationQrSessionSection.summary,
        if (state.hasActiveLink)
          RestaurantReservationQrSessionSection.activeLink,
        if (state.hasScanResult)
          RestaurantReservationQrSessionSection.scanStatus,
        if (state.hasSelectedAction)
          RestaurantReservationQrSessionSection.selectedAction,
        if (showActivityTrail && state.hasActivityTrail && !state.isIdle)
          RestaurantReservationQrSessionSection.activityTrail,
      ],
    );
  }
}
