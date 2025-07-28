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
      duration: const Duration(milliseconds: 800),
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
      backgroundColor: ToyosakiColors.lightGrey,
      appBar: _buildToyosakiAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ToyosakiColors.softBackgroundGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: RefreshableListWidget<CategoriaProvider>(
                  onRefresh:
                      () => context.read<CategoriaProvider>().loadCategorias(),
                  isEmpty:
                      (provider) => _getFilteredCategories(provider).isEmpty,
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
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final categoria = filteredCategories[index];
                        return _buildToyosakiCategoryCard(categoria, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildToyosakiFAB(),
    );
  }

  PreferredSizeWidget _buildToyosakiAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ToyosakiColors.secondaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_rounded,
              color: ToyosakiColors.secondaryYellow,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'TOYOSAKI Repuestos',
                style: TextStyle(
                  fontSize: 12,
                  color: ToyosakiColors.secondaryYellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: ToyosakiColors.accentGreen,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        color: ToyosakiColors.accentGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: ToyosakiColors.cardShadow,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar categorías...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: ToyosakiColors.accentGreen,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: ToyosakiColors.mediumGrey,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Estadísticas
            Consumer<CategoriaProvider>(
              builder: (context, provider, child) {
                final categories = provider.categorias;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: ToyosakiColors.secondaryYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${categories.length} categorías',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' organizadas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToyosakiCategoryCard(Categoria categoria, int index) {
    final categoryColor = ToyosakiColors.getCategoryColor(categoria.nombre);
    final categoryIcon = ToyosakiColors.getCategoryIcon(categoria.nombre);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: ToyosakiColors.accentGreen.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, categoryColor.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de categoría
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Información de la categoría
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ToyosakiColors.darkGrey,
                        ),
                      ),
                      if (categoria.descripcion != null &&
                          categoria.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          categoria.descripcion!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Chip con color de categoría
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Repuestos ${categoria.nombre}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones de acción
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ToyosakiColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: ToyosakiColors.primaryBlue,
                          size: 20,
                        ),
                        onPressed:
                            () => _showCategoriaDialog(
                              context,
                              categoria: categoria,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: ToyosakiColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: ToyosakiColors.errorRed,
                          size: 20,
                        ),
                        onPressed: () => _showDeleteDialog(context, categoria),
                      ),
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

  Widget _buildToyosakiFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ToyosakiColors.accentGreen,
            ToyosakiColors.accentGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: ToyosakiColors.yellowAccentShadow,
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showCategoriaDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: const Text(
          'Nueva Categoría',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
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
                    color: ToyosakiColors.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoria == null
                        ? Icons.add_circle_outline
                        : Icons.edit_outlined,
                    color: ToyosakiColors.accentGreen,
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
                      color: ToyosakiColors.accentGreen,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ToyosakiColors.accentGreen,
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
                      color: ToyosakiColors.accentGreen,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ToyosakiColors.accentGreen,
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
                        backgroundColor: ToyosakiColors.errorRed,
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
                  backgroundColor: ToyosakiColors.accentGreen,
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
