import 'package:flutter/material.dart';

Widget inputField({
  required TextEditingController controller,
  required VoidCallback onSendPressed,
}) {
  return Container(
    padding: const EdgeInsets.all(8.0), // Add padding around the input field
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      children: [
        // Input Field
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4F4), // Light gray background
              borderRadius: BorderRadius.circular(24), // Rounded edges
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Aa',
                border: InputBorder.none, // Remove default border
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0), // Space between input and button

        // Send Button
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFC575C7), // Purple background for the send button
            shape: BoxShape.circle,   // Circular shape for the button
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white), // Purple arrow icon
            onPressed: onSendPressed,
          ),
        ),
      ],
    ),
  );
}
