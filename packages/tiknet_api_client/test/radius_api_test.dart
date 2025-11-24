import 'package:test/test.dart';
import 'package:tiknet_api_client/tiknet_api_client.dart';


/// tests for RadiusApi
void main() {
  final instance = TiknetApiClient().getRadiusApi();

  group(RadiusApi, () {
    //Future radiusRadacctList() async
    test('test radiusRadacctList', () async {
      // TODO
    });

    //Future radiusRadcheckList() async
    test('test radiusRadcheckList', () async {
      // TODO
    });

    //Future radiusRadreplyList() async
    test('test radiusRadreplyList', () async {
      // TODO
    });

    //Future radiusUserBalancesList() async
    test('test radiusUserBalancesList', () async {
      // TODO
    });

    //Future radiusUserMacsList() async
    test('test radiusUserMacsList', () async {
      // TODO
    });

    //Future radiusUserPlansList() async
    test('test radiusUserPlansList', () async {
      // TODO
    });

  });
}
