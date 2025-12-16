import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Pantalla de inicio con información de la tarea
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.lightGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícono principal animado
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sensors,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Título principal
                  const Text(
                    'Tarea 3',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtítulo
                  const Text(
                    'Uso de Sensores en Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Tarjetas de información
                  _buildInfoCard(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    description: 'Visualiza datos en tiempo real de múltiples sensores',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.gamepad_rounded,
                    title: 'Juego',
                    description: 'Controla el juego con movimiento del dispositivo',
                  ),
                  const SizedBox(height: 50),
                  
                  // Indicador para navegar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Usa la barra inferior para navegar',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget para tarjeta de información
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
