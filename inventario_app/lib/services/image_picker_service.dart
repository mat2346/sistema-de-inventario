import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Mostrar bottom sheet para seleccionar fuente de imagen
  static Future<XFile?> showImageSourceActionSheet(BuildContext context) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Seleccionar imagen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Opción: Cámara
                    ListTile(
                      leading: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 28,
                      ),
                      title: const Text('Tomar foto'),
                      subtitle: const Text('Usar la cámara del dispositivo'),
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _pickImageFromCamera();
                        Navigator.pop(context, image);
                      },
                    ),

                    // Opción: Galería
                    ListTile(
                      leading: const Icon(
                        Icons.photo_library,
                        color: Colors.green,
                        size: 28,
                      ),
                      title: const Text('Elegir de galería'),
                      subtitle: const Text('Seleccionar imagen existente'),
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _pickImageFromGallery();
                        Navigator.pop(context, image);
                      },
                    ),

                    const SizedBox(height: 10),

                    // Cancelar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tomar foto desde cámara
  static Future<XFile?> _pickImageFromCamera() async {
    try {
      // Verificar y solicitar permisos de cámara
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        debugPrint('❌ Permiso de cámara denegado');
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('✅ Imagen capturada desde cámara: ${image.path}');
      }

      return image;
    } catch (e) {
      debugPrint('❌ Error al tomar foto: $e');
      return null;
    }
  }

  /// Seleccionar imagen desde galería
  static Future<XFile?> _pickImageFromGallery() async {
    try {
      // Verificar y solicitar permisos de galería
      var galleryStatus = await Permission.photos.request();
      if (!galleryStatus.isGranted) {
        // Para Android, intentar con storage
        galleryStatus = await Permission.storage.request();
        if (!galleryStatus.isGranted) {
          debugPrint('❌ Permiso de galería denegado');
          return null;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint('✅ Imagen seleccionada desde galería: ${image.path}');
      }

      return image;
    } catch (e) {
      debugPrint('❌ Error al seleccionar imagen: $e');
      return null;
    }
  }

  /// Subir imagen a producto específico
  static Future<Map<String, dynamic>> uploadProductImage(
    int productId,
    XFile imageFile,
  ) async {
    try {
      debugPrint('📤 Subiendo imagen para producto $productId...');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/productos/$productId/upload_image/'),
      );

      // Agregar headers
      request.headers.addAll({'Accept': 'application/json'});

      // Agregar archivo de imagen
      request.files.add(
        await http.MultipartFile.fromPath(
          'imagen',
          imageFile.path,
          filename: 'producto_$productId.jpg',
        ),
      );

      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Imagen subida exitosamente');
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Imagen subida exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        debugPrint('❌ Error al subir imagen: ${response.statusCode}');
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error al subir imagen',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Exception al subir imagen: $e');
      return {'success': false, 'error': 'Error de conexión: ${e.toString()}'};
    }
  }

  /// Eliminar imagen de producto
  static Future<Map<String, dynamic>> deleteProductImage(int productId) async {
    try {
      debugPrint('🗑️ Eliminando imagen del producto $productId...');

      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/productos/$productId/delete_image/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Imagen eliminada exitosamente');
        return {
          'success': true,
          'message': data['message'] ?? 'Imagen eliminada exitosamente',
        };
      } else {
        final errorData = json.decode(response.body);
        debugPrint('❌ Error al eliminar imagen: ${response.statusCode}');
        return {
          'success': false,
          'error': errorData['error'] ?? 'Error al eliminar imagen',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('❌ Exception al eliminar imagen: $e');
      return {'success': false, 'error': 'Error de conexión: ${e.toString()}'};
    }
  }

  /// Validar formato de imagen
  static bool isValidImageFormat(String path) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final lowerPath = path.toLowerCase();
    return validExtensions.any((ext) => lowerPath.endsWith(ext));
  }

  /// Obtener tamaño de archivo en MB
  static Future<double> getFileSizeInMB(String path) async {
    try {
      final file = File(path);
      final bytes = await file.length();
      return bytes / (1024 * 1024); // Convertir a MB
    } catch (e) {
      debugPrint('❌ Error al obtener tamaño de archivo: $e');
      return 0;
    }
  }
}
