import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkUtils {
  static Future<bool> hasInternetConnection() async {
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();

    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}