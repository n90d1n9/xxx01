import 'package:flutter/material.dart';

/// Presents consistent floating snackbars for board feedback.
class BoardSnackBarPresenter {
  const BoardSnackBarPresenter();

  /// Builds the snackbar used by board feedback surfaces.
  SnackBar snackBar(String message, {SnackBarAction? action}) {
    return SnackBar(
      content: Text(message),
      action: action,
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Shows a snackbar through the nearest scaffold messenger.
  void show(BuildContext context, String message, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(snackBar(message, action: action));
  }
}
