import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(home: Tab3()));

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
<ul><a href="https://www.google.com/">https://nodejs.org/en</a></ul>
</ul>
</body>
</html>
''';

class Tab3 extends StatefulWidget {
  @override
  _Tab3State createState() => _Tab3State();
}

WebViewController controllerGlobal;

Future<bool> _exitApp(BuildContext context) async {
  if (await controllerGlobal.canGoBack()) {
    print("onwill goback");
    controllerGlobal.goBack();
//  } else {
//    Scaffold.of(context).showSnackBar(
//      const SnackBar(content: Text("Je ne fillim te faqes aktuale.")),
//    );
    return Future.value(false);
  }
}

class _Tab3State extends State<Tab3> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    print('Tab3 instantiated');
  }

  @override
  Widget build(BuildContext context) {
    print("Tab3 built");
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            leading: Icon(Icons.monetization_on),
            backgroundColor: const Color(0xff0c120c),
            automaticallyImplyLeading: false,
            title: const Text('Qytetari IN'),
            //This drop down menu demonstrates that Flutter widgets can be shown over the web view.
            actions: <Widget>[
              NavigationControls(_controller.future),
              SampleMenu(_controller.future),
            ],

          ),
        ),

        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: 'https://qytetarin.com/index.php/rreth-nesh/',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            // TODO(iskakaushik): Remove this when collection literals makes it to stable.
            // ignore: prefer_collection_literals
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              if (request.url.startsWith('https://flutter.dev/docs')) {
                print('blocking navigation to $request}');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageFinished: (String url) {
              print('Tab 3 - Page finished loading: $url');
            },
          );
        }),

        floatingActionButton: NavigationControls(_controller.future),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;
  final CookieManager cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data, context);
                break;
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(
      WebViewController controller, BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(
      WebViewController controller, BuildContext context) async {
    final String cookies =
    await controller.evaluateJavascript('document.cookie');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(
      WebViewController controller, BuildContext context) async {
    final String contentBase64 =
    base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}


class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        controllerGlobal = controller;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[

            FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(color: Colors.white)
              ),
              child: const Icon(Icons.refresh),
              mini: true,
              onPressed: !webViewReady
                  ? null
                  : () {
                controller.reload();
              },
            ),
            FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  side: BorderSide(color: Colors.blueGrey)
              ),
              child: const Icon(Icons.arrow_back),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black54,
              elevation: 50.0,
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  controller.goBack();
                } else {
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("Je ne fillim te faqes aktuale!")),
                  );
                  return;
                }
              },
            ),
//            IconButton(
//              icon: const Icon(Icons.arrow_forward_ios),
//              onPressed: !webViewReady
//                  ? null
//                  : () async {
//                if (await controller.canGoForward()) {
//                  controller.goForward();
//                } else {
//                  Scaffold.of(context).showSnackBar(
//                    const SnackBar(
//                        content: Text("Je ne fund te faqes aktuale!")),
//                  );
//                  return;
//                }
//              },
//            ),


          ],

        );
      },
    );
  }
}