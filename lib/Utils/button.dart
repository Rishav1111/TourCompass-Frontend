import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange[900], // Text color
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 15), // Button padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Button border radius
        ),
        minimumSize: const Size(150, 10), // Minimum button size (width, height)
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
