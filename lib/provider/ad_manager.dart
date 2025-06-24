import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:pomodoro/provider/pomodoro_provider.dart';

class AdManager extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  
  AdManager() {
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',   //test
      //adUnitId: 'ca-app-pub-2337038661041173/3027483975',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          print('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load rewarded ad: $error');
        },
      ),
    );
  }

  void watchAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          notifyListeners();
          print('User earned 60 coins.');
        },
      );

      _rewardedAd = null;
      _loadRewardedAd();
    } else {
      print('Rewarded ad not ready.');
    }
  }
}
