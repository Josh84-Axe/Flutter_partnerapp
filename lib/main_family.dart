import 'flavors.dart';
import 'main.dart' as main_app;

void main() {
  F.appFlavor = Flavor.family;
  main_app.main();
}
