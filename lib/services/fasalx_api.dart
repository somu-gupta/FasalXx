import '../core/config/api_bases.dart';
import '../core/network/api_client.dart';

class FasalxApi {
  FasalxApi._();

  static final main = ApiClient(ApiBases.main);
  static final timeline = ApiClient(ApiBases.timeline);
  static final recommendation = ApiClient(ApiBases.recommendation);
}
