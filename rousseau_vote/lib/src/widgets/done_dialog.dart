import 'package:flutter/material.dart';
import 'package:rousseau_vote/src/l10n/rousseau_localizations.dart';

class DoneDialog extends StatelessWidget {

  const DoneDialog(this._action);
  
  final Function _action;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      title: Text(
        RousseauLocalizations.getText(context, 'vote-already-done'),
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Text(RousseauLocalizations.getText(context, 'vote-complete'),),
      elevation: 5,
      actions: <Widget>[
        FlatButton(
          child: Text(
            RousseauLocalizations.getText(context, 'back'),
            style: const TextStyle(fontSize: 18),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          onPressed: () => _action(context)
        ),
        Container()
      ],
    );
  }

}