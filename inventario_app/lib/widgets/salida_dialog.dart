import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salida.dart';
import '../models/producto.dart';
import '../models/sucursal.dart';
import '../providers/salida_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/sucursales_provider.dart';
import '../providers/auth_provider_jwt.dart';

class SalidaDialog extends StatefulWidget {
  final Salida? salida;

  const SalidaDialog({super.key, this.salida});

  @override
  State<SalidaDialog> createState() => _SalidaDialogState();
}

class _SalidaDialogState extends State<SalidaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();
  final _motivoController = TextEditingController();

  Producto? _selectedProducto;
  Sucursal? _selectedSucursal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar productos y sucursales si no están cargados
    final productoProvider = context.read<ProductoProvider>();
    final sucursalProvider = context.read<SucursalesProvider>();

    await Future.wait([
      productoProvider.loadProductos(),
      sucursalProvider.loadSucursales(),
    ]);

    // Si estamos editando, configurar los valores seleccionados
    if (widget.salida != null && mounted) {
      // Buscar el producto en la lista cargada por ID
      final producto =
          productoProvider.productos
              .where((p) => p.id == widget.salida!.producto.id)
              .firstOrNull;

      // Buscar la sucursal en la lista cargada por ID
      final sucursal =
          sucursalProvider.sucursales
              .where((s) => s.id == widget.salida!.sucursal.id)
              .firstOrNull;

      if (mounted) {
        setState(() {
          // Solo asignar si el producto/sucursal existe en la lista cargada
          _selectedProducto = producto;
          _selectedSucursal = sucursal;
          _cantidadController.text = widget.salida!.cantidad.toString();
          _motivoController.text = widget.salida!.motivo ?? '';
        });
      }

      // Debug info
      print(
        '🔍 Producto original: ${widget.salida!.producto.nombre} (ID: ${widget.salida!.producto.id})',
      );
      print(
        '🔍 Producto encontrado: ${producto?.nombre} (ID: ${producto?.id})',
      );
      print(
        '🔍 Sucursal original: ${widget.salida!.sucursal.nombre} (ID: ${widget.salida!.sucursal.id})',
      );
      print(
        '🔍 Sucursal encontrada: ${sucursal?.nombre} (ID: ${sucursal?.id})',
      );
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.output, color: Colors.red, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            widget.salida == null ? 'Nueva Salida' : 'Editar Salida',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
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
                // Información del empleado que registra
                Consumer<AuthProviderJWT>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Registrado por:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  authProvider
                                          .currentEmpleado
                                          ?.nombreCompleto ??
                                      'Usuario desconocido',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildProductoDropdown(),
                const SizedBox(height: 16),
                _buildSucursalDropdown(),
                const SizedBox(height: 16),
                _buildCantidadField(),
                const SizedBox(height: 16),
                _buildMotivoField(),
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
          onPressed: _isLoading ? null : _saveSalida,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
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
                  : Text(widget.salida == null ? 'Guardar' : 'Actualizar'),
        ),
      ],
    );
  }

  Widget _buildProductoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Producto *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Consumer<ProductoProvider>(
          builder: (context, provider, child) {
            // Filtrar productos válidos
            final productosValidos =
                provider.productos.where((p) => p.id != null).toList();

            // Verificar si el producto seleccionado está en la lista
            final selectedProductoValido =
                _selectedProducto != null &&
                        productosValidos.any(
                          (p) => p.id == _selectedProducto!.id,
                        )
                    ? _selectedProducto
                    : null;

            return DropdownButtonFormField<Producto>(
              value: selectedProductoValido,
              decoration: InputDecoration(
                hintText: 'Seleccionar producto',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  productosValidos.map((producto) {
                    return DropdownMenuItem<Producto>(
                      value: producto,
                      child: Text(
                        producto.nombre,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
              onChanged: (Producto? value) {
                setState(() {
                  _selectedProducto = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un producto';
                }
                return null;
              },
              // Validación adicional para asegurar que el valor existe en los items
              isExpanded: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSucursalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sucursal *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Consumer<SucursalesProvider>(
          builder: (context, provider, child) {
            // Filtrar sucursales válidas
            final sucursalesValidas =
                provider.sucursales.where((s) => s.id != null).toList();

            // Verificar si la sucursal seleccionada está en la lista
            final selectedSucursalValida =
                _selectedSucursal != null &&
                        sucursalesValidas.any(
                          (s) => s.id == _selectedSucursal!.id,
                        )
                    ? _selectedSucursal
                    : null;

            return DropdownButtonFormField<Sucursal>(
              value: selectedSucursalValida,
              decoration: InputDecoration(
                hintText: 'Seleccionar sucursal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items:
                  sucursalesValidas.map((sucursal) {
                    return DropdownMenuItem<Sucursal>(
                      value: sucursal,
                      child: Text(
                        sucursal.nombre,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
              onChanged: (Sucursal? value) {
                setState(() {
                  _selectedSucursal = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una sucursal';
                }
                return null;
              },
              // Validación adicional para asegurar que el valor existe en los items
              isExpanded: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCantidadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cantidad *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _cantidadController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ingrese la cantidad',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese la cantidad';
            }
            final cantidad = int.tryParse(value);
            if (cantidad == null || cantidad <= 0) {
              return 'Por favor ingrese una cantidad válida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMotivoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivo',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _motivoController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Motivo de la salida (opcional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSalida() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProviderJWT>();
      final salidaProvider = context.read<SalidaProvider>();

      final salidaData = Salida(
        id: widget.salida?.id,
        producto: _selectedProducto!,
        sucursal: _selectedSucursal!,
        empleado: authProvider.currentEmpleado!,
        cantidad: int.parse(_cantidadController.text),
        motivo: _motivoController.text.isEmpty ? null : _motivoController.text,
        fecha: widget.salida?.fecha ?? DateTime.now(),
      );

      if (widget.salida == null) {
        await salidaProvider.addSalida(salidaData);
      } else {
        await salidaProvider.updateSalida(salidaData.id!, salidaData);
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.salida == null
                ? 'Salida registrada exitosamente'
                : 'Salida actualizada exitosamente',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar salida: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
