import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entrada.dart';
import '../providers/entrada_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/sucursales_provider.dart';
import '../providers/proveedor_provider.dart';
import '../widgets/widgets.dart';
import '../widgets/proveedor_dialog.dart';
import '../mixins/crud_operations_mixin.dart';

class EntradasScreen extends StatefulWidget {
  const EntradasScreen({super.key});

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen>
    with CrudOperationsMixin, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EntradaProvider>().loadEntradas();
      context.read<ProductoProvider>().loadProductos();
      context.read<SucursalesProvider>().loadSucursales();
      context.read<ProveedorProvider>().loadProveedores();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Entrada> _getFilteredEntradas(EntradaProvider provider) {
    print(
      '🔍 EntradasScreen: Filtrando entradas - Total: ${provider.entradas.length}, Query: "$_searchQuery"',
    );
    if (_searchQuery.isEmpty) return provider.entradas;
    return provider.entradas
        .where(
          (entrada) =>
              entrada.producto.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              entrada.sucursal.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              entrada.proveedor.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndStats(),
            Expanded(
              child: RefreshableListWidget<EntradaProvider>(
                onRefresh: () => context.read<EntradaProvider>().loadEntradas(),
                isEmpty: (provider) => _getFilteredEntradas(provider).isEmpty,
                isLoading: (provider) => provider.isLoading,
                getError: (provider) => provider.error,
                emptyTitle:
                    _searchQuery.isEmpty
                        ? 'No hay entradas registradas'
                        : 'No se encontraron entradas',
                emptySubtitle: 'Toca el botón + para agregar una',
                emptyIcon: Icons.input,
                onEmpty: () => _showEntradaDialog(context),
                onRetry: () {
                  final provider = context.read<EntradaProvider>();
                  provider.clearError();
                  provider.loadEntradas();
                },
                listBuilder: (context, provider) {
                  final filteredEntradas = _getFilteredEntradas(provider);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: filteredEntradas.length,
                    itemBuilder:
                        (context, index) =>
                            _buildEntradaCard(filteredEntradas[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón para registrar proveedor
          FloatingActionButton(
            heroTag: "proveedor",
            onPressed: () => _showProveedorDialog(context),
            backgroundColor: Colors.orange,
            elevation: 4,
            child: const Icon(Icons.business, size: 20),
          ),
          const SizedBox(height: 8),
          _buildFloatingActionButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 65,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.input, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Entradas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'TOYOSAKI Repuestos',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: Colors.green),
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar entradas...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 18,
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(color: Colors.green, fontSize: 13),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<EntradaProvider>(
            builder: (context, provider, child) {
              final entradas = provider.entradas;
              final today = DateTime.now();
              final todayEntradas =
                  entradas
                      .where(
                        (entrada) =>
                            entrada.fecha.year == today.year &&
                            entrada.fecha.month == today.month &&
                            entrada.fecha.day == today.day,
                      )
                      .length;

              return Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      'Total',
                      '${entradas.length}',
                      Icons.input,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Hoy',
                      '$todayEntradas',
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Este Mes',
                      '${entradas.where((e) => e.fecha.month == today.month).length}',
                      Icons.calendar_month,
                      Colors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildEntradaCard(Entrada entrada) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.input, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entrada.producto.nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Sucursal: ${entrada.sucursal.nombre}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Proveedor: ${entrada.proveedor.nombre}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Empleado: ${entrada.empleado.nombreCompleto}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${entrada.cantidad}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entrada.fecha.day}/${entrada.fecha.month}/${entrada.fecha.year}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Editar',
                    Icons.edit,
                    Colors.blue,
                    () => _showEntradaDialog(context, entrada: entrada),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showEntradaDialog(context),
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: const Text(
        'Nueva Entrada',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
    );
  }

  void _showEntradaDialog(BuildContext context, {Entrada? entrada}) async {
    // Cargar proveedores si no están cargados
    final proveedorProvider = context.read<ProveedorProvider>();
    if (proveedorProvider.proveedores.isEmpty) {
      await proveedorProvider.loadProveedores();
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EntradaDialog(entrada: entrada),
    );

    if (result == true) {
      // Recargar las entradas después de agregar/editar
      context.read<EntradaProvider>().loadEntradas();
    }
  }

  void _showProveedorDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ProveedorDialog(),
    );

    if (result == true) {
      // Recargar proveedores después de agregar uno nuevo
      context.read<ProveedorProvider>().loadProveedores();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.business, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('Proveedor registrado exitosamente'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
