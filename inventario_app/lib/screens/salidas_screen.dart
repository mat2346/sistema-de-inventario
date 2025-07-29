import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/salida.dart';
import '../providers/salida_provider.dart';
import '../providers/producto_provider.dart';
import '../providers/sucursales_provider.dart';
import '../widgets/widgets.dart';
import '../mixins/crud_operations_mixin.dart';

class SalidasScreen extends StatefulWidget {
  const SalidasScreen({super.key});

  @override
  State<SalidasScreen> createState() => _SalidasScreenState();
}

class _SalidasScreenState extends State<SalidasScreen>
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
      context.read<SalidaProvider>().loadSalidas();
      context.read<ProductoProvider>().loadProductos();
      context.read<SucursalesProvider>().loadSucursales();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Salida> _getFilteredSalidas(SalidaProvider provider) {
    if (_searchQuery.isEmpty) return provider.salidas;
    return provider.salidas
        .where(
          (salida) =>
              salida.producto.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              salida.sucursal.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (salida.motivo?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false),
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
              child: RefreshableListWidget<SalidaProvider>(
                onRefresh: () => context.read<SalidaProvider>().loadSalidas(),
                isEmpty: (provider) => _getFilteredSalidas(provider).isEmpty,
                isLoading: (provider) => provider.isLoading,
                getError: (provider) => provider.error,
                emptyTitle:
                    _searchQuery.isEmpty
                        ? 'No hay salidas registradas'
                        : 'No se encontraron salidas',
                emptySubtitle: 'Toca el botón + para agregar una',
                emptyIcon: Icons.output,
                onEmpty: () => _showSalidaDialog(context),
                onRetry: () {
                  final provider = context.read<SalidaProvider>();
                  provider.clearError();
                  provider.loadSalidas();
                },
                listBuilder: (context, provider) {
                  final filteredSalidas = _getFilteredSalidas(provider);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: filteredSalidas.length,
                    itemBuilder:
                        (context, index) =>
                            _buildSalidaCard(filteredSalidas[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.output, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Salidas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
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
      iconTheme: IconThemeData(color: Colors.red),
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
                hintText: 'Buscar salidas...',
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
              style: TextStyle(color: Colors.red, fontSize: 13),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<SalidaProvider>(
            builder: (context, provider, child) {
              final salidas = provider.salidas;
              final today = DateTime.now();
              final todaySalidas =
                  salidas
                      .where(
                        (salida) =>
                            salida.fecha.year == today.year &&
                            salida.fecha.month == today.month &&
                            salida.fecha.day == today.day,
                      )
                      .length;

              final ventas = salidas.where((s) => s.esVenta).length;
              final ventasHoy =
                  salidas
                      .where(
                        (s) =>
                            s.esVenta &&
                            s.fecha.year == today.year &&
                            s.fecha.month == today.month &&
                            s.fecha.day == today.day,
                      )
                      .length;

              return Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      'Total',
                      '${salidas.length}',
                      Icons.output,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Hoy',
                      '$todaySalidas',
                      Icons.today,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Ventas',
                      '$ventas',
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'V. Hoy',
                      '$ventasHoy',
                      Icons.trending_up,
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

  Widget _buildSalidaCard(Salida salida) {
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
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.output, color: Colors.red, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salida.producto.nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Sucursal: ${salida.sucursal.nombre}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        'Empleado: ${salida.empleado.nombreCompleto}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      if (salida.motivo != null && salida.motivo!.isNotEmpty)
                        Text(
                          'Motivo: ${salida.motivo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      if (salida.esVenta)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'VENTA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            if (salida.monto != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '\$${salida.monto!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ],
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
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${salida.cantidad}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${salida.fecha.day}/${salida.fecha.month}/${salida.fecha.year}',
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
                    () => _showSalidaDialog(context, salida: salida),
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
      onPressed: () => _showSalidaDialog(context),
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: const Text(
        'Nueva Salida',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
    );
  }

  void _showSalidaDialog(BuildContext context, {Salida? salida}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SalidaDialog(salida: salida),
    );

    if (result == true) {
      // Recargar las salidas después de agregar/editar
      context.read<SalidaProvider>().loadSalidas();
    }
  }
}
