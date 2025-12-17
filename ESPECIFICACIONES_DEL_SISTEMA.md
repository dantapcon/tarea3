# Especificaciones del Sistema
## Tarea 3: Uso de Sensores en Flutter

---

## 📦 Librerías y Paquetes Utilizados

### Dependencias Principales
```yaml
sensors_plus: ^7.0.0
```
- **Propósito**: Acceso a sensores del dispositivo (acelerómetro, giroscopio, magnetómetro)
- **Uso**: Lectura de datos en tiempo real de sensores de movimiento

```yaml
flutter_compass: ^0.8.1
```
- **Propósito**: Acceso al sensor de brújula/magnetómetro
- **Uso**: Obtener dirección cardinal y ángulo de orientación del dispositivo

```yaml
fl_chart: ^1.1.1
```
- **Propósito**: Librería de gráficos (incluida pero no utilizada actualmente)
- **Uso potencial**: Visualización de datos de sensores en gráficas

---

## 🖥️ Estructura de Pantallas

### 1. **HomeScreen** (Pantalla de Inicio)
- **Ubicación**: `lib/screens/home_screen.dart`
- **Descripción**: Pantalla de bienvenida con información académica
- **Componentes**:
  - Logo de la ESPE (cargado desde URL)
  - Información del estudiante (nombre, materia, nivel)
  - Título del proyecto
  - Tarjetas informativas sobre Dashboard y Juego

### 2. **DashboardScreen** (Dashboard de Sensores)
- **Ubicación**: `lib/screens/dashboard_screen.dart`
- **Descripción**: Visualización en tiempo real de múltiples sensores
- **Componentes**:
  - Tarjetas de sensores con datos en tiempo real
  - Visualización de ejes X, Y, Z con barras de progreso
  - Brújula visual con representación circular

### 3. **GameScreen** (Juego Controlado por Movimiento)
- **Ubicación**: `lib/screens/game_screen.dart`
- **Descripción**: Juego de laberinto controlado por inclinación del dispositivo
- **Componentes**:
  - Área de juego con física en tiempo real
  - Sistema de obstáculos y objetivos
  - Panel de información (puntos, nivel, tiempo)

---

## 📊 Dashboard de Sensores - Construcción y Detección

### Arquitectura del Dashboard

#### **Inicialización de Sensores**
```dart
void _initSensors() {
  // Timer para actualizar UI cada 100ms (throttling)
  _updateTimer = Timer.periodic(Duration(milliseconds: 100), ...);
  
  // Listeners de sensores (actualizan variables sin setState)
  accelerometerEventStream().listen(...);
  gyroscopeEventStream().listen(...);
  magnetometerEventStream().listen(...);
  FlutterCompass.events.listen(...);
}
```

### Sensores Implementados

#### **1. Acelerómetro**
- **Datos capturados**: Aceleración en 3 ejes (X, Y, Z) en m/s²
- **Stream**: `accelerometerEventStream()`
- **Actualización**: Continua, UI actualizada cada 100ms
- **Visualización**: 
  - Barras de progreso coloreadas por eje (Rojo-X, Verde-Y, Azul-Z)
  - Valores numéricos con 2 decimales
  - Rango visualizado: -10 a +10 m/s²

#### **2. Giroscopio**
- **Datos capturados**: Velocidad angular en 3 ejes (X, Y, Z) en rad/s
- **Stream**: `gyroscopeEventStream()`
- **Actualización**: Continua, UI actualizada cada 100ms
- **Visualización**: 
  - Barras de progreso por eje
  - Valores numéricos con 2 decimales
  - Representa rotación del dispositivo

#### **3. Magnetómetro**
- **Datos capturados**: Campo magnético en 3 ejes (X, Y, Z) en µT
- **Stream**: `magnetometerEventStream()`
- **Actualización**: Continua, UI actualizada cada 100ms
- **Visualización**: 
  - Barras de progreso por eje
  - Valores numéricos con 2 decimales
  - Útil para detectar campos magnéticos cercanos

#### **4. Brújula**
- **Datos capturados**: Ángulo de orientación (0-360°) y dirección cardinal
- **Stream**: `FlutterCompass.events`
- **Actualización**: Continua, UI actualizada cada 100ms
- **Visualización**:
  - Círculo con aguja roja apuntando al norte magnético
  - Marcadores cardinales (N, E, S, O)
  - Dirección en grados y texto (N, NE, E, SE, S, SO, O, NO)
  - Cálculo de dirección mediante rangos de ángulos

### Optimización de Rendimiento
- **Throttling**: UI actualizada solo 10 veces por segundo (cada 100ms)
- **Separación de lógica**: Listeners actualizan variables, Timer actualiza UI
- **Beneficios**: 
  - Valores legibles (no parpadean)
  - Menor consumo de batería
  - Mejor rendimiento general

---

## 🎮 Juego - Construcción y Uso de Sensores

### Arquitectura del Juego

#### **Sistema de Física**
```dart
// Control basado en inclinación del dispositivo
_velocityX = -event.x * 0.4;  // Sensibilidad controlada
_velocityY = event.y * 0.4;

// Límites de velocidad para control preciso
_velocityX = _velocityX.clamp(-3.0, 3.0);
_velocityY = _velocityY.clamp(-3.0, 3.0);

// Actualización de posición
_ballX += _velocityX * 0.015;
_ballY += _velocityY * 0.015;
```

### Uso de Sensores

#### **Acelerómetro para Control de Movimiento**
- **Sensor utilizado**: Acelerómetro (eje X e Y)
- **Función**: Detectar inclinación del dispositivo
- **Mapeo**:
  - **Eje X del sensor** → Movimiento horizontal de la pelota (invertido)
  - **Eje Y del sensor** → Movimiento vertical de la pelota
  - Multiplicador de sensibilidad: 0.4 (control suave)
- **Frecuencia**: Actualización continua (≈100 Hz)
- **Límites**: Velocidad máxima ±3.0 unidades/frame

#### **Sistema Coordinado**
```
Inclinación → Aceleración → Velocidad → Posición
    ↓              ↓             ↓          ↓
  event.x     -event.x*0.4   _velocityX  _ballX
  event.y      event.y*0.4   _velocityY  _ballY
```

### Mecánicas del Juego

#### **Generación de Niveles**
- **Obstáculos**: 3 + nivel actual (máximo 6)
- **Tamaño**: Aleatorio entre 0.12 y 0.20 unidades
- **Distribución**: Sistema anti-superposición
  - Distancia mínima entre obstáculos: margen de 0.1 unidades
  - Verificación en coordenadas X e Y
  - Máximo 20 intentos por obstáculo

#### **Sistema de Colisiones**
- **Detección**: Comparación de coordenadas por frames
- **Colisión con bordes**: Rebote con pérdida de velocidad (50%)
- **Colisión con obstáculos**: Game Over inmediato
- **Llegada a objetivo**: Avance de nivel y aumento de puntuación

#### **Sistema de Puntuación**
- **Fórmula**: 100 × nivel alcanzado
- **Visualización**: Puntuación actual, nivel alcanzado y tiempo transcurrido

---

## 🎨 Sistema de Colores

### Paleta Verde Pastel
- **Archivo**: `lib/utils/colors.dart`
- **Colores principales**:
  - Primary: `#A8E6CF` (Verde pastel claro)
  - Secondary: `#88D9B8` (Verde pastel medio)
  - Accent: `#B8F3D8` (Verde menta)
  - Background: `#F5FFFA` (Blanco verdoso)
- **Gradientes**: 
  - `primaryGradient`: Primary → Secondary
  - `lightGradient`: Light → Background

---

## 🧩 Componentes Reutilizables

### SensorCard
- **Ubicación**: `lib/widgets/sensor_card.dart`
- **Propósito**: Tarjeta estilizada para mostrar datos de sensores
- **Props**: título, ícono, valor, subtítulo, color

### AxisDataWidget
- **Ubicación**: `lib/widgets/sensor_card.dart`
- **Propósito**: Visualización de datos en 3 ejes (X, Y, Z)
- **Características**: 
  - Barras de progreso coloreadas
  - Valores numéricos
  - Rango normalizado -10 a +10

---

## ⚡ Especificaciones Técnicas Adicionales

### Requisitos del Sistema
- **Flutter SDK**: 3.10.1+
- **Dart SDK**: 3.10.1+
- **Android**: API 21+ (Android 5.0 Lollipop)
- **iOS**: iOS 11.0+

### Permisos Necesarios
- **Ninguno explícito**: Los sensores de movimiento no requieren permisos en Android/iOS

### Navegación
- **Sistema**: BottomNavigationBar con 3 pestañas
- **Estado**: Mantenido por MainScreen (StatefulWidget)
- **Transiciones**: Instantáneas entre pantallas

### Optimizaciones Implementadas
1. **Throttling de sensores**: UI actualizada cada 100ms
2. **Listeners sin setState**: Separación de lógica y UI
3. **Límites de velocidad**: Control preciso en el juego
4. **Sistema anti-superposición**: Generación eficiente de obstáculos
5. **SingleChildScrollView**: Prevención de overflow en pantallas

### Manejo de Errores
- **Imágenes de red**: ErrorBuilder con ícono de respaldo
- **Sensores no disponibles**: Valores en 0 sin crash

---

## 📝 Notas de Implementación



### Código Limpio
- Comentarios concisos y descriptivos
- Nombres de variables claros
- Separación en archivos lógicos
- Widgets reutilizables
- Documentación de métodos con `///`

---

**Última actualización**: 16 de diciembre de 2025
**Autor**: Danilo Josué Tapia Condorcana
**Materia**: Desarrollo de Aplicaciones Móviles - Nivel Sexto
