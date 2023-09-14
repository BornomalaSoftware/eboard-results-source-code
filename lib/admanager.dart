import 'dart:io';

// Start :: AdManager
class AdManager {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2474229370148368/6529850028';
      // } else if (Platform.isIOS) {
      //   return 'ca-app-pub-xxx';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2474229370148368/1798351805";
      // } else if (Platform.isIOS) {
      //   return "ca-app-pub-xxx";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-2474229370148368/8172188466";
      // } else if (Platform.isIOS) {
      //   return "ca-app-pub-xxx";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
// End :: AdManager