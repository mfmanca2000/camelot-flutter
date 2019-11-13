
import 'package:flutter/material.dart';

class RoundedTextField extends StatelessWidget {
  final hintText;
  final obscureText;
  final enabled;

  RoundedTextField({this.hintText, this.obscureText = false, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      enabled: enabled,
      style: TextStyle(fontFamily: 'Roboto', fontSize: 20.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hintText,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
      );
  }

}