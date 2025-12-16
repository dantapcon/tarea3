import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../utils/colors.dart';
import '../widgets/sensor_card.dart';

/// Dashboard que muestra todos los sensores en tiempo real
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Datos de acelerómetro
  double _accX = 0.0, _accY = 0.0, _accZ = 0.0;
  
  // Datos de giroscopio
  double _gyroX = 0.0, _gyroY = 0.0, _gyroZ = 0.0;
  
  // Datos de magnetómetro
  double _magX = 0.0, _magY = 0.0, _magZ = 0.0;
  
  // Brújula
  double _compassHeading = 0.0;
  String _compassDirection = 'N';
  
  // Sensores adicionales
  double _lightLevel = 0.0;
  double _proximityValue = 0.0;
  bool _lightAvailable = false;
  bool _proximityAvailable = false;
  
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  /// Inicializa todos los sensores
  void _initSensors() {
    // Acelerómetro
    _subscriptions.add(
      accelerometerEventStream().listen((AccelerometerEvent event) {
        setState(() {
          _accX = event.x;
          _accY = event.y;
          _accZ = event.z;
        });
      }),
    );

    // Giroscopio
    _subscriptions.add(
      gyroscopeEventStream().listen((GyroscopeEvent event) {
        setState(() {
          _gyroX = event.x;
          _gyroY = event.y;
          _gyroZ = event.z;
        });
      }),
    );

    // Magnetómetro
    _subscriptions.add(
      magnetometerEventStream().listen((MagnetometerEvent event) {
        setState(() {
          _magX = event.x;
          _magY = event.y;
          _magZ = event.z;
        });
      }),
    );

    // Brújula
    FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        setState(() {
          _compassHeading = event.heading!;
          _compassDirection = _getCompassDirection(_compassHeading);
        });
      }
    });

    // Sensor de luz (puede no estar disponible)
    try {
      // Note: Light sensor no está directamente en sensors_plus
      // Se simula o se puede usar con plugin específico de plataforma
      _lightAvailable = false;
    } catch (e) {
      _lightAvailable = false;
    }

    // Sensor de proximidad (puede no estar disponible)
    try {
      _proximityAvailable = false;
    } catch (e) {
      _proximityAvailable = false;
    }
  }

  /// Convierte grados a dirección cardinal
  String _getCompassDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SO';
    if (heading >= 247.5 && heading < 292.5) return 'O';
    return 'NO';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Dashboard de Sensores',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reinicia los sensores
          setState(() {});
        },
        color: AppColors.secondary,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Acelerómetro
            SensorCard(
              title: 'Acelerómetro',
              icon: Icons.speed,
              value: 'Medición de aceleración',
              subtitle: 'Detecta cambios de velocidad en 3 ejes',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AxisDataWidget(
                label: 'Ejes (m/s²)',
                x: _accX,
                y: _accY,
                z: _accZ,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Giroscopio
            SensorCard(
              title: 'Giroscopio',
              icon: Icons.rotate_right,
              value: 'Velocidad angular',
              subtitle: 'Mide la rotación del dispositivo',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AxisDataWidget(
                label: 'Rotación (rad/s)',
                x: _gyroX,
                y: _gyroY,
                z: _gyroZ,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),

            // Magnetómetro
            SensorCard(
              title: 'Magnetómetro',
              icon: Icons.explore,
              value: 'Campo magnético',
              subtitle: 'Detecta campos magnéticos',
              color: AppColors.accent,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AxisDataWidget(
                label: 'Campo (µT)',
                x: _magX,
                y: _magY,
                z: _magZ,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),

            // Brújula
            _buildCompassCard(),
            const SizedBox(height: 24),

            // Sensores opcionales
            if (_lightAvailable || _proximityAvailable) ...[
              const Text(
                'Sensores Adicionales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_lightAvailable)
              SensorCard(
                title: 'Sensor de Luz',
                icon: Icons.light_mode,
                value: '${_lightLevel.toStringAsFixed(0)} lux',
                subtitle: 'Nivel de iluminación ambiente',
                color: AppColors.warning,
              ),

            if (_proximityAvailable) ...[
              const SizedBox(height: 16),
              SensorCard(
                title: 'Sensor de Proximidad',
                icon: Icons.sensors,
                value: '${_proximityValue.toStringAsFixed(1)} cm',
                subtitle: 'Distancia de objetos cercanos',
                color: AppColors.info,
              ),
            ],

            if (!_lightAvailable && !_proximityAvailable) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los sensores de luz y proximidad pueden no estar disponibles en este dispositivo',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Widget de brújula con visualización circular
  Widget _buildCompassCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.navigation,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Brújula',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Brújula visual
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Círculo exterior
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                ),
                
                // Marcadores cardinales
                ...List.generate(4, (index) {
                  final angle = index * 90.0;
                  final labels = ['N', 'E', 'S', 'O'];
                  return Transform.rotate(
                    angle: angle * pi / 180,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: labels[index] == 'N' 
                              ? Colors.red 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
                
                // Aguja
                Transform.rotate(
                  angle: (_compassHeading * pi / 180),
                  child: Icon(
                    Icons.navigation,
                    size: 80,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Información de dirección
          Text(
            '$_compassDirection',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${_compassHeading.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
