import 'token_storage_stub.dart';
import 'token_storage_io.dart' if (dart.library.html) 'token_storage_web.dart';

// ignore: camel_case_types
class TokenStorage extends TokenStorageImpl {
  TokenStorage({super.storage});
}
