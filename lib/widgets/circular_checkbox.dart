import 'package:flutter/material.dart';

class CircularCheckBox extends StatefulWidget {
  const CircularCheckBox({super.key});

  @override
  _CircularCheckBoxState createState() => _CircularCheckBoxState();
}

class _CircularCheckBoxState extends State<CircularCheckBox> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
              color: _isChecked ? Colors.black : Colors.white,
            ),
            child: _isChecked
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        const Text('Я принимаю условия пользования'),
      ],
    );
  }
}
