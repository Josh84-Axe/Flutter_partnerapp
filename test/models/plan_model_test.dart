import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot_partner_app/models/plan_model.dart';

void main() {
  group('PlanModel', () {
    test('fromJson parses API response correctly', () {
      final json = {
        "id": 37,
        "slug": "30-minutes",
        "profile": 22,
        "profile_name": "30 Minutes",
        "name": "30 Minutes",
        "price": "10.00",
        "price_display": "10 GHS",
        "validity": 16,
        "formatted_validity": "30 Minutes",
        "data_limit": null,
        "shared_users": 14,
        "description": "",
        "is_active": true,
        "is_for_roaming": false,
        "is_for_promo": true,
        "created_at": "2025-08-10T00:24:28.860572Z",
        "validity_value": "30m",
        "shared_users_value": 1,
        "shared_users_label": "1 device"
      };

      final plan = PlanModel.fromJson(json);

      expect(plan.id, 37);
      expect(plan.name, "30 Minutes");
      expect(plan.price, "10.00");
      expect(plan.priceDisplay, "10 GHS");
      expect(plan.dataLimit, null);
      expect(plan.formattedValidity, "30 Minutes");
      expect(plan.sharedUsersLabel, "1 device");
      expect(plan.isActive, true);
    });

    test('fromJson parses API response with data limit correctly', () {
      final json = {
        "id": 40,
        "slug": "connect-extra",
        "name": "CONNECT EXTRA",
        "price": "15.00",
        "price_display": "15 GHS",
        "validity": 19,
        "formatted_validity": "1 Day",
        "data_limit": 5, // 5GB
        "shared_users": 14,
        "shared_users_label": "1 device",
        "is_active": true,
        "validity_value": "1d",
      };

      final plan = PlanModel.fromJson(json);

      expect(plan.id, 40);
      expect(plan.dataLimit, 5);
      expect(plan.formattedValidity, "1 Day");
    });
  });
}
