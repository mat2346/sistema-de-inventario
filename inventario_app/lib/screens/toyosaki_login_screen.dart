import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_jwt.dart';
import '../theme/toyosaki_colors.dart';
import '../services/credentials_storage.dart';

class ToyosakiLoginScreen extends StatefulWidget {
  const ToyosakiLoginScreen({super.key});

  @override
  State<ToyosakiLoginScreen> createState() => _ToyosakiLoginScreenState();
}

class _ToyosakiLoginScreenState extends State<ToyosakiLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberCredentials = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadSavedCredentials();
  }

  /// Cargar credenciales guardadas al inicializar
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await CredentialsStorage.getSavedCredentials();
      if (mounted) {
        setState(() {
          _nombreController.text = credentials['username'] ?? '';
          _passwordController.text = credentials['password'] ?? '';
          _rememberCredentials = credentials['remember'] ?? false;
        });
      }
    } catch (e) {
      //error
    }
  }

  /// Limpiar credenciales guardadas
  Future<void> _clearSavedCredentials() async {
    try {
      await CredentialsStorage.clearCredentials();
      if (mounted) {
        setState(() {
          _nombreController.clear();
          _passwordController.clear();
          _rememberCredentials = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Credenciales guardadas eliminadas'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      //error
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nombreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProviderJWT>(context, listen: false);
      await authProvider.login(
        _nombreController.text,
        _passwordController.text,
      );

      // Guardar credenciales si el login fue exitoso
      await CredentialsStorage.saveCredentials(
        username: _nombreController.text,
        password: _passwordController.text,
        remember: _rememberCredentials,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Bienvenido a TOYOSAKI! 🎉'),
            backgroundColor: ToyosakiColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de acceso: ${e.toString()}'),
            backgroundColor: ToyosakiColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo y encabezado
                      _buildHeader(),
                      const SizedBox(height: 48),

                      // Formulario
                      _buildLoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo circular
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: ToyosakiColors.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ToyosakiColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.car_repair_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // Título principal
        Text(
          'TOYOSAKI',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: ToyosakiColors.primaryBlue,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // Subtítulo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: ToyosakiColors.secondaryYellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Repuestos Automotrices',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ToyosakiColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Sistema de Inventario',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),

        // Indicador de credenciales guardadas
        if (_nombreController.text.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ToyosakiColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ToyosakiColors.accentGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  color: ToyosakiColors.accentGreen,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Credenciales guardadas',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ToyosakiColors.accentGreen,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo de usuario
            _buildTextField(
              controller: _nombreController,
              label: 'Usuario',
              hint: 'Ingresa tu usuario',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de contraseña
            _buildTextField(
              controller: _passwordController,
              label: 'Contraseña',
              hint: 'Ingresa tu contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese su contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Checkbox para recordar credenciales
            _buildRememberCheckbox(),
            const SizedBox(height: 32),

            // Botón de login
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ToyosakiColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1.5),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ToyosakiColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: ToyosakiColors.primaryBlue,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildRememberCheckbox() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: _rememberCredentials,
            onChanged: (value) {
              setState(() {
                _rememberCredentials = value ?? false;
              });
            },
            activeColor: ToyosakiColors.primaryBlue,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Recordar mis credenciales',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ToyosakiColors.primaryBlue,
            ),
          ),
        ),
        if (_rememberCredentials)
          Icon(
            Icons.security_outlined,
            color: ToyosakiColors.accentGreen,
            size: 18,
          ),
        if (_nombreController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty)
          GestureDetector(
            onTap: _clearSavedCredentials,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.clear, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Limpiar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: ToyosakiColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : const Text(
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
      ),
    );
  }
}
