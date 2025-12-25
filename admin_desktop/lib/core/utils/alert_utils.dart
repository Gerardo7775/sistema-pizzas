import 'package:flutter/material.dart';

class AlertUtils {
  static void showCustomModal({
    required BuildContext context,
    required String title,
    required String message,
    bool isError = true,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (isError ? Colors.red : Colors.green).withValues(
                  alpha: 0.2,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: (isError ? Colors.red : Colors.green).withValues(
                alpha: 0.3,
              ),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 64,
                color: isError ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isError ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isError ? Colors.red : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
