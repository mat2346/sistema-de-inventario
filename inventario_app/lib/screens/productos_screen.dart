import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../models/producto.dart';
import '../models/inventario.dart';
import '../providers/producto_provider.dart';
import '../providers/categoria_provider.dart';
import '../providers/inventario_provider.dart';
import '../providers/sucursales_provider.dart';
import '../widgets/widgets.dart';
import '../widgets/product_image_widget.dart';
import '../mixins/crud_operations_mixin.dart';
import '../theme/toyosaki_colors.dart';
import '../services/image_picker_service.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen>
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
      context.read<ProductoProvider>().loadProductos();
      context.read<CategoriaProvider>().loadCategorias();
      context.read<InventarioProvider>().loadInventarios();
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

  List<Producto> _getFilteredProducts(ProductoProvider provider) {
    if (_searchQuery.isEmpty) return provider.productos;
    return provider.productos
        .where(
          (producto) =>
              producto.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (producto.descripcion?.toLowerCase().contains(
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
              child: RefreshableListWidget<ProductoProvider>(
                onRefresh:
                    () => context.read<ProductoProvider>().loadProductos(),
                isEmpty: (provider) => _getFilteredProducts(provider).isEmpty,
                isLoading: (provider) => provider.isLoading,
                getError: (provider) => provider.error,
                emptyTitle:
                    _searchQuery.isEmpty
                        ? 'No hay productos registrados'
                        : 'No se encontraron productos',
                emptySubtitle: 'Toca el botón + para agregar uno',
                emptyIcon: Icons.inventory,
                onEmpty: () => _showProductDialog(context),
                onRetry: () {
                  final provider = context.read<ProductoProvider>();
                  provider.clearError();
                  provider.loadProductos();
                },
                listBuilder: (context, provider) {
                  final filteredProducts = _getFilteredProducts(provider);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: filteredProducts.length,
                    itemBuilder:
                        (context, index) =>
                            _buildProductCard(filteredProducts[index]),
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
              color: ToyosakiColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Productos',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ToyosakiColors.primaryBlue,
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
      iconTheme: IconThemeData(color: ToyosakiColors.primaryBlue),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.filter_list_outlined,
              color: Colors.grey[600],
              size: 16,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Filtros - Próximamente'),
                  backgroundColor: ToyosakiColors.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
                hintText: 'Buscar productos...',
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
              style: TextStyle(color: ToyosakiColors.primaryBlue, fontSize: 13),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ProductoProvider>(
            builder: (context, provider, child) {
              final products = provider.productos;

              // Calcular productos con precios
              final productsWithPrices =
                  products
                      .where(
                        (p) => p.precioCompra != null && p.precioVenta != null,
                      )
                      .toList();

              // Calcular margen promedio
              double avgMargin = 0;
              if (productsWithPrices.isNotEmpty) {
                final totalMargin = productsWithPrices.fold<double>(0, (
                  sum,
                  p,
                ) {
                  return sum +
                      ((p.precioVenta! - p.precioCompra!) /
                          p.precioCompra! *
                          100);
                });
                avgMargin = totalMargin / productsWithPrices.length;
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      'Total',
                      '${products.length}',
                      Icons.inventory_2_outlined,
                      ToyosakiColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Con Precios',
                      '${productsWithPrices.length}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Margen Prom.',
                      '${avgMargin.toStringAsFixed(1)}%',
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

  Widget _buildProductCard(Producto producto) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _showProductDetailModal(context, producto),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Imagen del producto
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImageWidget(
                      producto: producto,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Información del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        producto.nombre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ToyosakiColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (producto.descripcion != null &&
                          producto.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          producto.descripcion!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Precio de compra
                          if (producto.precioCompra != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 8,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '\$${producto.precioCompra!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (producto.precioCompra != null &&
                              producto.precioVenta != null)
                            const SizedBox(width: 4),

                          // Precio de venta
                          if (producto.precioVenta != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: ToyosakiColors.secondaryYellow
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 8,
                                    color: ToyosakiColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 1),
                                  Text(
                                    '\$${producto.precioVenta!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: ToyosakiColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Disponible',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ✅ BOTONES DE ACCIÓN SIMPLIFICADOS - Solo editar e imagen
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactActionButton(
                      icon: Icons.edit_outlined,
                      color: Colors.blue,
                      onTap:
                          () => _showProductDialog(context, producto: producto),
                    ),
                    const SizedBox(height: 4),
                    _buildCompactActionButton(
                      icon: Icons.image_outlined,
                      color: ToyosakiColors.secondaryYellow,
                      onTap: () => _showImageDialog(context, producto),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Icon(icon, color: color, size: 10),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => _showProductDialog(context),
      backgroundColor: ToyosakiColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: const Text(
        'Nuevo',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
    );
  }

  // ✅ MODAL DETALLADO DEL PRODUCTO - Vista completa con imagen grande y stock
  void _showProductDetailModal(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
                minHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header con imagen grande
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ToyosakiColors.primaryBlue.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Imagen del producto
                        Center(
                          child: Container(
                            width: 170,
                            height: 170,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ProductImageWidget(
                                producto: producto,
                                width: 170,
                                height: 170,
                              ),
                            ),
                          ),
                        ),

                        // Botón cerrar
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenido principal
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y categoría
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: ToyosakiColors.primaryBlue,
                                      ),
                                    ),
                                    if (producto.categoria != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ToyosakiColors.secondaryYellow
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          producto.categoria!.nombre,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: ToyosakiColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Precios
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Precio de venta
                                  if (producto.precioVenta != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ToyosakiColors.primaryBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Precio Venta',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '\$${producto.precioVenta!.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if (producto.precioCompra != null &&
                                      producto.precioVenta != null)
                                    const SizedBox(height: 8),

                                  // Precio de compra
                                  if (producto.precioCompra != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Precio Compra',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                          Text(
                                            '\$${producto.precioCompra!.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.orange[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Margen de ganancia
                                  if (producto.precioCompra != null &&
                                      producto.precioVenta != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Margen: ${((producto.precioVenta! - producto.precioCompra!) / producto.precioCompra! * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Descripción
                          if (producto.descripcion != null &&
                              producto.descripcion!.isNotEmpty) ...[
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ToyosakiColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              producto.descripcion!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Stock por sucursales
                          Text(
                            'Stock por Sucursales',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ToyosakiColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: Consumer<InventarioProvider>(
                              builder: (context, inventarioProvider, child) {
                                final stockPorSucursal =
                                    inventarioProvider.inventarios
                                        .where(
                                          (inv) =>
                                              inv.producto.id == producto.id,
                                        )
                                        .toList();

                                if (stockPorSucursal.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inventory_outlined,
                                          color: Colors.grey[400],
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sin stock registrado',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID del producto: ${producto.id}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            // Recargar inventarios manualmente
                                            context
                                                .read<InventarioProvider>()
                                                .loadInventarios();
                                          },
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                          ),
                                          label: const Text('Recargar Stock'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ToyosakiColors.primaryBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: stockPorSucursal.length,
                                  itemBuilder: (context, index) {
                                    final inventario = stockPorSucursal[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: ToyosakiColors.primaryBlue
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.store_outlined,
                                              color: ToyosakiColors.primaryBlue,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  inventario.sucursal.nombre,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        ToyosakiColors
                                                            .primaryBlue,
                                                  ),
                                                ),
                                                if (inventario
                                                        .sucursal
                                                        .descripcion !=
                                                    null)
                                                  Text(
                                                    inventario
                                                        .sucursal
                                                        .descripcion!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  inventario.cantidad > 0
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red.withOpacity(
                                                        0.1,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${inventario.cantidad} unidades',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    inventario.cantidad > 0
                                                        ? Colors.green[700]
                                                        : Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showProductDialog(
                                      context,
                                      producto: producto,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Editar Producto'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ToyosakiColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showImageDialog(context, producto);
                                  },
                                  icon: const Icon(
                                    Icons.image_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Cambiar Imagen'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ToyosakiColors.primaryBlue,
                                    side: BorderSide(
                                      color: ToyosakiColors.primaryBlue,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ✅ DIÁLOGO DE IMAGEN DEDICADO - Única funcionalidad de cambio de imagen
  void _showImageDialog(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.image_outlined, color: ToyosakiColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Cambiar Imagen',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ToyosakiColors.primaryBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProductImageWidget(
                    producto: producto,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          // ✅ FUNCIONALIDAD REAL usando ActionSheet
                          Navigator.pop(context);
                          final imageFile =
                              await ImagePickerService.showImageSourceActionSheet(
                                context,
                              );
                          if (imageFile != null) {
                            await _uploadProductImage(producto, imageFile);
                          }
                        },
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text(
                          'Seleccionar',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ToyosakiColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (producto.imagenUrl != null &&
                          producto.imagenUrl!.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: () async {
                            Navigator.pop(context);
                            await _deleteProductImage(producto);
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text(
                            'Eliminar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
    );
  }

  // ✅ DIÁLOGO DE EDICIÓN SIMPLIFICADO - Sin opciones de imagen duplicadas
  void _showProductDialog(BuildContext context, {Producto? producto}) {
    final nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: producto?.descripcion ?? '',
    );
    final precioCompraController = TextEditingController(
      text: producto?.precioCompra?.toStringAsFixed(2) ?? '',
    );
    final precioVentaController = TextEditingController(
      text: producto?.precioVenta?.toStringAsFixed(2) ?? '',
    );

    // Variable para manejar la imagen seleccionada al crear un nuevo producto
    dynamic selectedImageFile;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    producto == null ? 'Nuevo Producto' : 'Editar Producto',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ToyosakiColors.primaryBlue,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDialogTextField(
                            controller: nombreController,
                            label: 'Nombre del producto',
                            icon: Icons.inventory_2_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildDialogTextField(
                            controller: descripcionController,
                            label: 'Descripción',
                            icon: Icons.description_outlined,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),

                          // Campos de precios
                          Row(
                            children: [
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: precioCompraController,
                                  label: 'Precio Compra',
                                  icon: Icons.shopping_cart_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDialogTextField(
                                  controller: precioVentaController,
                                  label: 'Precio Venta',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ✅ SECCIÓN DE IMAGEN - Para crear Y editar
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: ToyosakiColors.primaryBlue,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      producto == null
                                          ? 'Imagen del Producto'
                                          : 'Imagen Actual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ToyosakiColors.primaryBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Mostrar imagen seleccionada o imagen actual
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        selectedImageFile != null
                                            ? Container(
                                              color: ToyosakiColors.primaryBlue
                                                  .withOpacity(0.1),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    color:
                                                        ToyosakiColors
                                                            .primaryBlue,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Imagen\nSeleccionada',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          ToyosakiColors
                                                              .primaryBlue,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            : producto != null
                                            ? ProductImageWidget(
                                              producto: producto,
                                              width: 100,
                                              height: 100,
                                            )
                                            : Container(
                                              color: Colors.grey[100],
                                              child: Icon(
                                                Icons
                                                    .add_photo_alternate_outlined,
                                                color: Colors.grey[400],
                                                size: 32,
                                              ),
                                            ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Botones de acción de imagen
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final imageFile =
                                            await ImagePickerService.showImageSourceActionSheet(
                                              context,
                                            );
                                        if (imageFile != null) {
                                          setState(() {
                                            selectedImageFile = imageFile;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 14,
                                      ),
                                      label: Text(
                                        selectedImageFile != null
                                            ? 'Cambiar'
                                            : 'Seleccionar',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ToyosakiColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),

                                    if (selectedImageFile != null ||
                                        (producto?.imagenUrl != null &&
                                            producto!.imagenUrl!.isNotEmpty))
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            selectedImageFile = null;
                                          });
                                          if (producto != null) {
                                            // Para productos existentes, eliminar imagen del servidor
                                            _deleteProductImage(producto);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'Quitar',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                if (producto == null &&
                                    selectedImageFile == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Opcional: Puedes agregar una imagen después',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nombreController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Por favor ingrese un nombre',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                          return;
                        }

                        // Parsear precios
                        double? precioCompra;
                        double? precioVenta;

                        if (precioCompraController.text.trim().isNotEmpty) {
                          try {
                            precioCompra = double.parse(
                              precioCompraController.text.trim(),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'El precio de compra debe ser un número válido',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        if (precioVentaController.text.trim().isNotEmpty) {
                          try {
                            precioVenta = double.parse(
                              precioVentaController.text.trim(),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'El precio de venta debe ser un número válido',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        final nuevoProducto = Producto(
                          id: producto?.id,
                          nombre: nombreController.text.trim(),
                          descripcion:
                              descripcionController.text.trim().isEmpty
                                  ? null
                                  : descripcionController.text.trim(),
                          precioCompra: precioCompra,
                          precioVenta: precioVenta,
                        );

                        final provider = context.read<ProductoProvider>();

                        try {
                          // Guardar o actualizar el producto
                          if (producto == null) {
                            try {
                              // Crear nuevo producto
                              await provider.addProducto(nuevoProducto);
                            } catch (e) {
                              throw e;
                            }

                            try {
                              // Recargar productos para obtener el ID del nuevo producto
                              await provider.loadProductos();
                            } catch (e) {
                              throw e;
                            }

                            final productoRecienCreado =
                                provider.productos
                                    .where(
                                      (p) => p.nombre == nuevoProducto.nombre,
                                    )
                                    .lastOrNull;

                            if (productoRecienCreado?.id != null) {
                              // Si hay una imagen seleccionada, subirla
                              if (selectedImageFile != null) {
                                try {
                                  await _uploadProductImage(
                                    productoRecienCreado!,
                                    selectedImageFile,
                                  );
                                } catch (e) {
                                  // No detenemos el flujo por error de imagen
                                }
                              }

                              Navigator.pop(context);

                              // ✅ FLUJO AUTOMÁTICO: Llamada directa al modal después de cerrar el diálogo
                              _openStockModalAfterProductCreation(
                                context,
                                productoRecienCreado!,
                              );
                            } else {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Error: No se pudo obtener el producto creado',
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            // Actualizar producto existente
                            await provider.updateProducto(
                              producto.id!,
                              nuevoProducto,
                            );

                            // Si hay una imagen seleccionada para producto existente
                            if (selectedImageFile != null) {
                              await _uploadProductImage(
                                producto,
                                selectedImageFile,
                              );
                            }

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Producto actualizado exitosamente',
                                ),
                                backgroundColor: ToyosakiColors.primaryBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ToyosakiColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(producto == null ? 'Crear' : 'Actualizar'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ToyosakiColors.primaryBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 14),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: TextStyle(color: ToyosakiColors.primaryBlue, fontSize: 13),
      ),
    );
  }

  // ✅ MÉTODOS para manejar imágenes
  Future<void> _uploadProductImage(Producto producto, dynamic imageFile) async {
    if (producto.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error: El producto debe estar guardado antes de agregar imágenes',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final result = await ImagePickerService.uploadProductImage(
        producto.id!,
        imageFile,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Imagen subida exitosamente'),
            backgroundColor: ToyosakiColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Recargar productos para mostrar la nueva imagen
        context.read<ProductoProvider>().loadProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al subir imagen'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteProductImage(Producto producto) async {
    if (producto.id == null) return;

    try {
      final result = await ImagePickerService.deleteProductImage(producto.id!);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Imagen eliminada exitosamente'),
            backgroundColor: ToyosakiColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Recargar productos para actualizar la vista
        context.read<ProductoProvider>().loadProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar imagen'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ MÉTODO AUXILIAR para abrir modal de stock después de crear producto
  void _openStockModalAfterProductCreation(
    BuildContext context,
    Producto producto,
  ) {
    // Verificar que el widget esté montado
    if (!mounted) {
      return;
    }

    // Usar el contexto del scaffold para evitar problemas de navegación
    final scaffoldContext = this.context;

    // Pequeño delay para asegurar que la navegación se complete
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _showStockRegistrationModal(scaffoldContext, producto);
      }
    });
  }

  // ✅ MODAL DE REGISTRO DE STOCK - Se abre después de crear un producto
  void _showStockRegistrationModal(BuildContext context, Producto producto) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Consumer<SucursalesProvider>(
                builder: (context, sucursalesProvider, child) {
                  if (sucursalesProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sucursales = sucursalesProvider.sucursales;

                  // Mapa para almacenar las cantidades por sucursal
                  final Map<int, TextEditingController> cantidadControllers =
                      {};

                  // Inicializar controladores para cada sucursal
                  for (var sucursal in sucursales) {
                    cantidadControllers[sucursal.id!] = TextEditingController(
                      text: '0',
                    );
                  }

                  return StatefulBuilder(
                    builder:
                        (context, setModalState) => Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ToyosakiColors.primaryBlue,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.inventory_outlined,
                                      color: ToyosakiColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '✅ Producto Creado',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Ahora registra el stock para: ${producto.nombre}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Contenido
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Define la cantidad inicial en cada sucursal:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    if (sucursales.isEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.warning_outlined,
                                              color: Colors.orange[700],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No hay sucursales registradas',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Debes crear al menos una sucursal antes de registrar stock',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[600],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: sucursales.length,
                                          itemBuilder: (context, index) {
                                            final sucursal = sucursales[index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 12,
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.grey[200]!,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: ToyosakiColors
                                                          .primaryBlue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.store_outlined,
                                                      color:
                                                          ToyosakiColors
                                                              .primaryBlue,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          sucursal.nombre,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                ToyosakiColors
                                                                    .primaryBlue,
                                                          ),
                                                        ),
                                                        if (sucursal.descripcion !=
                                                                null &&
                                                            sucursal
                                                                .descripcion!
                                                                .isNotEmpty)
                                                          Text(
                                                            sucursal
                                                                .descripcion!,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .grey[600],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80,
                                                    child: TextField(
                                                      controller:
                                                          cantidadControllers[sucursal
                                                              .id!],
                                                      keyboardType:
                                                          TextInputType.number,
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration: InputDecoration(
                                                        labelText: 'Cantidad',
                                                        labelStyle: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey[300]!,
                                                          ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                ToyosakiColors
                                                                    .primaryBlue,
                                                          ),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            ToyosakiColors
                                                                .primaryBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // Botones de acción
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Producto creado sin stock inicial. Puedes agregarlo después.',
                                            ),
                                            backgroundColor: Colors.orange,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[600],
                                        side: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Saltar por ahora'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed:
                                          sucursales.isEmpty
                                              ? null
                                              : () async {
                                                try {
                                                  final inventarioProvider =
                                                      context
                                                          .read<
                                                            InventarioProvider
                                                          >();
                                                  bool hasStock = false;

                                                  // Crear inventarios para cada sucursal con cantidad > 0
                                                  for (var sucursal
                                                      in sucursales) {
                                                    final cantidadText =
                                                        cantidadControllers[sucursal
                                                                .id!]
                                                            ?.text ??
                                                        '0';
                                                    final cantidad =
                                                        int.tryParse(
                                                          cantidadText,
                                                        ) ??
                                                        0;

                                                    if (cantidad > 0) {
                                                      hasStock = true;
                                                      final nuevoInventario =
                                                          Inventario(
                                                            producto: producto,
                                                            sucursal: sucursal,
                                                            cantidad: cantidad,
                                                          );

                                                      await inventarioProvider
                                                          .addInventario(
                                                            nuevoInventario,
                                                          );
                                                    }
                                                  }

                                                  Navigator.pop(context);

                                                  if (hasStock) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                          '¡Perfecto! Producto creado con stock inicial registrado.',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                          'Producto creado. No se registró stock inicial.',
                                                        ),
                                                        backgroundColor:
                                                            Colors.orange,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                      ),
                                                    );
                                                  }

                                                  // Recargar inventarios para actualizar la vista
                                                  await inventarioProvider
                                                      .loadInventarios();
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error al registrar stock: ${e.toString()}',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                    ),
                                                  );
                                                }
                                              },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ToyosakiColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Registrar Stock'),
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
            ),
          ),
    );
  }
}
