
/// Error boundary catching and displaying errors gracefully.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({super.key, required this.child, this.errorBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() { _error = details.exception; _stackTrace = details.stack; });
      FlutterError.presentError(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) return widget.errorBuilder!(_error!, _stackTrace);
      return _DefaultErrorView(error: _error!, stackTrace: _stackTrace);
    }
    return widget.child;
  }
}

class _DefaultErrorView extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  const _DefaultErrorView({required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error.withOpacity(0.6)),
            const SizedBox(height: UIConstants.spacingMd),
            Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: UIConstants.spacingSm),
            Text(error.toString(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onLightMedium), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const ErrorStateWidget({super.key, required this.message, this.onRetry, this.retryLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.onLightLow),
            const SizedBox(height: UIConstants.spacingMd),
            Text('Oops!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: UIConstants.spacingSm),
            Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onLightMedium), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: UIConstants.spacingLg),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(retryLabel ?? 'Try Again')),
            ],
          ],
        ),
      ),
    );
  }
}
