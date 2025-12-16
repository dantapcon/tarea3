import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../utils/colors.dart';

/// Juego controlado por acelerómetro
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Posición de la pelota
  double _ballX = 0.0;
  double _ballY = 0.0;
  
  // Velocidad de la pelota
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  
  // Tamaño de la pelota
  final double _ballSize = 30.0;
  
  // Juego
  int _score = 0;
  int _level = 1;
  bool _gameStarted = false;
  bool _gameOver = false;
  
  // Obstáculos
  final List<Obstacle> _obstacles = [];
  
  // Objetivo
  Offset? _targetPosition;
  
  StreamSubscription? _accelerometerSubscription;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  /// Inicializa el juego
  void _initGame() {
    setState(() {
      _ballX = 0.0;
      _ballY = 0.0;
      _velocityX = 0.0;
      _velocityY = 0.0;
      _score = 0;
      _level = 1;
      _gameStarted = false;
      _gameOver = false;
      _obstacles.clear();
    });
  }

  /// Inicia el juego
  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _generateLevel();
    });

    // Escucha el acelerómetro
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (_gameStarted && !_gameOver && mounted) {
          setState(() {
            // Control más suave: usar directamente la inclinación
            // Invertir los ejes para que sea más intuitivo
            _velocityX = -event.x * 0.4; // Reducido de 0.8 a 0.4
            _velocityY = event.y * 0.4;   // Reducido de 0.8 a 0.4
            
            // Límite de velocidad más bajo para mejor control
            _velocityX = _velocityX.clamp(-3.0, 3.0); // Reducido de 5.0 a 3.0
            _velocityY = _velocityY.clamp(-3.0, 3.0); // Reducido de 5.0 a 3.0
            
            // Actualiza posición con factor de tiempo más pequeño
            _ballX += _velocityX * 0.015; // Reducido de 0.02 a 0.015
            _ballY += _velocityY * 0.015; // Reducido de 0.02 a 0.015
            
            // Asegurar que la pelota no salga de los límites
            _ballX = _ballX.clamp(-0.95, 0.95);
            _ballY = _ballY.clamp(-0.95, 0.95);
          });
        }
      },
    );

    // Timer del juego
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_gameStarted && !_gameOver) {
        _checkCollisions();
        _checkTarget();
      }
    });
  }

  /// Genera un nivel con obstáculos y objetivo
  void _generateLevel() {
    _obstacles.clear();
    final random = Random();
    
    // Genera obstáculos según el nivel (máximo 6)
    final obstacleCount = min(3 + _level, 6);
    
    for (int i = 0; i < obstacleCount; i++) {
      bool validPosition = false;
      int attempts = 0;
      
      while (!validPosition && attempts < 20) {
        attempts++;
        
        final newX = (random.nextDouble() * 2 - 1) * 0.7;
        final newY = (random.nextDouble() * 2 - 1) * 0.7;
        final newWidth = 0.12 + random.nextDouble() * 0.08;  // Tamaño reducido
        final newHeight = 0.12 + random.nextDouble() * 0.08;
        
        // Verificar que no esté muy cerca del inicio
        if (sqrt(newX * newX + newY * newY) < 0.25) {
          continue;
        }
        
        // Verificar que no se superponga con otros obstáculos
        bool overlaps = false;
        for (var obstacle in _obstacles) {
          final dx = (newX - obstacle.x).abs();
          final dy = (newY - obstacle.y).abs();
          final minDistanceX = (newWidth + obstacle.width) / 2 + 0.1; // Añadir margen
          final minDistanceY = (newHeight + obstacle.height) / 2 + 0.1;
          
          if (dx < minDistanceX && dy < minDistanceY) {
            overlaps = true;
            break;
          }
        }
        
        if (!overlaps) {
          _obstacles.add(Obstacle(
            x: newX,
            y: newY,
            width: newWidth,
            height: newHeight,
          ));
          validPosition = true;
        }
      }
    }
    
    // Genera posición del objetivo evitando obstáculos
    bool validPosition = false;
    int attempts = 0;
    
    while (!validPosition && attempts < 30) {
      attempts++;
      final targetX = (random.nextDouble() * 2 - 1) * 0.8;
      final targetY = (random.nextDouble() * 2 - 1) * 0.8;
      
      // Verifica que no esté muy cerca del inicio
      if (sqrt(targetX * targetX + targetY * targetY) < 0.3) {
        continue;
      }
      
      // Verificar que no esté dentro de un obstáculo
      bool insideObstacle = false;
      for (var obstacle in _obstacles) {
        final dx = (targetX - obstacle.x).abs();
        final dy = (targetY - obstacle.y).abs();
        
        if (dx < obstacle.width / 2 + 0.1 && dy < obstacle.height / 2 + 0.1) {
          insideObstacle = true;
          break;
        }
      }
      
      if (!insideObstacle) {
        _targetPosition = Offset(targetX, targetY);
        validPosition = true;
      }
    }
    
    // Si no se encontró posición válida, usar una por defecto
    if (!validPosition) {
      _targetPosition = Offset(0.7, 0.7);
    }
  }

  /// Verifica colisiones con obstáculos y bordes
  void _checkCollisions() {
    // Colisión con bordes (resetea velocidad)
    if (_ballX.abs() > 0.95) {
      _velocityX *= -0.5;
      _ballX = _ballX.clamp(-0.95, 0.95);
    }
    if (_ballY.abs() > 0.95) {
      _velocityY *= -0.5;
      _ballY = _ballY.clamp(-0.95, 0.95);
    }
    
    // Colisión con obstáculos
    for (var obstacle in _obstacles) {
      if (_ballX > obstacle.x - obstacle.width / 2 &&
          _ballX < obstacle.x + obstacle.width / 2 &&
          _ballY > obstacle.y - obstacle.height / 2 &&
          _ballY < obstacle.y + obstacle.height / 2) {
        // Game over
        setState(() {
          _gameOver = true;
          _gameStarted = false;
        });
        _accelerometerSubscription?.cancel();
        _gameTimer?.cancel();
        break;
      }
    }
  }

  /// Verifica si llegó al objetivo
  void _checkTarget() {
    if (_targetPosition != null) {
      final distance = sqrt(
        pow(_ballX - _targetPosition!.dx, 2) + 
        pow(_ballY - _targetPosition!.dy, 2)
      );
      
      if (distance < 0.1) {
        // ¡Nivel completado!
        setState(() {
          _score += 100 * _level;
          _level++;
          _ballX = 0.0;
          _ballY = 0.0;
          _velocityX = 0.0;
          _velocityY = 0.0;
          _generateLevel();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Juego de Movimiento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_gameStarted)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Nivel $_level',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Panel de información
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.light,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(
                  icon: Icons.stars,
                  label: 'Puntos',
                  value: '$_score',
                  color: AppColors.warning,
                ),
                _buildInfoChip(
                  icon: Icons.flag,
                  label: 'Nivel',
                  value: '$_level',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          
          // Área de juego
          Expanded(
            child: Stack(
              children: [
                // Fondo del juego
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.light,
                        AppColors.background,
                      ],
                    ),
                  ),
                  child: _gameStarted
                      ? _buildGameArea()
                      : _buildStartScreen(),
                ),
                
                // Overlay de game over
                if (_gameOver) _buildGameOverOverlay(),
              ],
            ),
          ),
          
          // Instrucciones
          if (!_gameStarted && !_gameOver)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phonelink_setup,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Inclina tu dispositivo para mover la pelota',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar Juego'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Widget de chip de información
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pantalla de inicio
  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_esports,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¡Esquiva los obstáculos!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Llega al objetivo verde para avanzar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Área de juego
  Widget _buildGameArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        
        return Stack(
          children: [
            // Obstáculos
            ..._obstacles.map((obstacle) {
              return Positioned(
                left: centerX + obstacle.x * size.width / 2 - 
                      obstacle.width * size.width / 4,
                top: centerY + obstacle.y * size.height / 2 - 
                     obstacle.height * size.height / 4,
                child: Container(
                  width: obstacle.width * size.width / 2,
                  height: obstacle.height * size.height / 2,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Objetivo
            if (_targetPosition != null)
              Positioned(
                left: centerX + _targetPosition!.dx * size.width / 2 - 20,
                top: centerY + _targetPosition!.dy * size.height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            
            // Pelota
            Positioned(
              left: centerX + _ballX * size.width / 2 - _ballSize / 2,
              top: centerY + _ballY * size.height / 2 - _ballSize / 2,
              child: Container(
                width: _ballSize,
                height: _ballSize,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Overlay de game over
  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Game Over!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Puntuación: $_score',
                style: const TextStyle(
                  fontSize: 24,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Nivel alcanzado: $_level',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _initGame();
                  _startGame();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Jugar de Nuevo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clase para representar un obstáculo
class Obstacle {
  final double x;
  final double y;
  final double width;
  final double height;

  Obstacle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}
