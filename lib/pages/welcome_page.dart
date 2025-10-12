import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timetable/model/redux/actions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import '../model/constants.dart';
import '../model/redux/store.dart';
import '../service/db/grades.dart';
import '../service/network_fetch.dart';
import '../service/storage.dart';
import 'home_page.dart';
import 'login_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<StatefulWidget> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isChecked = false;
  int _versionTapCount = 0;
  DateTime? _lastTapTime;

  void _performGuestLogin() async {
    await loadWeekInterval();
    // Warten, bis alle asynchronen Operationen abgeschlossen sind
    await Future.delayed(const Duration(milliseconds: 200));
    await fetchAccountData(isGuest: true);
    await writeAccount(isGuest: true);
    await writeGPA(isGuest: true);
    await writeGradesToStorage(isGuest: true);
    store.dispatch(setIsGuest(true));
    // Navigation wie nach Login (direkter Page Call)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _onVersionTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _versionTapCount = 1;
    } else {
      _versionTapCount++;
    }
    _lastTapTime = now;
    if (_versionTapCount >= 5) {
      _performGuestLogin();
      _versionTapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Column(
            children: [
              Text('Willkommen!', style: TextStyle(fontSize: 30.0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('bei der ', style: TextStyle(fontSize: 20.0)),
                  Text('inoffiziellen',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ],
              ),
              Text(
                'CampusNet',
                style: TextStyle(
                  fontSize: 32.0,
                ),
              ),
              Text('Stundenplan App', style: TextStyle(fontSize: 22.0)),
              Text('des Institut Informatik', style: TextStyle(fontSize: 17.0)),
              Text('(veraltet)', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.disabled))
                          return Colors.grey;
                        return null;
                      },
                    ),
                    enableFeedback: (_isChecked) ? true : false,
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: (_isChecked)
                      ? () async {
                          LoginPage.performLogin(onLoginSuccess: () async {
                            await loadWeekInterval();
                            await fetchGradeData().then((_) {
                              writeGradesToStorage();
                              writeGPA();
                            });
                            await fetchAccountData().then((_) {
                              writeAccount();
                            });
                          });
                        }
                      : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward),
                      Padding(
                        padding: EdgeInsets.all(
                          10.0,
                        ),
                        child: Text('CampusNet Login'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        }),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              style: TextStyle(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withAlpha(178),
                              ),
                              text: 'Ich akzeptiere die '),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              decoration: TextDecoration.underline,
                            ),
                            text: 'Nutzungsbedingungen',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(
                                  Uri.parse(
                                    TERMS_URL,
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withAlpha(178),
                            ),
                            text: ' und ',
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              decoration: TextDecoration.underline,
                            ),
                            text: 'Datenschutzrichtlinie',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(
                                  Uri.parse(
                                    PRIVACY_URL,
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withAlpha(178),
                            ),
                            text:
                                ' und nehme eindeutig zur Kenntnis, dass alle Angaben ohne Gewähr sind und der ',
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context).dividerColor,
                              decoration: TextDecoration.underline,
                            ),
                            text: 'Haftungsausschluss',
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(
                                  Uri.parse(
                                    DISCLAIMER_URL,
                                  ),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                          ),
                          TextSpan(
                            style: TextStyle(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withAlpha(178),
                            ),
                            text: ' gilt.',
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          FutureBuilder(
            future: rootBundle.loadString('pubspec.yaml'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GestureDetector(
                  onTap: _onVersionTap,
                  child: Text(
                    'Version: ${loadYaml(
                      snapshot.data.toString(),
                    )["version"].split("+").first}',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Theme.of(context).dividerColor.withAlpha(178),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
