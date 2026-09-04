import 'package:flutter_test/flutter_test.dart';
import 'package:hotspot_partner_app/models/router_configuration_model.dart';

void main() {
  group('RouterConfigurationModel QA Tests', () {
    test('Deserializes bootstrap_token from json payload', () {
      final json = {
        'id': '217',
        'name': 'SalonTogo',
        'slug': 'salontogo',
        'ip_address': '10.0.0.5',
        'bootstrap_token': '-oYCdUNhrEJKIWiTuCJjzqLigrAn1Ccgr3AF7Kb1ItU',
        'is_active': true,
      };

      final model = RouterConfigurationModel.fromJson(json);

      expect(model.id, equals('217'));
      expect(model.name, equals('SalonTogo'));
      expect(model.slug, equals('salontogo'));
      expect(model.ipAddress, equals('10.0.0.5'));
      expect(model.bootstrapToken, equals('-oYCdUNhrEJKIWiTuCJjzqLigrAn1Ccgr3AF7Kb1ItU'));
    });

    test('Serializes bootstrap_token to json map', () {
      final model = RouterConfigurationModel(
        id: '217',
        name: 'SalonTogo',
        slug: 'salontogo',
        bootstrapToken: '-oYCdUNhrEJKIWiTuCJjzqLigrAn1Ccgr3AF7Kb1ItU',
      );

      final json = model.toJson();

      expect(json['bootstrap_token'], equals('-oYCdUNhrEJKIWiTuCJjzqLigrAn1Ccgr3AF7Kb1ItU'));
      expect(json['slug'], equals('salontogo'));
    });
  });
}
