import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/state_widgets.dart';

class ProviderConsumerWidget<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T provider) builder;
  final String? loadingMessage;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final VoidCallback? onEmpty;
  final bool Function(T provider) isEmpty;
  final bool Function(T provider) isLoading;
  final String? Function(T provider) getError;

  const ProviderConsumerWidget({
    super.key,
    required this.builder,
    required this.isEmpty,
    required this.isLoading,
    required this.getError,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.loadingMessage,
    this.emptyIcon = Icons.inbox,
    this.onRetry,
    this.onEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, provider, child) {
        // Estado de carga
        if (isLoading(provider)) {
          return LoadingWidget(message: loadingMessage);
        }

        // Estado de error
        final error = getError(provider);
        if (error != null) {
          return ErrorStateWidget(
            error: error,
            onRetry: () {
              if (onRetry != null) {
                onRetry!();
              }
            },
          );
        }

        // Estado vacío
        if (isEmpty(provider)) {
          return EmptyStateWidget(
            title: emptyTitle,
            subtitle: emptySubtitle,
            icon: emptyIcon,
            onAction: onEmpty,
            actionText: onEmpty != null ? 'Agregar' : null,
          );
        }

        // Estado con datos
        return builder(context, provider);
      },
    );
  }
}

/// Widget específico para listas con RefreshIndicator
class RefreshableListWidget<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T provider) listBuilder;
  final Future<void> Function() onRefresh;
  final bool Function(T provider) isEmpty;
  final bool Function(T provider) isLoading;
  final String? Function(T provider) getError;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final VoidCallback? onEmpty;
  final VoidCallback? onRetry;

  const RefreshableListWidget({
    super.key,
    required this.listBuilder,
    required this.onRefresh,
    required this.isEmpty,
    required this.isLoading,
    required this.getError,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyIcon = Icons.inbox,
    this.onEmpty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderConsumerWidget<T>(
      isEmpty: isEmpty,
      isLoading: isLoading,
      getError: getError,
      emptyTitle: emptyTitle,
      emptySubtitle: emptySubtitle,
      emptyIcon: emptyIcon,
      onEmpty: onEmpty,
      onRetry: onRetry,
      builder: (context, provider) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: listBuilder(context, provider),
        );
      },
    );
  }
}
