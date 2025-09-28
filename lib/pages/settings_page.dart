import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';

import '../dialogs/changelog_dialog.dart';
import '../dialogs/crashlytics_dialog.dart';
import '../dialogs/select_default_view.dart';
import '../model/constants.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../service/storage.dart';
import '../widgets/page_wrapper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return PageWrapper(
            simpleDesign: true,
            title: 'Einstellungen',
            body: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 40.0),
                      child: SizedBox(
                        height: 75.0,
                        child: Image.asset(
                          'assets/images/icon.png',
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: rootBundle.loadString('pubspec.yaml'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            'Version: ${loadYaml(
                              snapshot.data.toString(),
                            )["version"].split("+")[0]}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                        return Container();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
                      child: Text(
                        'Jan Bellenberg\nFinn Dilan',
                        style: TextStyle(fontSize: 15.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.account_circle_sharp,
                      ),
                      title: Text(
                        "Angemeldet als: ${state.account ?? "Unbekannter Account"}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Divider(
                        color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.view_comfortable_rounded),
                      title: Text(
                        'Startansicht: ${state.defaultView.text}',
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SelectDefaultViewDialog(),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.bug_report,
                      ),
                      title: const Text('Crashlytics-Zustimmung'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CrashlyticsDialog(),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_answer),
                      title: Text(
                        "Vor dem Aktualisieren fragen: ${state.enableConfirmRefreshDialog ? "Ja" : "Nein"}",
                      ),
                      onTap: () {
                        store.dispatch(redux.setEnableConfirmRefreshDialog(
                          !state.enableConfirmRefreshDialog,
                        ));
                        writeEnableConfirmRefreshDialog();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Divider(
                        color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('Offizielles CampusNet'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            CAMPUS_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: const Text('Was ist neu?'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ChangelogDialog(),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_balance),
                      title: const Text('Lizenzen'),
                      onTap: () {
                        showLicensePage(context: context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.error),
                      title: const Text('Nutzungsbedingungen'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            TERMS_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Datenschutz'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            PRIVACY_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.warning_amber_rounded),
                      title: const Text('Haftungsausschluss'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            DISCLAIMER_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Quellcode'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            SOURCE_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text('Feedback'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            FEEDBACK_URL,
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Impressum'),
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            IMPRINT_URL,
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Divider(
                        color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.logout,
                          color: Colors.red.withAlpha(178)),
                      title: const Text('Abmelden'),
                      onTap: () {
                        Navigator.pop(context);
                        clearStorage();
                        store.dispatch(redux.clear());
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
