import 'package:flutter/material.dart';

class WhatasppStickers extends StatelessWidget {
  const WhatasppStickers({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // use Theme.of(context).scaffoldBackgroundColor if needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sticky_note_2_rounded,
              size: 100,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "Coming Soon",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "WhatsApp Stickers feature will be available soon!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
