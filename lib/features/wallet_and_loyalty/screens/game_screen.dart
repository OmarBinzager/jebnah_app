import 'dart:math';
import 'package:flutter/material.dart';

// =========================================================
// الواجهة الرئيسية - لوحة التحكم والإحصائيات
// =========================================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // بيانات الإحصائيات المشتركة بين اللعبتين
  int totalPoints = 0;
  int gamesPlayed = 0;
  int winsCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // المساحة العلوية
            const SizedBox(height: 20),

            // بطاقة الإحصائيات
            _buildStatsCard(),

            const SizedBox(height: 40),

            // عنوان الألعاب
            const Text(
              'اختر لعبتك المفضلة',
              style: TextStyle(
                color: Color(0xFF3B155B),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            // أيقونات الألعاب
            _buildGamesGrid(),

            const Spacer(),

            // نص سفلي
          ],
        ),
      ),
    );
  }

  // عنوان التطبيق
  Widget _buildAppTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars, color: Color(0xFFFFD54F), size: 28),
          SizedBox(width: 12),
          Text(
            '🎯 ألعاب النقاط',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة الإحصائيات
  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dashboard, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                'لوحة التحكم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '⭐ النقاط',
                '$totalPoints',
                Icons.stars_rounded,
                const Color(0xFFFFD600),
              ),
              _buildStatItem(
                '🎮 لعب',
                '$gamesPlayed',
                Icons.games_rounded,
                const Color(0xFF00E676),
              ),
              _buildStatItem(
                '🏆 فوز',
                '$winsCount',
                Icons.emoji_events_rounded,
                const Color(0xFFFF4081),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // شبكة أيقونات الألعاب
  Widget _buildGamesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGameIcon(
            icon: Icons.casino_rounded,
            label: 'عجلة الحظ',
            color: const Color(0xFFE91E63),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WheelGameScreen(),
                ),
              ).then((result) {
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    totalPoints += result['points'] as int;
                    gamesPlayed++;
                    if (result['won'] ?? false) winsCount++;
                  });
                }
              });
            },
          ),
          const SizedBox(width: 40),
          _buildGameIcon(
            icon: Icons.inventory_2_rounded,
            label: 'تجميع المواد',
            color: const Color(0xFF4CAF50),
            onTap: () {
              _showComingSoonDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3B155B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // رسالة "قريباً"
  void _showComingSoonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, color: Color(0xFFFFD600)),
            SizedBox(width: 10),
            Text(
              'قريباً!',
              style: TextStyle(
                color: Color(0xFF3B155B),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.build_circle_rounded,
              color: Color(0xFFFF6B6B),
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'لعبة تجميع المواد\nقريباً جداً!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3B155B),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '⏳ نعمل على تطويرها لك',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// واجهة لعبة عجلة الحظ (محسّنة)
// =========================================================
class WheelGameScreen extends StatefulWidget {
  const WheelGameScreen({super.key});

  @override
  State<WheelGameScreen> createState() => _WheelGameScreenState();
}

class _WheelGameScreenState extends State<WheelGameScreen>
    with SingleTickerProviderStateMixin {
  static const Color purpleBgStart = Color(0xFF532876);
  static const Color purpleBgEnd = Color(0xFF3B155B);

  late AnimationController _animationController;
  late Animation<double> _wheelAnimation;

  bool isSpinning = false;
  int spinsLeft = 5;
  int totalScore = 0;
  String lastPrize = '';
  double currentAngle = 0.0;
  int roundWins = 0;

  // 12 قسم متناوب: قنبلة / عملات
  final List<Map<String, dynamic>> items = [
    {'type': 'coins', 'label': '500', 'value': 500},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
    {'type': 'coins', 'label': '1000', 'value': 1000},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
    {'type': 'coins', 'label': '2000', 'value': 2000},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
    {'type': 'coins', 'label': '5000', 'value': 5000},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
    {'type': 'coins', 'label': '10000', 'value': 10000},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
    {'type': 'coins', 'label': '20000', 'value': 20000},
    {'type': 'bomb', 'label': 'قنبلة', 'value': 0},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (isSpinning) return;
    if (spinsLeft <= 0) {
      _showGameOverDialog();
      return;
    }

    final random = Random();
    int targetIndex = random.nextInt(items.length);

    double sliceAngle = (2 * pi) / items.length;
    double targetAngle = (10 * 2 * pi) + (targetIndex * sliceAngle);

    _wheelAnimation =
        Tween<double>(
          begin: currentAngle,
          end: currentAngle + targetAngle,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    setState(() => isSpinning = true);

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        isSpinning = false;
        currentAngle = (_wheelAnimation.value) % (2 * pi);
        spinsLeft--;

        final selectedItem = items[targetIndex];
        if (selectedItem['type'] == 'coins') {
          totalScore += selectedItem['value'] as int;
          lastPrize = selectedItem['label'];
          roundWins++;
        } else {
          lastPrize = '💥 قنبلة';
        }

        _showResultDialog(selectedItem);
      });
    });
  }

  void _showResultDialog(Map<String, dynamic> item) {
    bool isBomb = item['type'] == 'bomb';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          isBomb ? '💥 حظ أوفر!' : '🎉 مبروك!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B155B),
            fontSize: 24,
          ),
        ),
        content: Text(
          isBomb
              ? 'لقد حصلت على قنبلة! 😅'
              : 'حصلت على ${item['label']} قطعة ذهبية! 🪙',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF3B155B), fontSize: 18),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBomb
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'متابعة',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          '🏆 انتهت المحاولات!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B155B),
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إجمالي النقاط: $totalScore',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF6B00),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'عدد مرات الفوز: $roundWins',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF3B155B), fontSize: 16),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'points': totalScore,
                    'won': roundWins > 0,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'العودة',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    spinsLeft = 5;
                    totalScore = 0;
                    lastPrize = '';
                    roundWins = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'إعادة اللعب',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // زر العودة (تم إصلاح موضعه إلى الجهة اليسرى)
            Positioned(
              top: 10,
              left: 15,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'points': totalScore,
                      'won': roundWins > 0,
                    });
                  },
                ),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 10),
                _buildHeaderBanner(),
                const SizedBox(height: 15),
                _buildStatsCard(),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double size = min(
                          constraints.maxWidth * 0.85,
                          constraints.maxHeight * 0.85,
                        );
                        return SizedBox(
                          width: size,
                          height: size,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animationController.isAnimating
                                        ? _wheelAnimation.value
                                        : currentAngle,
                                    child: CustomPaint(
                                      size: Size(size, size),
                                      painter: DetailedWheelPainter(
                                        items: items,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(top: -16, child: _buildPointer()),
                              _buildCenterSpinButton(size * 0.28),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B155B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B155B).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'النقاط',
            '$totalScore',
            Icons.stars_rounded,
            const Color(0xFFFFD600),
          ),
          _buildDivider(),
          _buildStatItem(
            'المحاولات',
            '$spinsLeft',
            Icons.replay_rounded,
            const Color(0xFF00E676),
          ),
          _buildDivider(),
          _buildStatItem(
            'الجائزة',
            lastPrize.isEmpty ? '---' : lastPrize,
            Icons.emoji_events_rounded,
            const Color(0xFFFF4081),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF3B155B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF3B155B),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(
    height: 28,
    width: 1,
    color: const Color(0xFF3B155B).withOpacity(0.2),
  );

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F), width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Text(
        '🎡 عجلة الحظ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPointer() =>
      CustomPaint(size: const Size(32, 32), painter: TrianglePainter());

  Widget _buildCenterSpinButton(double buttonSize) {
    return GestureDetector(
      onTap: _spinWheel,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: const Color(0xFFFFECB3),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFB300), width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF3F51B5),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$spinsLeft',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'تدوير',
              style: TextStyle(
                color: Color(0xFF283593),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// رسام العجلة
// =========================================================
class DetailedWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;

  DetailedWheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(radius, radius);
    double angleStep = (2 * pi) / items.length;

    // خلفية العجلة (رمادية فاتحة للخلفية البيضاء)
    Paint outerCircle = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawCircle(center, radius, outerCircle);

    for (int i = 0; i < items.length; i++) {
      double startAngle = i * angleStep - (pi / 2);
      Paint slicePaint = Paint()
        ..color = (i % 2 == 1)
            ? const Color(0xFFFFB0CF)
            : const Color(0xFFFFF7FA);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        angleStep,
        true,
        slicePaint,
      );
    }

    for (int i = 0; i < items.length; i++) {
      double midAngle = (i * angleStep - (pi / 2)) + (angleStep / 2);
      var item = items[i];

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(midAngle + pi / 2);

      if (item['type'] == 'bomb') {
        double contentY = -radius * 0.58;
        Paint bombPaint = Paint()..color = const Color(0xFF1A1A1A);
        canvas.drawCircle(Offset(0, contentY), 14, bombPaint);
        Paint topPaint = Paint()..color = const Color(0xFF757575);
        canvas.drawRect(Rect.fromLTWH(-3, contentY - 17, 6, 4), topPaint);
        Paint fusePaint = Paint()
          ..color = const Color(0xFFFF5722)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        Path fusePath = Path()
          ..moveTo(0, contentY - 17)
          ..quadraticBezierTo(5, contentY - 22, 2, contentY - 26);
        canvas.drawPath(fusePath, fusePaint);
        canvas.drawCircle(
          Offset(2, contentY - 26),
          2,
          Paint()..color = const Color(0xFFFFD600),
        );
      } else {
        double contentY = -radius * 0.62;
        RRect cardRRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, contentY + 16),
            width: 44,
            height: 18,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(cardRRect, Paint()..color = const Color(0xFFE0E0E0));
        canvas.drawRRect(
          cardRRect,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );

        TextPainter tp = TextPainter(
          text: TextSpan(
            text: item['label'],
            style: const TextStyle(
              color: Color(0xFF37474F),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.rtl,
        );
        tp.layout();
        tp.paint(canvas, Offset(-tp.width / 2, contentY + 10));

        Paint goldPaint = Paint()..color = const Color(0xFFFFD600);
        Paint darkGoldPaint = Paint()..color = const Color(0xFFFFA000);

        canvas.drawCircle(Offset(-5, contentY - 2), 7, goldPaint);
        canvas.drawCircle(
          Offset(-5, contentY - 2),
          7,
          darkGoldPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          Offset(5, contentY - 2),
          7,
          goldPaint..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(5, contentY - 2),
          7,
          darkGoldPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          Offset(0, contentY - 7),
          8,
          goldPaint..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset(0, contentY - 7),
          8,
          darkGoldPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
      canvas.restore();
    }

    Paint innerBorder = Paint()
      ..color = const Color(0xFF4A1A6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 6, innerBorder);

    for (int i = 0; i < 20; i++) {
      double dotsAngle = i * (2 * pi / 20);
      double dx = center.dx + (radius - 5) * cos(dotsAngle);
      double dy = center.dy + (radius - 5) * sin(dotsAngle);
      canvas.drawCircle(
        Offset(dx, dy),
        2.5,
        Paint()..color = const Color(0xFFFFD600),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =========================================================
// رسم مثلث المؤشر
// =========================================================
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color(0xFFFFD600);
    Paint borderPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================
// تشغيل التطبيق
// =========================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألعاب النقاط',
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const GameScreen(),
    );
  }
}
