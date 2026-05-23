import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quantum Calculator'),
    );
  }
}

// -------------------------------------------------------------
// Pure Dart Math Expression Parser (Self-contained & Robust)
// -------------------------------------------------------------
class ExpressionEvaluator {
  static double evaluate(String expression) {
    // 1. Clean expression characters
    String expr = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll(' ', '');

    if (expr.isEmpty) return 0.0;

    int pos = -1;
    int ch = -1;

    void nextChar() {
      pos++;
      ch = (pos < expr.length) ? expr.codeUnitAt(pos) : -1;
    }

    bool eat(int charToEat) {
      while (ch == 32) {
        nextChar();
      }
      if (ch == charToEat) {
        nextChar();
        return true;
      }
      return false;
    }

    late double Function() parseExpression;
    late double Function() parseTerm;
    late double Function() parseFactor;

    parseExpression = () {
      double x = parseTerm();
      for (;;) {
        if (eat(43)) { // '+'
          x += parseTerm();
        } else if (eat(45)) { // '-'
          x -= parseTerm();
        } else {
          return x;
        }
      }
    };

    parseTerm = () {
      double x = parseFactor();
      for (;;) {
        if (eat(42)) { // '*'
          x *= parseFactor();
        } else if (eat(47)) { // '/'
          double divisor = parseFactor();
          if (divisor == 0.0) throw Exception('Div by zero');
          x /= divisor;
        } else {
          return x;
        }
      }
    };

    parseFactor = () {
      if (eat(43)) return parseFactor(); // unary plus
      if (eat(45)) return -parseFactor(); // unary minus

      double x;
      int startPos = pos;
      if (eat(40)) { // '('
        x = parseExpression();
        if (!eat(41)) throw Exception('Missing closing )');
      } else if ((ch >= 48 && ch <= 57) || ch == 46) { // numbers & decimal point
        while ((ch >= 48 && ch <= 57) || ch == 46) {
          nextChar();
        }
        x = double.parse(expr.substring(startPos, pos));
      } else {
        throw Exception('Syntax error');
      }

      return x;
    };

    nextChar();
    double result = parseExpression();
    if (pos < expr.length) {
      throw Exception('Extra characters');
    }
    return result;
  }
}

// -------------------------------------------------------------
// Particle Physics Model
// -------------------------------------------------------------
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double opacity;
  double life; // range 1.0 down to 0.0

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    this.opacity = 1.0,
    this.life = 1.0,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.15; // subtle gravity acceleration
    life -= 0.024; // speed of fade out
    if (opacity > 0) {
      opacity = life.clamp(0.0, 1.0);
    }
  }
}

// -------------------------------------------------------------
// Interactive Screen Shake Widget on Errors
// -------------------------------------------------------------
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final AnimationController controller;

  const ShakeWidget({super.key, required this.child, required this.controller});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        // Elastic shake using sine wave oscillation
        final double offset = 15.0 * math.sin(widget.controller.value * 4 * math.pi);
        return Transform.translate(
          offset: Offset(offset, 0.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// -------------------------------------------------------------
// MyHomePage main view state
// -------------------------------------------------------------
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  String _inputExpression = '';
  String _calculatedResult = '0';
  bool _isEvaluated = false;

  // Active particles list
  final List<Particle> _particles = [];

  // Controllers
  late AnimationController _bgController;       // Drifting space background
  late AnimationController _physicsController;  // 60FPS particle physics loop
  late AnimationController _entranceController; // Keyboard staggered entry
  late AnimationController _shakeController;    // Error glass shake

  // Entrance animations
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;

  bool _isCyberTheme = false; // Cosmic Space vs Cyberpunk theme toggler

  // Colors Palette - Space Purple Theme
  final Color _spaceDigitColor = const Color(0xFF00FFFF);    // Neon Cyan
  final Color _spaceOperatorColor = const Color(0xFFFF007F); // Neon Hot Pink
  final Color _spaceActionColor = const Color(0xFF8A2BE2);   // Neon Violet
  final Color _spaceEqualColor = const Color(0xFF39FF14);    // Glowing Green

  // Colors Palette - Cyberpunk Theme
  final Color _cyberDigitColor = const Color(0xFF39FF14);    // Neon Lime Green
  final Color _cyberOperatorColor = const Color(0xFFFF5F1F); // Neon Orange
  final Color _cyberActionColor = const Color(0xFFFFE600);   // Neon Yellow
  final Color _cyberEqualColor = const Color(0xFF00FFFF);    // Cyber Cyan

  // Get active colors based on theme choice
  Color get _digitColor => _isCyberTheme ? _cyberDigitColor : _spaceDigitColor;
  Color get _operatorColor => _isCyberTheme ? _cyberOperatorColor : _spaceOperatorColor;
  Color get _actionColor => _isCyberTheme ? _cyberActionColor : _spaceActionColor;
  Color get _equalColor => _isCyberTheme ? _cyberEqualColor : _spaceEqualColor;

  @override
  void initState() {
    super.initState();

    // 1. Ambient Background Drifter
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 2. 60FPS Physics Tick loop (conserves battery when clear)
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        if (_particles.isNotEmpty) {
          setState(() {
            for (int i = _particles.length - 1; i >= 0; i--) {
              _particles[i].update();
              if (_particles[i].life <= 0) {
                _particles.removeAt(i);
              }
            }
          });
        } else {
          if (_physicsController.isAnimating) {
            _physicsController.stop();
          }
        }
      });

    // 3. Page Entry sequence
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // 4. Elastic shake feedback for syntax/math errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _physicsController.dispose();
    _entranceController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Spark burst physics launcher from global coordinates
  void _spawnSparkParticles(Offset globalPosition, Color baseColor) {
    final random = math.Random();
    setState(() {
      for (int i = 0; i < 15; i++) {
        final double angle = random.nextDouble() * 2 * math.pi;
        final double speed = random.nextDouble() * 5.0 + 2.0;
        final double vx = math.cos(angle) * speed;
        final double vy = math.sin(angle) * speed - 1.2;

        final double size = random.nextDouble() * 5.0 + 3.0;

        _particles.add(Particle(
          x: globalPosition.dx,
          y: globalPosition.dy,
          vx: vx,
          vy: vy,
          size: size,
          color: baseColor.withValues(alpha: 0.9),
        ));
      }
    });

    if (!_physicsController.isAnimating) {
      _physicsController.repeat();
    }
  }

  // Handle calculator key press actions
  void _handleButtonPress(String label, Color buttonColor) {
    setState(() {
      if (label == 'C') {
        _inputExpression = '';
        _calculatedResult = '0';
        _isEvaluated = false;
        _triggerResetWaterParticles();
      } else if (label == '⌫') {
        if (_isEvaluated) {
          _inputExpression = '';
          _calculatedResult = '0';
          _isEvaluated = false;
        } else if (_inputExpression.isNotEmpty) {
          _inputExpression = _inputExpression.substring(0, _inputExpression.length - 1);
        }
      } else if (label == '=') {
        _evaluateMathExpression();
      } else {
        // Clear previous calculation on typing new digits directly
        if (_isEvaluated) {
          if (label == '+' || label == '-' || label == '×' || label == '÷') {
            _inputExpression = _calculatedResult + label;
          } else {
            _inputExpression = label;
          }
          _isEvaluated = false;
        } else {
          _inputExpression += label;
        }
      }
    });
  }

  // Evaluation of math calculations with try/catch alerts
  void _evaluateMathExpression() {
    if (_inputExpression.isEmpty) return;

    try {
      final double result = ExpressionEvaluator.evaluate(_inputExpression);

      setState(() {
        // Clean trailing decimal values if integer (e.g. 15.0 -> 15)
        if (result == result.toInt()) {
          _calculatedResult = result.toInt().toString();
        } else {
          // Max decimal precision format
          _calculatedResult = double.parse(result.toStringAsFixed(6)).toString();
        }
        _isEvaluated = true;
      });

      // Special green success burst centered on display
      _triggerSuccessMilestoneSparks();
    } catch (e) {
      // Trigger Red Shaking Feedback on equation failures
      _shakeController.forward(from: 0.0);
      setState(() {
        _calculatedResult = 'Error';
        _isEvaluated = true;
      });

      _triggerWarningRubySparks();
    }
  }

  // Falling water blue reset sparks
  void _triggerResetWaterParticles() {
    final random = math.Random();
    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2;

    setState(() {
      for (int i = 0; i < 25; i++) {
        _particles.add(Particle(
          x: centerX + (random.nextDouble() - 0.5) * 250,
          y: 200.0 + (random.nextDouble() - 0.5) * 60,
          vx: (random.nextDouble() - 0.5) * 3,
          vy: random.nextDouble() * 3.5 + 2.0,
          size: random.nextDouble() * 4.0 + 2.0,
          color: const Color(0xFF00FFFF).withValues(alpha: 0.8),
        ));
      }
    });
    if (!_physicsController.isAnimating) {
      _physicsController.repeat();
    }
  }

  // Warning ruby sparkles
  void _triggerWarningRubySparks() {
    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2;
    final random = math.Random();

    setState(() {
      for (int i = 0; i < 30; i++) {
        _particles.add(Particle(
          x: centerX + (random.nextDouble() - 0.5) * 150,
          y: 220.0,
          vx: (random.nextDouble() - 0.5) * 7.0,
          vy: (random.nextDouble() - 0.5) * 5.0 - 2.0,
          size: random.nextDouble() * 5.0 + 3.0,
          color: const Color(0xFFFF003C), // Glowing Warning Red
        ));
      }
    });
    if (!_physicsController.isAnimating) {
      _physicsController.repeat();
    }
  }

  // Equal evaluation golden success particles
  void _triggerSuccessMilestoneSparks() {
    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2;
    final random = math.Random();

    setState(() {
      for (int i = 0; i < 35; i++) {
        final double angle = random.nextDouble() * 2 * math.pi;
        final double speed = random.nextDouble() * 5.5 + 3.0;

        _particles.add(Particle(
          x: centerX,
          y: 200.0,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 1.5,
          size: random.nextDouble() * 4.0 + 3.0,
          color: _equalColor,
        ));
      }
    });
    if (!_physicsController.isAnimating) {
      _physicsController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Opacity(
          opacity: _entranceController.value,
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          // Cyberpunk / Cosmic purple switcher
          IconButton(
            icon: Icon(
              _isCyberTheme ? Icons.bolt : Icons.bolt_outlined,
              color: _isCyberTheme ? const Color(0xFF39FF14) : const Color(0xFFFF007F),
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _isCyberTheme = !_isCyberTheme;

                // Theme switch rain sparkles
                final random = math.Random();
                for (int i = 0; i < 20; i++) {
                  _particles.add(Particle(
                    x: random.nextDouble() * size.width,
                    y: 70.0 + random.nextDouble() * 20.0,
                    vx: (random.nextDouble() - 0.5) * 2,
                    vy: random.nextDouble() * 3 + 1,
                    size: random.nextDouble() * 4.0 + 2.0,
                    color: _isCyberTheme ? const Color(0xFF39FF14) : const Color(0xFF8A2BE2),
                  ));
                }
              });
              if (!_physicsController.isAnimating) {
                _physicsController.repeat();
              }
            },
          ),
          const SizedBox(width: 12.0),
        ],
      ),
      body: Stack(
        children: [
          // 1. Nebula animated drifting background blobs
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(
                  _bgController.value,
                  isCyberTheme: _isCyberTheme,
                ),
                child: Container(),
              );
            },
          ),

          // 2. High-Fidelity glass calculator board layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _cardOpacity.value,
                      child: Transform.scale(
                        scale: _cardScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glass Screen Container
                        ShakeWidget(
                          controller: _shakeController,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.025),
                                  borderRadius: BorderRadius.circular(28.0),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 25.0,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Math History Display Row
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      reverse: true,
                                      child: Text(
                                        _inputExpression.isEmpty ? ' ' : _inputExpression,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.white38,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),

                                    // Dynamic Output Display (Fades when calculating)
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        _calculatedResult,
                                        key: ValueKey<String>(_calculatedResult),
                                        style: TextStyle(
                                          fontSize: 48.0,
                                          fontWeight: FontWeight.bold,
                                          color: _calculatedResult == 'Error'
                                              ? const Color(0xFFFF003C)
                                              : Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: _calculatedResult == 'Error'
                                                  ? const Color(0xFFFF003C).withValues(alpha: 0.5)
                                                  : _equalColor.withValues(alpha: 0.25),
                                              blurRadius: 18.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),

                        // Keyboard Grid Frame (Frosted container backing)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                            child: Container(
                              padding: const EdgeInsets.all(18.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.015),
                                borderRadius: BorderRadius.circular(28.0),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  width: 1.2,
                                ),
                              ),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                mainAxisSpacing: 14.0,
                                crossAxisSpacing: 14.0,
                                children: [
                                  // Row 1
                                  _buildKey('C', _actionColor),
                                  _buildKey('(', _operatorColor),
                                  _buildKey(')', _operatorColor),
                                  _buildKey('÷', _operatorColor),
                                  // Row 2
                                  _buildKey('7', _digitColor),
                                  _buildKey('8', _digitColor),
                                  _buildKey('9', _digitColor),
                                  _buildKey('×', _operatorColor),
                                  // Row 3
                                  _buildKey('4', _digitColor),
                                  _buildKey('5', _digitColor),
                                  _buildKey('6', _digitColor),
                                  _buildKey('-', _operatorColor),
                                  // Row 4
                                  _buildKey('1', _digitColor),
                                  _buildKey('2', _digitColor),
                                  _buildKey('3', _digitColor),
                                  _buildKey('+', _operatorColor),
                                  // Row 5
                                  _buildKey('0', _digitColor),
                                  _buildKey('.', _digitColor),
                                  _buildKey('⌫', _actionColor),
                                  _buildKey('=', _equalColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Absolute Overlay Canvas for explosive neon tap sparks
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ParticlePainter(_particles),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Key creation helper linking coordinate tapping and sparks
  Widget _buildKey(String label, Color inkColor) {
    return CalculatorButton(
      label: label,
      color: inkColor,
      onTap: () => _handleButtonPress(label, inkColor),
      onTapDown: (Offset pos) => _spawnSparkParticles(pos, inkColor),
    );
  }
}

// -------------------------------------------------------------
// Interactive Keyboard Key Button Widget
// -------------------------------------------------------------
class CalculatorButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Function(Offset pos) onTapDown;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.onTapDown,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    widget.onTapDown(details.globalPosition);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          // Press tactile scale shrink of 12%
          final double scale = 1.0 - (_pressController.value * 0.12);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.035),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.12 + (_pressController.value * 0.2)),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.04 + (_pressController.value * 0.12)),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    shadows: [
                      Shadow(
                        color: widget.color.withValues(alpha: 0.2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// Background painter: orbital floating gradient blobs
// -------------------------------------------------------------
class BackgroundPainter extends CustomPainter {
  final double progress;
  final bool isCyberTheme;

  BackgroundPainter(this.progress, {required this.isCyberTheme});

  @override
  void paint(Canvas canvas, Size size) {
    // Radical deep background gradients
    final Paint bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          isCyberTheme ? const Color(0xFF060B12) : const Color(0xFF0F0824),
          isCyberTheme ? const Color(0xFF030508) : const Color(0xFF05020E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final double phase = progress * 2.0 * math.pi;

    // Drifting Orb 1
    final double orb1x = size.width * 0.25 + size.width * 0.12 * math.cos(phase);
    final double orb1y = size.height * 0.32 + size.height * 0.08 * math.sin(phase);
    final Paint orb1Paint = Paint()
      ..color = isCyberTheme
          ? const Color(0xFF39FF14).withValues(alpha: 0.12)
          : const Color(0xFF8A2BE2).withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95.0);
    canvas.drawCircle(Offset(orb1x, orb1y), 160.0, orb1Paint);

    // Drifting Orb 2
    final double orb2x = size.width * 0.75 + size.width * 0.09 * math.sin(phase + 1.6);
    final double orb2y = size.height * 0.68 + size.height * 0.11 * math.cos(phase + 1.6);
    final Paint orb2Paint = Paint()
      ..color = isCyberTheme
          ? const Color(0xFF00FFFF).withValues(alpha: 0.12)
          : const Color(0xFFFF007F).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100.0);
    canvas.drawCircle(Offset(orb2x, orb2y), 190.0, orb2Paint);

    // Drifting Orb 3
    final double orb3x = size.width * 0.5 + size.width * 0.07 * math.sin(phase - 1.8);
    final double orb3y = size.height * 0.52 + size.height * 0.07 * math.cos(phase - 1.8);
    final Paint orb3Paint = Paint()
      ..color = isCyberTheme
          ? const Color(0xFFFFE600).withValues(alpha: 0.08)
          : const Color(0xFF00FFFF).withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 115.0);
    canvas.drawCircle(Offset(orb3x, orb3y), 170.0, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isCyberTheme != isCyberTheme;
  }
}

// -------------------------------------------------------------
// Particle Painter for launching neon sparks
// -------------------------------------------------------------
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      if (p.life <= 0) continue;
      final Paint paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);

      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
