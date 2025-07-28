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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: filteredCategories.length,
                    itemBuilder:
                        (context, index) =>
                            _buildCategoriaCard(filteredCategories[index]),
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
                hintText: 'Buscar categorías...',
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Motor',
                      '${categories.where((c) => c.nombre.toLowerCase().contains('motor')).length}',
                      Icons.settings_outlined,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildCompactStat(
                      'Frenos',
                      '${categories.where((c) => c.nombre.toLowerCase().contains('freno')).length}',
                      Icons.block_outlined,
                      Colors.red,
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

  Widget _buildCategoriaCard(Categoria categoria) {
    final categoryColor = _getCategoryColor(categoria.nombre);
    final categoryIcon = _getCategoryIcon(categoria.nombre);

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
          onTap: () => _showCategoriaDetailModal(context, categoria),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Icono de categoría
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: categoryColor.withOpacity(0.1),
                    border: Border.all(color: categoryColor.withOpacity(0.3)),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 24),
                ),
                const SizedBox(width: 10),

                // Información de la categoría
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categoria.nombre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ToyosakiColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (categoria.descripcion != null &&
                          categoria.descripcion!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          categoria.descripcion!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Categoría',
                          style: TextStyle(
                            fontSize: 9,
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
                    const SizedBox(height: 4),
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

  // Modal detallado de la categoría
  void _showCategoriaDetailModal(BuildContext context, Categoria categoria) {
    final categoryColor = _getCategoryColor(categoria.nombre);
    final categoryIcon = _getCategoryIcon(categoria.nombre);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
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
                  // Header con icono grande
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [categoryColor.withOpacity(0.1), Colors.white],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Icono de la categoría
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: categoryColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              categoryIcon,
                              color: categoryColor,
                              size: 60,
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Text(
                            categoria.nombre,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: ToyosakiColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Categoría de Repuestos',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: categoryColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Descripción
                          if (categoria.descripcion != null &&
                              categoria.descripcion!.isNotEmpty) ...[
                            Text(
                              'Descripción',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ToyosakiColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              categoria.descripcion!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sin descripción',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showCategoriaDialog(
                                      context,
                                      categoria: categoria,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Editar Categoría'),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showDeleteDialog(context, categoria);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  label: const Text('Eliminar'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
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
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              categoria == null ? 'Nueva Categoría' : 'Editar Categoría',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ToyosakiColors.primaryBlue,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nombreController,
                    label: 'Nombre de la categoría',
                    icon: Icons.category_outlined,
                    hint: 'Ej: Motor, Frenos, Transmisión...',
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(
                    controller: descripcionController,
                    label: 'Descripción (opcional)',
                    icon: Icons.description_outlined,
                    hint: 'Describe el tipo de repuestos...',
                    maxLines: 2,
                  ),
                ],
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
                        content: const Text('Por favor ingrese un nombre'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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

                  try {
                    if (categoria == null) {
                      await provider.addCategoria(nuevaCategoria);
                    } else {
                      await provider.updateCategoria(
                        categoria.id!,
                        nuevaCategoria,
                      );
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          categoria == null
                              ? 'Categoría creada exitosamente'
                              : 'Categoría actualizada exitosamente',
                        ),
                        backgroundColor: ToyosakiColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
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
                child: Text(categoria == null ? 'Crear' : 'Actualizar'),
              ),
            ],
          ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
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

  void _showDeleteDialog(BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_outlined, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Confirmar Eliminación'),
              ],
            ),
            content: Text(
              '¿Estás seguro de que deseas eliminar la categoría "${categoria.nombre}"?\n\nEsta acción no se puede deshacer.',
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
                  try {
                    final provider = context.read<CategoriaProvider>();
                    await provider.deleteCategoria(categoria.id!);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Categoría eliminada exitosamente'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: ${e.toString()}'),
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
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  // Helpers para iconos y colores de categorías
  Color _getCategoryColor(String nombre) {
    final name = nombre.toLowerCase();
    if (name.contains('motor')) return Colors.blue;
    if (name.contains('freno')) return Colors.red;
    if (name.contains('transmisión') || name.contains('transmision'))
      return Colors.orange;
    if (name.contains('suspensión') || name.contains('suspension'))
      return Colors.purple;
    if (name.contains('eléctrico') || name.contains('electrico'))
      return Colors.amber;
    if (name.contains('escape')) return Colors.grey;
    if (name.contains('carrocería') || name.contains('carroceria'))
      return Colors.green;
    return ToyosakiColors.primaryBlue;
  }

  IconData _getCategoryIcon(String nombre) {
    final name = nombre.toLowerCase();
    if (name.contains('motor')) return Icons.settings;
    if (name.contains('freno')) return Icons.block;
    if (name.contains('transmisión') || name.contains('transmision'))
      return Icons.build;
    if (name.contains('suspensión') || name.contains('suspension'))
      return Icons.height;
    if (name.contains('eléctrico') || name.contains('electrico'))
      return Icons.electrical_services;
    if (name.contains('escape')) return Icons.air;
    if (name.contains('carrocería') || name.contains('carroceria'))
      return Icons.directions_car;
    return Icons.category;
  }
}
