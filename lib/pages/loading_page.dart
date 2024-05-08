import 'package:flutter/material.dart';
import 'package:timetable/model/redux/store.dart';
import '../model/redux/actions.dart' as redux;
import 'package:timetable/service/storage.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: SizedBox(
                height: 150.0,
                width: 150.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  strokeWidth: 3.0,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Bitte warten...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
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
