import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:timetable/core/toast.dart';
import 'package:timetable/service/storage.dart';

import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';

class BiometricsPage extends StatelessWidget {
  BiometricsPage({super.key}) {
    _startAuthentication();
  }

  void _startAuthentication() async {
    try {
      if (!await LocalAuthentication().canCheckBiometrics ||
          !await LocalAuthentication().isDeviceSupported()) {
        return;
      }

      await LocalAuthentication().stopAuthentication();
      await LocalAuthentication()
          .authenticate(
        localizedReason: 'Bitte App entsperren',
        options: const AuthenticationOptions(
          stickyAuth: true,
          sensitiveTransaction: false,
          biometricOnly: true,
          useErrorDialogs: false,
        ),
      )
          .then((success) {
        if (success) {
          store.dispatch(redux.setLockState(false));
        }
      });
    } catch (e) {
      showErrorToast('Biometrische Authentifizierung fehlgeschlagen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Icon(
                Icons.fingerprint,
                size: 200.0,
                color: Theme.of(context).dividerColor.withOpacity(0.54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: TextButton(
                onPressed: _startAuthentication,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: const Text(
                  'App entsperren',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                clearStorage();
                store.dispatch(redux.clear());
              },
              child: const Text('App zurücksetzen'),
            ),
          ],
        ),
      ),
    );
  }
}
