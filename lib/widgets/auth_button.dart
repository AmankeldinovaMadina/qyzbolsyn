// lib/widgets/custom_buttons.dart
import 'package:flutter/material.dart';

// Custom Elevated Button
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Take up the whole width
      height: 52, // Set the height to 62
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 62), // Horizontal padding of 62
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFA7BFD), // Button background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Set corner radius to 12
            ),
            padding: EdgeInsets.zero, // No extra padding since we control it via SizedBox
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Custom Outlined Button
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Take up the whole width
      height: 52, // Set the height to 62
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 62), // Horizontal padding of 62
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFA7BFD), width: 2), // Border color and width
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Set corner radius to 12
            ),
            padding: EdgeInsets.zero, // No extra padding since we control it via SizedBox
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Color(0xFFFA7BFD)),
          ),
        ),
      ),
    );
  }
}
