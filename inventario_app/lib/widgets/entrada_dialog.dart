import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entrada.dart';
import '../models/producto.dart';
import '../models/sucursal.dart';
import '../models/proveedor.dart';
import '../providers/entrada_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/sucursales_provider.dart';
import '../providers/proveedor_provider.dart';
import '../providers/auth_provider_jwt.dart';
import 'proveedor_dialog.dart';

class EntradaDialog extends StatefulWidget {
  final Entrada? entrada;

  const EntradaDialog({super.key, this.entrada});

  @override
  State<EntradaDialog> createState() => _EntradaDialogState();
}

class _EntradaDialogState extends State<EntradaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController();

  Producto? _selectedProducto;
  Sucursal? _selectedSucursal;
  Proveedor? _selectedProveedor;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar productos, sucursales y proveedores si no están cargados
    final productoProvider = context.read<ProductoProvider>();
    final sucursalProvider = context.read<SucursalesProvider>();
    final proveedorProvider = context.read<ProveedorProvider>();

 

    try {
      await Future.wait([
        productoProvider.loadProductos(),
        sucursalProvider.loadSucursales(),
        proveedorProvider.loadProveedores(),
      ]);

  

      // Si hay errores, imprimirlos
   
    } catch (e) {
     //s
    }

    setState(() {
      _isLoading = false;
    });

    // Si estamos editando, configurar los valores seleccionados
    if (widget.entrada != null && mounted) {
      // Buscar el producto en la lista cargada por ID
      final producto =
          productoProvider.productos
              .where((p) => p.id == widget.entrada!.producto.id)
              .firstOrNull;

      // Buscar la sucursal en la lista cargada por ID
      final sucursal =
          sucursalProvider.sucursales
              .where((s) => s.id == widget.entrada!.sucursal.id)
              .firstOrNull;

      // Buscar el proveedor en la lista cargada por ID
      final proveedor =
          proveedorProvider.proveedores
              .where((p) => p.id == widget.entrada!.proveedor.id)
              .firstOrNull;

      if (mounted) {
        setState(() {
          // Solo asignar si el producto/sucursal/proveedor existe en la lista cargada
          _selectedProducto = producto;
          _selectedSucursal = sucursal;
          _selectedProveedor = proveedor;
          _cantidadController.text = widget.entrada!.cantidad.toString();
        });
      }

      
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
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
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.input, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Text(
            widget.entrada == null ? 'Nueva Entrada' : 'Editar Entrada',
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
                // Información del empleado que registra
                Consumer<AuthProviderJWT>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.green, size: 16),
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
                                    color: Colors.green,
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
                _buildProveedorDropdown(),
                const SizedBox(height: 16),
                // Botón para agregar proveedor si no hay proveedores disponibles
                Consumer<ProveedorProvider>(
                  builder: (context, provider, child) {
                    if (provider.proveedores.isEmpty && !provider.isLoading) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No hay proveedores registrados',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => const ProveedorDialog(),
                                );
                                if (result == true) {
                                  provider.loadProveedores();
                                }
                              },
                              icon: const Icon(Icons.add, size: 14),
                              label: const Text(
                                'Registrar Proveedor',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),
                _buildCantidadField(),
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
          onPressed: _isLoading ? null : _saveEntrada,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
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
                  : Text(widget.entrada == null ? 'Guardar' : 'Actualizar'),
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
            color: Colors.green,
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
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
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
            color: Colors.green,
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
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
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
              isExpanded: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildProveedorDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Proveedor *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Consumer<ProveedorProvider>(
          builder: (context, provider, child) {
            print('🔍 ProveedorDropdown: Builder ejecutándose');
            print('🔍 Provider.isLoading: ${provider.isLoading}');
            print('🔍 Provider.error: ${provider.error}');
            print(
              '🔍 Provider.proveedores.length: ${provider.proveedores.length}',
            );

            // Filtrar proveedores válidos
            final proveedoresValidos =
                provider.proveedores.where((p) => p.id != null).toList();

            print('🔍 Proveedores válidos: ${proveedoresValidos.length}');

            // Verificar si el proveedor seleccionado está en la lista
            final selectedProveedorValido =
                _selectedProveedor != null &&
                        proveedoresValidos.any(
                          (p) => p.id == _selectedProveedor!.id,
                        )
                    ? _selectedProveedor
                    : null;

            // Si está cargando, mostrar un indicador
            if (provider.isLoading) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cargando proveedores...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            // Si hay error, mostrar mensaje
            if (provider.error != null) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: ${provider.error}',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.loadProveedores();
                      },
                      icon: Icon(Icons.refresh, size: 14),
                      label: Text('Reintentar', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Si no hay proveedores y no está cargando, mostrar botón de recarga
            if (proveedoresValidos.isEmpty && !provider.isLoading) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No hay proveedores disponibles',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('🔄 Manual: Recargando proveedores...');
                        provider.loadProveedores();
                      },
                      icon: Icon(Icons.refresh, size: 14),
                      label: Text(
                        'Cargar Proveedores',
                        style: TextStyle(fontSize: 11),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<Proveedor>(
              value: selectedProveedorValido,
              decoration: InputDecoration(
                hintText: 'Seleccionar proveedor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
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
              items:
                  proveedoresValidos.map((proveedor) {
                    return DropdownMenuItem<Proveedor>(
                      value: proveedor,
                      child: Text(
                        proveedor.nombre,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
              onChanged: (Proveedor? value) {
                setState(() {
                  _selectedProveedor = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un proveedor';
                }
                return null;
              },
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
            color: Colors.green,
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
              borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
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

  Future<void> _saveEntrada() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProviderJWT>();
      final entradaProvider = context.read<EntradaProvider>();

      final entradaData = Entrada(
        id: widget.entrada?.id,
        producto: _selectedProducto!,
        sucursal: _selectedSucursal!,
        proveedor: _selectedProveedor!,
        empleado: authProvider.currentEmpleado!,
        cantidad: int.parse(_cantidadController.text),
        fecha: widget.entrada?.fecha ?? DateTime.now(),
      );

      if (widget.entrada == null) {
        await entradaProvider.addEntrada(entradaData);
      } else {
        await entradaProvider.updateEntrada(entradaData.id!, entradaData);
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.entrada == null
                ? 'Entrada registrada exitosamente'
                : 'Entrada actualizada exitosamente',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar entrada: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
