import 'app_state.dart';

AppState appReducer(AppState state, dynamic updatedState) {
  if (updatedState! is AppState) {
    return state;
  }
  return updatedState;
}
