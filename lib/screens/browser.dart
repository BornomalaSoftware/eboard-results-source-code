// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nid/screens/about.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nid/admanager.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key, required this.url, this.analytics, this.observer})
      : super(key: key);

  final String url;
  final FirebaseAnalytics? analytics;
  final FirebaseAnalyticsObserver? observer;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with TickerProviderStateMixin {
  late final WebViewController _controller;

  // Start :: BannerAd ---------------------------------------------------------

  BannerAd? _bannerAd;

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _bannerAd = ad as BannerAd?;
          });
          widget.analytics!.logEvent(
            name: "browser_banner_ad_loaded",
            parameters: {
              "full_text": "Browser's Banner Ad Loaded",
            },
          );
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_failed_to_load",
            parameters: {
              "full_text": "Browser's Banner Ad Failed To Load",
            },
          );
          ad.dispose();
        },
        onAdOpened: (Ad ad) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_opened",
            parameters: {
              "full_text": "Browser's Banner Ad Opened",
            },
          );
        },
        onAdClosed: (Ad ad) {
          widget.analytics!.logEvent(
            name: "browser_banner_ad_closed",
            parameters: {
              "full_text": "Browser's Banner Ad Closed",
            },
          );
        },
      ),
    );
    _bannerAd!.load();
  }
  // End :: BannerAd -----------------------------------------------------------

  // Start :: InterstitialAd ---------------------------------------------------
  void showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
          widget.analytics!.logEvent(
            name: "browser_interstitialad_loaded_and_shown",
            parameters: {
              "full_text": "Browser's InterstitialAd Loaded And Shown",
            },
          );
        },
        onAdFailedToLoad: (err) {
          widget.analytics!.logEvent(
            name: "browser_interstitialad_failed_to_load",
            parameters: {
              "full_text": "Browser's InterstitialAd Failed To Load",
            },
          );
        },
      ),
    );
  }
  // End :: InterstitialAd -----------------------------------------------------

  // Declare :: ProgressController ---------------------------------------------
  late AnimationController progressController;
  bool determinate = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'BrowserPage',
    );

    loadBannerAd();

    // Start :: ProgressController ----------------------------
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });
    progressController.repeat();
    // End :: ProgressController ------------------------------

    // Start :: WebViewController -----------------------------
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _cleanUI();
            progressController.value = progress / 100;
            if (progress == 100) {
              progressController.stop();
            }
          },
          onPageStarted: (String url) {
            progressController.value = 0;
          },
          onPageFinished: (String url) {
            progressController.value = 0;
          },
          onWebResourceError: (WebResourceError error) {
            SnackBar(
                content: const Text('Something went wrong!'),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)));
          },

          // Handle Requests
          onNavigationRequest: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            // debugPrint('url change to ${change.url}');
            FirebaseAnalytics.instance.logEvent(
              name: "browser_url_change",
              parameters: {
                "full_text": "Url change to ${change.url}",
              },
            );
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(message.message),
                backgroundColor: Colors.black54,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    // End :: WebViewController -------------------------------
  }

  // Start :: RemoveHeader&Footer ----------------------------------------------
  Future<void> _cleanUI() async {
    await _controller.runJavaScript(
        "javascript:(function() {document.getElementById('main_header2').style.display='none'; document.getElementById('twitter-follow').style.display='none'; document.getElementsByClassName('row')[0].style.display='none';  document.getElementById('page-wrapper').style.backgroundColor='transparent'; document.getElementsByClassName('panel-heading')[0].style.display='none'; document.getElementsByClassName('panel panel-default')[0].style.border='none'; document.getElementsByClassName('panel panel-default')[0].style.backgroundColor='transparent'; document.getElementsByClassName('panel panel-default')[0].style.boxShadow='none'; document.getElementById('captcha_img').style.width='100%'; document.getElementById('captcha_img').style.padding='20px'; document.getElementById('captcha').style.display='block'; document.getElementById('captcha').style.width='100%'; document.getElementById('submit').style.width='100%'; document.getElementById('dev_info').style.display='none';})()");
  }
  // End :: RemoveHeader&Footer ------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.numbers_outlined, color: Colors.black45),
          title: const Text('eBoardResults',
              style: TextStyle(color: Colors.black45, fontSize: 15)),
          actions: <Widget>[
            IconButton(
                icon:
                    const Icon(Icons.refresh_rounded, color: Colors.black45),
                onPressed: () {
                  showInterstitialAd();
                  // _controller.clearCache();
                  _controller.reload();
                }),
            IconButton(
                icon: const Icon(Icons.info_outline_rounded,
                    color: Colors.black45),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const About()));
                }),
          ],
        ),
        body: Column(
          
          children: [
            // Start :: LinearProgressIndicator ----------------------------
            LinearProgressIndicator(
              value: progressController.value,
            ),
            // End :: LinearProgressIndicator ------------------------------

            // Start :: WebView --------------------------------------------
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            // End :: WebView ----------------------------------------------

            // const SizedBox(
            //   height: 5,
            // ),
            const LinearProgressIndicator(
              value: 0,
            ),

            // Start :: BannerAd -------------------------------------------
            if (_bannerAd != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              )
            // End :: BannerAd ----------------------------------------------
          ],
        ),
      ),
    );
  }
}
