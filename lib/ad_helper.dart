import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdHelper {
  static InterstitialAd? _interstitialAd;

  // 🔴 REPLACE WITH YOUR ADMOB ID
  static String get adUnitId =>
      'ca-app-pub-3940256099942544/1033173712'; // TEST ID

  // 🔄 LOAD AD
  static void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print("Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          print("Ad Failed: $error");
        },
      ),
    );
  }

  // ▶️ SHOW AD
  static void showAd(VoidCallback onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd(); // load next ad
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onAdClosed();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print("Ad not ready");
      onAdClosed();
    }
  }
}
