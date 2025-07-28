import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/proveedor.dart';
import '../providers/proveedor_provider.dart';

class ProveedorDialog extends StatefulWidget {
  final Proveedor? proveedor;

  const ProveedorDialog({super.key, this.proveedor});

  @override
  State<ProveedorDialog> createState() => _ProveedorDialogState();
}

class _ProveedorDialogState extends State<ProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _contactoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _direccionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      _nombreController.text = widget.proveedor!.nombre;
      _descripcionController.text = widget.proveedor!.descripcion ?? '';
      _contactoController.text = widget.proveedor!.contacto ?? '';
      _telefonoController.text = widget.proveedor!.telefono ?? '';
      _correoController.text = widget.proveedor!.correo ?? '';
      _direccionController.text = widget.proveedor!.direccion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _contactoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            widget.proveedor == null ? 'Nuevo Proveedor' : 'Editar Proveedor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre del Proveedor *',
                  icon: Icons.business,
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  icon: Icons.description_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contactoController,
                  label: 'Persona de Contacto',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo Electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _direccionController,
                  label: 'Dirección',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProveedor,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(widget.proveedor == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Ingrese $label',
            prefixIcon: Icon(icon, color: Colors.green, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator:
              required
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Future<void> _saveProveedor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final proveedorProvider = context.read<ProveedorProvider>();

      final proveedorData = Proveedor(
        id: widget.proveedor?.id,
        nombre: _nombreController.text.trim(),
        descripcion:
            _descripcionController.text.trim().isEmpty
                ? null
                : _descripcionController.text.trim(),
        contacto:
            _contactoController.text.trim().isEmpty
                ? null
                : _contactoController.text.trim(),
        telefono:
            _telefonoController.text.trim().isEmpty
                ? null
                : _telefonoController.text.trim(),
        correo:
            _correoController.text.trim().isEmpty
                ? null
                : _correoController.text.trim(),
        direccion:
            _direccionController.text.trim().isEmpty
                ? null
                : _direccionController.text.trim(),
      );

      if (widget.proveedor == null) {
        await proveedorProvider.createProveedor(proveedorData);
      } else {
        await proveedorProvider.updateProveedor(proveedorData);
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.proveedor == null
                ? 'Proveedor registrado exitosamente'
                : 'Proveedor actualizado exitosamente',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar proveedor: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
