import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AnimatedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
