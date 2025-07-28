import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../providers/categoria_provider.dart';
import '../widgets/widgets.dart';
import '../mixins/crud_operations_mixin.dart';
import '../theme/toyosaki_colors.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen>
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

    // Cargar categorías del backend al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriaProvider>().loadCategorias();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Categoria> _getFilteredCategories(CategoriaProvider provider) {
    if (_searchQuery.isEmpty) {
      return provider.categorias;
    }
    return provider.categorias
        .where(
          (categoria) =>
              categoria.nombre.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              categoria.descripcion?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true,
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
              child: RefreshableListWidget<CategoriaProvider>(
                onRefresh:
                    () => context.read<CategoriaProvider>().loadCategorias(),
                isEmpty: (provider) => _getFilteredCategories(provider).isEmpty,
                isLoading: (provider) => provider.isLoading,
                getError: (provider) => provider.error,
                emptyTitle:
                    _searchQuery.isEmpty
                        ? 'No hay categorías registradas'
                        : 'No se encontraron categorías',
                emptySubtitle: 'Toca el botón + para agregar una',
                emptyIcon: Icons.category,
                onEmpty: () => _showCategoriaDialog(context),
                onRetry: () {
                  final provider = context.read<CategoriaProvider>();
                  provider.clearError();
                  provider.loadCategorias();
                },
                listBuilder: (context, provider) {
                  final filteredCategories = _getFilteredCategories(provider);
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final categoria = filteredCategories[index];
                      return _buildCategoryCard(categoria);
                    },
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
              Icons.category_outlined,
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
                  'Categorías',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ToyosakiColors.primaryBlue,
                  ),
                ),
                Text(
                  'TOYOSAKI Repuestos',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
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
                const SnackBar(content: Text('Filtros próximamente')),
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
                hintText: 'Buscar categorías...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ToyosakiColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.search,
                    color: ToyosakiColors.primaryBlue,
                    size: 12,
                  ),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[500],
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: TextStyle(color: ToyosakiColors.primaryBlue, fontSize: 13),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<CategoriaProvider>(
            builder: (context, provider, child) {
              final categories = provider.categorias;
              return Row(
                children: [
                  Expanded(
                    child: _buildCompactStat(
                      'Total',
                      '${categories.length}',
                      Icons.category_outlined,
                      ToyosakiColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactStat(
                      'Activas',
                      '${categories.length}',
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactStat(
                      'Filtradas',
                      '${_getFilteredCategories(provider).length}',
                      Icons.filter_list,
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

  Widget _buildCategoryCard(Categoria categoria) {
    final categoryColor = ToyosakiColors.getCategoryColor(categoria.nombre);
    final categoryIcon = ToyosakiColors.getCategoryIcon(categoria.nombre);

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
          onTap: () => _showCategoriaDialog(context, categoria: categoria),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icono compacto
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 18),
                ),
                const SizedBox(width: 12),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ToyosakiColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (categoria.descripcion != null &&
                          categoria.descripcion!.isNotEmpty)
                        Text(
                          categoria.descripcion!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Botones de acción compactos
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCompactActionButton(
                      icon: Icons.edit_outlined,
                      color: Colors.blue,
                      onTap:
                          () => _showCategoriaDialog(
                            context,
                            categoria: categoria,
                          ),
                    ),
                    const SizedBox(width: 8),
                    _buildCompactActionButton(
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      onTap: () => _showDeleteDialog(context, categoria),
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
      onPressed: () => _showCategoriaDialog(context),
      backgroundColor: ToyosakiColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: const Text(
        'Nueva',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
    );
  }

  void _showCategoriaDialog(BuildContext context, {Categoria? categoria}) {
    final nombreController = TextEditingController(
      text: categoria?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: categoria?.descripcion ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ToyosakiColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoria == null
                        ? Icons.add_circle_outline
                        : Icons.edit_outlined,
                    color: ToyosakiColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  categoria == null ? 'Nueva Categoría' : 'Editar Categoría',
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la categoría',
                    hintText: 'Ej: Motor, Frenos, Transmisión...',
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      color: ToyosakiColors.primaryBlue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ToyosakiColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Describe el tipo de repuestos...',
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: ToyosakiColors.primaryBlue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ToyosakiColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
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
                        content: const Text('Por favor ingrese un nombre'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final nuevaCategoria = Categoria(
                    id: categoria?.id,
                    nombre: nombreController.text.trim(),
                    descripcion:
                        descripcionController.text.trim().isEmpty
                            ? null
                            : descripcionController.text.trim(),
                  );

                  final provider = context.read<CategoriaProvider>();

                  await handleSaveOperation(
                    operation:
                        categoria == null
                            ? provider.addCategoria(nuevaCategoria)
                            : provider.updateCategoria(
                              categoria.id!,
                              nuevaCategoria,
                            ),
                    isUpdate: categoria != null,
                    itemType: 'Categoría',
                    onSuccess: () => Navigator.pop(context),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ToyosakiColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(categoria == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, Categoria categoria) {
    showDeleteConfirmation(
      itemName: categoria.nombre,
      itemType: 'la categoría',
      onConfirm: () async {
        final provider = context.read<CategoriaProvider>();
        await handleDeleteOperation(
          operation: provider.deleteCategoria(categoria.id!),
          itemType: 'Categoría',
        );
      },
    );
  }
}
