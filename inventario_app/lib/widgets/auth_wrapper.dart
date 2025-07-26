import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_jwt.dart';
import '../screens/home_screen.dart';
import '../screens/toyosaki_login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderJWT>(
      builder: (context, authProvider, child) {
        // Mostrar loading si está cargando
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF1565C0),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TOYOSAKI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cargando...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si está autenticado, mostrar la app principal
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // Si no está autenticado, mostrar login
        return const ToyosakiLoginScreen();
      },
    );
  }
}
