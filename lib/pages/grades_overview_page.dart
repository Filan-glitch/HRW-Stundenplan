import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../dialogs/confirm_refresh_dialog.dart';
import '../model/module.dart';
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../service/network_fetch.dart';
import '../widgets/page_wrapper.dart';
import 'login_page.dart';

class GradesOverviewPage extends StatefulWidget {
  const GradesOverviewPage({super.key});

  @override
  State<GradesOverviewPage> createState() => _GradesOverviewPageState();
}

class _GradesOverviewPageState extends State<GradesOverviewPage> {
  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      simpleDesign: true,
      title: 'Prüfungsergebnisse',
      body: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                if (store.state.enableConfirmRefreshDialog) {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmRefreshDialog(),
                  );
                } else {
                  LoginPage.performLogin(
                    onLoginSuccess: () async => await reloadAll(
                      keepEdited: true,
                    ),
                  );
                }
              },
              child: ListView.builder(
                itemCount: state.modules.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Gesamtnote: ${state.gpa.toString()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    );
                  }

                  final Module module = state.modules[index - 1];
                  if (module.status == Status.passed &&
                      module.creditsAll == 0) {
                    return Container();
                  }

                  return ListTile(
                    title: Text(
                      module.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (module.grade > 0)
                          Row(
                            children: [
                              const Text('Note: '),
                              Text(
                                module.grade.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        if (module.status != Status.open) ...[
                          if (module.creditsAll > 0)
                            Text(
                              'Mögliche Credits: ${module.creditsAll.toString()}',
                            ),
                          if (module.creditsCharged > 0)
                            Text(
                              'Angerechnete Credits: ${module.creditsCharged.toString()}',
                            ),
                        ],
                        if (module.status == Status.passed)
                          const Text(
                            'Status: Bestanden',
                            style: TextStyle(color: Colors.green),
                          ),
                        if (module.status == Status.failed)
                          const Text(
                            'Status: Unvollständig',
                            style: TextStyle(color: Colors.orange),
                          ),
                        if (module.status == Status.open)
                          const Text(
                            'Status: Offen',
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
