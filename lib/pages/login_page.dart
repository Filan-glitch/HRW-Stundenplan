import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:timetable/core/toast.dart';

import '../model/constants.dart';
import '../model/login_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static Completer<bool>? _loginCompleter;
  static Future<void> Function()? _onLoginSuccess;

  static Future<bool> hasActiveSession() async {
    store.dispatch(redux.startTask());

    final String identityPageContent = (await http
            .get(Uri.parse('https://dsf.hs-ruhrwest.de/IdentityServer/')))
        .body;

    store.dispatch(redux.stopTask());

    return identityPageContent.contains('Logout');
  }

  static Future<bool> performLogin(
      {required Future<void> Function() onLoginSuccess}) async {
    if (store.state.loginFormState != LoginFormState.notShown) {
      return Future.value(false);
    }
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      return Future.value(false);
    }

    _onLoginSuccess = onLoginSuccess;
    _loginCompleter = Completer();
    store.dispatch(redux.setLoginFormState(LoginFormState.background));

    return _loginCompleter!.future;
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _cancelLogin() {
    store.dispatch(redux.setLoginFormState(LoginFormState.notShown));

    if (LoginPage._loginCompleter != null &&
        !LoginPage._loginCompleter!.isCompleted) {
      LoginPage._loginCompleter!.complete(false);
    }
  }

  final GlobalKey<State<InAppWebView>> _webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusNet Login'),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          _cancelLogin();
        },
        child: InAppWebView(
          key: _webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(LOGIN_URL)),
          shouldOverrideUrlLoading: _onNavigationRequest,
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            isInspectable: kDebugMode,
            forceDark: ForceDark.ON,
            algorithmicDarkeningAllowed: true,
            mediaType: 'text/html',
          ),
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'cancel',
              callback: (args) {
                _cancelLogin();
              },
            );
          },
          onLoadStop: (controller, url) {
            if (!url.toString().contains('IdentityServer/Account/Login')) {
              return;
            }
            _injectCancelJS(controller);
          },
        ),
      ),
    );
  }

  Future<NavigationActionPolicy> _onNavigationRequest(
      InAppWebViewController controller, NavigationAction action) async {
    final String url = action.request.url.toString();

    if (url.startsWith(BASE_URL) && url.contains('PRGNAME=LOGINCHECK')) {
      _handleLogin(url);
      return NavigationActionPolicy.CANCEL;
    }

    if (url.contains('Account/Login') &&
        store.state.loginFormState != LoginFormState.inputRequired) {
      store.dispatch(redux.setLoginFormState(LoginFormState.inputRequired));
    }

    return NavigationActionPolicy.ALLOW;
  }

  void _handleLogin(String url) {
    String? args, cnsc;
    final Uri link = Uri.parse(url);
    http.get(link).then((response) async {
      if (LoginPage._loginCompleter!.isCompleted) return;

      // extract ARGUMENTS
      String startpageLink = response.headers['refresh'] ?? '';
      startpageLink = startpageLink.replaceAll('0; URL=', '');
      args =
          Uri.parse(startpageLink).queryParameters['ARGUMENTS']?.split(',')[0];

      // extract CNSC
      if (response.headers['set-cookie'] != null) {
        for (String cookieString
            in response.headers['set-cookie']!.split(',')) {
          if (!cookieString.contains('cnsc')) continue;
          cnsc = cookieString.split(';')[0].split('=')[1];
        }
      }

      store.dispatch(redux.setLoginFormState(LoginFormState.notShown));

      if (args != null && cnsc != null) {
        store.dispatch(redux.setCredentials(args, cnsc));

        await LoginPage._onLoginSuccess!();

        writeCredentials().then((value) {
          if (!LoginPage._loginCompleter!.isCompleted) {
            LoginPage._loginCompleter!.complete(true);
          }
        });
      } else {
        if (!LoginPage._loginCompleter!.isCompleted) {
          LoginPage._loginCompleter!.complete(false);
        }
        showErrorToast('Es ist ein Fehler aufgetreten');
      }
    });
  }

  void _injectCancelJS(InAppWebViewController controller) {
    controller.evaluateJavascript(
      source:
          """document.querySelector('button[value=cancel]').onclick = () => window.flutter_inappwebview.callHandler('cancel');""",
    );
  }
}
