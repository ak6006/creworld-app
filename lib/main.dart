import 'dart:async';

import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

String selectedUrl = 'https://portal.crewsa.net/';

// ignore: prefer_collection_literals
final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
      }),
].toSet();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => const MyHomePage(title: 'Flutter WebView Demo'),
        '/widget': (_) {
          return WebviewScaffold(
            url: selectedUrl,
            // javascriptChannels: jsChannels,
            //mediaPlaybackRequiresUserGesture: false,
            appBar: AppBar(
              title: const Text('Widget WebView'),
            ),
            withZoom: true,
            withLocalStorage: true,
            hidden: true,
            initialChild: Container(
              color: Colors.redAccent,
              child: const Center(
                child: Text('Waiting.....'),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      flutterWebViewPlugin.goBack();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      flutterWebViewPlugin.goForward();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.autorenew),
                    onPressed: () {
                      flutterWebViewPlugin.reload();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On destroy stream
  late StreamSubscription _onDestroy;

  // On urlChanged stream
  late StreamSubscription<String> _onUrlChanged;

  // On urlChanged stream
  late StreamSubscription<WebViewStateChanged> _onStateChanged;

  late StreamSubscription<WebViewHttpError> _onHttpError;

  late StreamSubscription<double> _onProgressChanged;

  late StreamSubscription<double> _onScrollYChanged;

  late StreamSubscription<double> _onScrollXChanged;

  final _urlCtrl = TextEditingController(text: selectedUrl);

  final _codeCtrl = TextEditingController(text: 'window.navigator.userAgent');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _history = [];

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();

    _urlCtrl.addListener(() {
      selectedUrl = _urlCtrl.text;
    });

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebViewPlugin.onDestroy.listen((_) {
      if (mounted) {
        // Actions like show a info toast.
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Webview Destroyed')));
      }
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          _history.add('onUrlChanged: $url');
        });
      }
    });

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      if (mounted) {
        setState(() {
          _history.add('onProgressChanged: $progress');
        });
      }
    });

    _onScrollYChanged =
        flutterWebViewPlugin.onScrollYChanged.listen((double y) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in Y Direction: $y');
        });
      }
    });

    _onScrollXChanged =
        flutterWebViewPlugin.onScrollXChanged.listen((double x) {
      if (mounted) {
        setState(() {
          _history.add('Scroll in X Direction: $x');
        });
      }
    });

    _onStateChanged =
        flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        setState(() {
          _history.add('onStateChanged: ${state.type} ${state.url}');
        });
      }
    });

    _onHttpError =
        flutterWebViewPlugin.onHttpError.listen((WebViewHttpError error) {
      if (mounted) {
        setState(() {
          _history.add('onHttpError: ${error.code} ${error.url}');
        });
      }
    });

    //   flutterWebViewPlugin.launch(selectedUrl,appCacheEnabled: true);
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    _onProgressChanged.cancel();
    _onScrollXChanged.cancel();
    _onScrollYChanged.cancel();

    flutterWebViewPlugin.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flutterWebViewPlugin = FlutterWebviewPlugin();
    return Scaffold(
      key: _scaffoldKey,
      body: new WebviewScaffold(
        appCacheEnabled: true,
        url: "https://portal.crewsa.net/",
        // bottomNavigationBar: ,
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(255, 255, 0, 1), //(38, 38, 38, 0.4),
          title: new Text(
            "CreWorld",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                flutterWebViewPlugin.goBack();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
              onPressed: () {
                flutterWebViewPlugin.goForward();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.black,
              ),
              onPressed: () {
                flutterWebViewPlugin
                    .reloadUrl('https://portal.crewsa.net/public/home');
              },
            ),
          ],
        ),
      ),
    );
    //  Scaffold(
    //   key: _scaffoldKey,
    //   appBar: AppBar(
    //     title: const Text('Plugin example app'),
    //   ),
    //   body: SingleChildScrollView(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Container(
    //           padding: const EdgeInsets.all(24.0),
    //           child: TextField(controller: _urlCtrl),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             flutterWebViewPlugin.launch(
    //               selectedUrl,
    //               rect: Rect.fromLTWH(
    //                   0.0, 0.0, MediaQuery.of(context).size.width, 300.0),
    //               userAgent: kAndroidUserAgent,
    //               invalidUrlRegex:
    //                   r'^(https).+(twitter)', // prevent redirecting to twitter when user click on its icon in flutter website
    //             );
    //           },
    //           child: const Text('Open Webview (rect)'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             flutterWebViewPlugin.launch(selectedUrl, hidden: true);
    //           },
    //           child: const Text('Open "hidden" Webview'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             flutterWebViewPlugin.launch(selectedUrl,appCacheEnabled: true);
    //           },
    //           child: const Text('Open Fullscreen Webview'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             Navigator.of(context).pushNamed('/widget');
    //           },
    //           child: const Text('Open widget webview'),
    //         ),
    //         Container(
    //           padding: const EdgeInsets.all(24.0),
    //           child: TextField(controller: _codeCtrl),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             final future =
    //                 flutterWebViewPlugin.evalJavascript(_codeCtrl.text);
    //             future.then((String? result) {
    //               setState(() {
    //                 _history.add('eval: $result');
    //               });
    //             });
    //           },
    //           child: const Text('Eval some javascript'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             final future = flutterWebViewPlugin
    //                 .evalJavascript('alert("Hello World");');
    //             future.then((String? result) {
    //               setState(() {
    //                 _history.add('eval: $result');
    //               });
    //             });
    //           },
    //           child: const Text('Eval javascript alert()'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             setState(() {
    //               _history.clear();
    //             });
    //             flutterWebViewPlugin.close();
    //           },
    //           child: const Text('Close'),
    //         ),
    //         ElevatedButton(
    //           onPressed: () {
    //             flutterWebViewPlugin.getCookies().then((m) {
    //               setState(() {
    //                 _history.add('cookies: $m');
    //               });
    //             });
    //           },
    //           child: const Text('Cookies'),
    //         ),
    //         Text(_history.join('\n'))
    //       ],
    //     ),
    //   ),
    // );
  }
}

// class MyChromeSafariBrowser extends ChromeSafariBrowser {
//   @override
//   void onOpened() {
//     print("ChromeSafari browser opened");
//   }

//   @override
//   void onCompletedInitialLoad() {
//     print("ChromeSafari browser initial load completed");
//   }

//   @override
//   void onClosed() {
//     print("ChromeSafari browser closed");
//   }
// }

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (Platform.isAndroid) {
//     await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
//   }

//   runApp(MaterialApp(home: MyApp()));
// }

// class MyApp extends StatefulWidget {
//   final ChromeSafariBrowser browser = new MyChromeSafariBrowser();

//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     widget.browser.addMenuItem(new ChromeSafariBrowserMenuItem(
//         id: 1,
//         label: 'Custom item menu 1',
//         action: (url, title) {
//           print('Custom item menu 1 clicked!');
//         }));
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ChromeSafariBrowser Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//             onPressed: () async {
//               await widget.browser.open(
//                   url: Uri.parse("https://flutter.dev/"),
//                   options: ChromeSafariBrowserClassOptions(
//                       android: AndroidChromeCustomTabsOptions(
//                           addDefaultShareMenuItem: false,enableUrlBarHiding: true),
                          
//                       ios: IOSSafariOptions(barCollapsingEnabled: true,)));
//             },
//             child: Text("Open Chrome Safari Browser")),
//       ),
//     );
//   }
// }




// class MyInAppBrowser extends InAppBrowser {
//   @override
//   Future onBrowserCreated() async {
//     print("Browser Created!");
//   }

//   @override
//   Future onLoadStart(url) async {
//     print("Started $url");
//   }

//   @override
//   Future onLoadStop(url) async {
//     print("Stopped $url");
//   }

//   @override
//   void onLoadError(url, code, message) {
//     print("Can't load $url.. Error: $message");
//   }

//   @override
//   void onProgressChanged(progress) {
//     print("Progress: $progress");
//   }

//   @override
//   void onExit() {
//     print("Browser closed!");
//   }
// }

// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (Platform.isAndroid) {
//     await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
//   }

//   runApp(
//     MaterialApp(
//       home: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   final MyInAppBrowser browser = new MyInAppBrowser();

//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   var options = InAppBrowserClassOptions(
//       crossPlatform: InAppBrowserOptions(hideUrlBar: false),
//       inAppWebViewGroupOptions: InAppWebViewGroupOptions(
//           crossPlatform: InAppWebViewOptions(javaScriptEnabled: true)));

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('InAppBrowser Example'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//             onPressed: () {
//               widget.browser.openUrlRequest(
//                   urlRequest: URLRequest(url: Uri.parse("https://flutter.dev")),
//                   options: options);
//             },
//             child: Text("Open InAppBrowser")),
//       ),
//     );
//   }
// }


