import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_jwt.dart';
import '../screens/toyosaki_login_screen_jwt.dart';
import '../screens/home_screen.dart';

class AuthWrapperJWT extends StatefulWidget {
  const AuthWrapperJWT({super.key});

  @override
  State<AuthWrapperJWT> createState() => _AuthWrapperJWTState();
}

class _AuthWrapperJWTState extends State<AuthWrapperJWT> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await context.read<AuthProviderJWT>().initialize();
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    return Consumer<AuthProviderJWT>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return _buildLoadingScreen();
        }

        if (authProvider.isAuthenticated &&
            authProvider.currentEmpleado != null) {
          return const HomeScreen();
        }

        return const ToyosakiLoginScreenJWT();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1565C0),
              const Color(0xFF1565C0).withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(Icons.car_repair, size: 80, color: Colors.white),
              SizedBox(height: 24),

              Text(
                'TOYOSAKI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),

              Text(
                'Cargando sistema JWT...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 32),

              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
