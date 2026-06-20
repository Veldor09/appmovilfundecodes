import 'package:flutter/material.dart';
import '../app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                child: Icon(Icons.volunteer_activism, size: 52, color: Colors.white),
              ),
              SizedBox(height: 24),
              Text(
                'FUNDECODES',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Gestión de Voluntariado',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ],
          ),
        ),
      ),
    );
  }
}
