import 'flavors.dart';
import 'main.dart' as main_app;

void main() {
  F.appFlavor = Flavor.partner;
  main_app.main();
}
