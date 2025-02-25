// terms_of_service_screen.dart
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользовательское соглашение')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Условия использования',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '1. Общие положения\n'
              '1.1. Настоящее Пользовательское соглашение (далее - Соглашение) регулирует отношения между сервисом и пользователем\n\n'
              '2. Права и обязанности сторон\n'
              '2.1. Пользователь обязуется:\n'
              'а) предоставлять достоверную информацию при регистрации.\n\n'
              '2.2. Сервис обязуется:\n'
              'а) предоставлять достоверную информацию о криптовалютах.\n\n',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}