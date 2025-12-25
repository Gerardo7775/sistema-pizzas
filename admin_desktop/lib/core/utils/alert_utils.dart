import 'package:flutter/material.dart';

class AlertUtils {
  static void showCustomModal({
    required BuildContext context,
    required String title,
    required String message,
    bool isError = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = isError
        ? const Color(0xFFD32F2F)
        : const Color(0xFF388E3C);
    final softBg = isError ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 420,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: softBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.priority_high_rounded : Icons.check_rounded,
                  size: 32,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    showCustomModal(
      context: context,
      title: '¡Ups! Algo salió mal',
      message: message,
      isError: true,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showCustomModal(
      context: context,
      title: '¡Éxito!',
      message: message,
      isError: false,
    );
  }
}
