import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';
import 'screens/toyosaki_login_screen_jwt.dart';
import 'providers/producto_provider.dart';
import 'providers/categoria_provider.dart';
import 'providers/inventario_provider.dart';
import 'providers/sucursales_provider.dart';
import 'providers/entrada_provider.dart';
import 'providers/salida_provider.dart';
import 'providers/proveedor_provider.dart';
import 'providers/auth_provider_jwt.dart';
import 'widgets/auth_wrapper_jwt.dart';

void main() {
  runApp(const InventarioAppJWT());
}

class InventarioAppJWT extends StatelessWidget {
  const InventarioAppJWT({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviderJWT()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => SucursalesProvider()),
        ChangeNotifierProvider(create: (_) => EntradaProvider()),
        ChangeNotifierProvider(create: (_) => SalidaProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
      ],
      child: MaterialApp(
        title: 'TOYOSAKI - Sistema JWT',
        theme: ThemeData(
          // Colores principales de TOYOSAKI
          primarySwatch: MaterialColor(0xFF1565C0, {
            50: Color(0xFFE3F2FD),
            100: Color(0xFFBBDEFB),
            200: Color(0xFF90CAF9),
            300: Color(0xFF64B5F6),
            400: Color(0xFF42A5F5),
            500: Color(0xFF2196F3),
            600: Color(0xFF1E88E5),
            700: Color(0xFF1976D2),
            800: Color(0xFF1565C0),
            900: Color(0xFF0D47A1),
          }),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1565C0),
            elevation: 0,
            centerTitle: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const AuthWrapperJWT(),
          '/login': (context) => const ToyosakiLoginScreenJWT(),
          '/home': (context) => const HomeScreen(),
          '/productos': (context) => const ProductosScreen(),
          '/entradas': (context) => const EntradasScreen(),
          '/salidas': (context) => const SalidasScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
