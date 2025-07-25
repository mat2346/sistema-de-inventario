import 'empleado.dart';

class LoginRequest {
  final String nombre;
  final String password;

  LoginRequest({required this.nombre, required this.password});

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'password': password};
  }
}

class AuthSession {
  final bool authenticated;
  final String? message;
  final Empleado? empleado;
  final String? sessionKey;
  final Map<String, dynamic>? sessionInfo;

  AuthSession({
    required this.authenticated,
    this.message,
    this.empleado,
    this.sessionKey,
    this.sessionInfo,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      authenticated: json['authenticated'] ?? false,
      message: json['message'],
      empleado:
          json['empleado'] != null ? Empleado.fromJson(json['empleado']) : null,
      sessionKey: json['session_key'],
      sessionInfo: json['session_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authenticated': authenticated,
      'message': message,
      'empleado': empleado?.toJson(),
      'session_key': sessionKey,
      'session_info': sessionInfo,
    };
  }

  @override
  String toString() {
    return 'AuthSession(authenticated: $authenticated, message: $message)';
  }
}
