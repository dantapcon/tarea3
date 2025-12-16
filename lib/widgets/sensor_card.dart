import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Widget reutilizable para mostrar datos de sensores
class SensorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? subtitle;
  final Color? color;

  const SensorCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.primary).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? AppColors.primary).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color ?? AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar valores de ejes X, Y, Z
class AxisDataWidget extends StatelessWidget {
  final String label;
  final double x;
  final double y;
  final double z;
  final Color color;

  const AxisDataWidget({
    super.key,
    required this.label,
    required this.x,
    required this.y,
    required this.z,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildAxisBar('X', x, Colors.red),
        const SizedBox(height: 4),
        _buildAxisBar('Y', y, Colors.green),
        const SizedBox(height: 4),
        _buildAxisBar('Z', z, Colors.blue),
      ],
    );
  }

  Widget _buildAxisBar(String axis, double value, Color color) {
    final displayValue = value.clamp(-10, 10);
    final percentage = ((displayValue + 10) / 20).clamp(0.0, 1.0);
    
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            axis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
