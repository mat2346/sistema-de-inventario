import 'package:flutter/material.dart';
import '../models/producto.dart';

class ProductImageWidget extends StatefulWidget {
  final Producto producto;
  final double? width;
  final double? height;

  const ProductImageWidget({
    Key? key,
    required this.producto,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<ProductImageWidget> createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (widget.producto.imagenUrl != null &&
        widget.producto.imagenUrl!.isNotEmpty) {
      // Mostrar imagen existente
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.producto.imagenUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Si hay error cargando la imagen de red, mostrar imagen por defecto
            return _buildDefaultImage();
          },
        ),
      );
    } else {
      // Mostrar imagen por defecto cuando no hay imagen
      return _buildDefaultImage();
    }
  }

  Widget _buildDefaultImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'lib/images/no_image.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Si también hay error con la imagen por defecto, mostrar placeholder
          return _buildPlaceholder(hasError: true);
        },
      ),
    );
  }

  Widget _buildPlaceholder({bool hasError = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasError ? Icons.broken_image : Icons.image_outlined,
            size: 32,
            color: hasError ? Colors.red[300] : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            hasError ? 'Error al cargar imagen' : 'Sin imagen',
            style: TextStyle(
              color: hasError ? Colors.red[300] : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
