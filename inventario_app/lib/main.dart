import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';
import 'providers/producto_provider.dart';
import 'providers/categoria_provider.dart';
import 'providers/inventario_provider.dart';
import 'providers/sucursales_provider.dart';
import 'providers/entrada_provider.dart';
import 'providers/salida_provider.dart';
import 'providers/proveedor_provider.dart';
import 'providers/auth_provider.dart';
import 'widgets/auth_wrapper.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => SucursalesProvider()),
        ChangeNotifierProvider(create: (_) => EntradaProvider()),
        ChangeNotifierProvider(create: (_) => SalidaProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()),
      ],
      child: MaterialApp(
        title: 'TOYOSAKI - Repuestos Automotrices',
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
            seedColor: Color(0xFF1565C0), // Azul principal
            brightness: Brightness.light,
          ).copyWith(
            primary: Color(0xFF1565C0), // Azul TOYOSAKI
            secondary: Color(0xFFFFC107), // Amarillo TOYOSAKI
            tertiary: Color(0xFF2E7D32), // Verde para éxito
            error: Color(0xFFD32F2F), // Rojo para errores
            surface: Color(0xFFF8F9FA), // Gris muy claro para fondos
            onPrimary: Colors.white,
            onSecondary: Colors.black87,
          ),
          useMaterial3: true,
          // AppBar personalizado TOYOSAKI
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
            shadowColor: Color(0xFF1565C0).withOpacity(0.5),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          // Botones personalizados
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: Color(0xFF1565C0).withOpacity(0.4),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Cards personalizadas con sombras
          cardTheme: CardTheme(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            surfaceTintColor: Color(0xFF1565C0).withOpacity(0.05),
          ),
          // Input decorations mejorados
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1565C0).withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1565C0).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            labelStyle: TextStyle(color: Color(0xFF1565C0)),
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIconColor: Color(0xFF1565C0),
            suffixIconColor: Color(0xFF1565C0),
          ),
          // FloatingActionButton personalizado
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFC107),
            foregroundColor: Colors.black87,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/productos': (context) => const ProductosScreen(),
          '/categorias': (context) => const CategoriasScreen(),
          '/inventario': (context) => const InventarioScreen(),
          '/entradas': (context) => const EntradasScreen(),
          '/salidas': (context) => const SalidasScreen(),
        },
      ),
    );
  }
}
