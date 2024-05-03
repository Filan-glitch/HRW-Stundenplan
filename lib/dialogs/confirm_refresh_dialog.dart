import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/redux/actions.dart' as redux;
import '../pages/login_page.dart';
import '../service/network_fetch.dart';
import '../service/storage.dart';
import '../widgets/dialog_wrapper.dart';

class ConfirmRefreshDialog extends StatefulWidget {
  const ConfirmRefreshDialog({super.key});

  @override
  State<ConfirmRefreshDialog> createState() => _ConfirmRefreshDialogState();
}

class _ConfirmRefreshDialogState extends State<ConfirmRefreshDialog> {
  bool keepEditedOnReload = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      builder: (context, state) {
        return DialogWrapper(
          title: 'Daten aktualisieren',
          children: [
            const Text(
              'Sollen die Daten aktualisiert werden?',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    LoginPage.performLogin(
                      onLoginSuccess: () async => await reloadAll(
                        keepEdited: keepEditedOnReload,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Ja'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nein'),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text(
                'Nicht erneut fragen',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              value: !state.enableConfirmRefreshDialog,
              onChanged: (value) {
                store.dispatch(
                  redux.setEnableConfirmRefreshDialog(value == false),
                );
                writeEnableConfirmRefreshDialog();
              },
            ),
            CheckboxListTile(
              title: const Text(
                'Bearbeitete Termine erhalten',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              value: keepEditedOnReload,
              onChanged: (value) {
                setState(() {
                  keepEditedOnReload = value == true;
                });
              },
            ),
          ],
        );
      },
      converter: (store) => store.state,
    );
  }
}
