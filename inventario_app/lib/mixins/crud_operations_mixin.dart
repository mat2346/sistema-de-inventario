import 'package:flutter/material.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confirmation_dialog.dart';

mixin CrudOperationsMixin<T extends StatefulWidget> on State<T> {
  /// Ejecuta una operación CRUD y maneja los resultados
  Future<void> executeCrudOperation({
    required Future<bool> operation,
    required String successMessage,
    required String errorProvider,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      final success = await operation;

      if (success) {
        if (mounted) AppSnackBar.showSuccess(context, successMessage);
        onSuccess?.call();
      } else {
        if (mounted) AppSnackBar.showError(context, 'Error: $errorProvider');
        onError?.call();
      }
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Error inesperado: $e');
      onError?.call();
    }
  }

  /// Muestra un diálogo de confirmación para eliminación
  Future<void> showDeleteConfirmation({
    required String itemName,
    required String itemType,
    required VoidCallback onConfirm,
  }) async {
    return ConfirmationDialog.show(
      context: context,
      title: 'Confirmar eliminación',
      content: '¿Estás seguro de que quieres eliminar $itemType "$itemName"?',
      confirmText: 'Eliminar',
      onConfirm: onConfirm,
    );
  }

  /// Maneja la operación de crear/actualizar
  Future<void> handleSaveOperation({
    required Future<bool> operation,
    required bool isUpdate,
    required String itemType,
    VoidCallback? onSuccess,
  }) async {
    await executeCrudOperation(
      operation: operation,
      successMessage:
          isUpdate
              ? '$itemType actualizado exitosamente'
              : '$itemType creado exitosamente',
      errorProvider:
          'No se pudo ${isUpdate ? "actualizar" : "crear"} $itemType',
      onSuccess: onSuccess,
    );
  }

  /// Maneja la operación de eliminar
  Future<void> handleDeleteOperation({
    required Future<bool> operation,
    required String itemType,
    VoidCallback? onSuccess,
  }) async {
    await executeCrudOperation(
      operation: operation,
      successMessage: '$itemType eliminado exitosamente',
      errorProvider: 'No se pudo eliminar $itemType',
      onSuccess: onSuccess,
    );
  }
}
