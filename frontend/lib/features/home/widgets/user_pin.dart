import 'package:flutter/material.dart';

class UserLocationPin extends StatelessWidget {
  final String imageUrl;
  final double size; 
  final Color color; 

  const UserLocationPin({
    super.key,
    required this.imageUrl,
    this.size = 60.0,
    this.color = const Color(0xFF00E676), 
  });

  @override
  Widget build(BuildContext context) {
    // Chiều cao đuôi = 35% hình tròn
    final tailHeight = size * 0.35; 
    
    // TỔNG CHIỀU CAO CHÍNH XÁC ĐẾN MŨI NHỌN (Không tính bóng)
    // Đây là con số quan trọng để Marker căn chỉnh
    final heightToTip = size + tailHeight;

    return SizedBox(
      width: size,
      height: heightToTip, // Widget chỉ cao đến đúng mũi nhọn
      
      // Dùng Stack với Clip.none để cho phép bóng vẽ tràn ra ngoài khung
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, 
        children: [
          // Lớp vẽ Pin + Bóng
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Cho phép height vẽ dài hơn kích thước thật để chứa bóng
            bottom: -20, // Mở rộng vùng vẽ xuống dưới đáy 20px
            child: CustomPaint(
              painter: _PinPainter(
                color: color, 
                circleDiameter: size,
                tailHeight: tailHeight
              ),
            ),
          ),

          // Lớp Avatar (Giữ nguyên)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                 // Bóng nhẹ cho khối tròn
                 BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            padding: EdgeInsets.all(size * 0.06), 
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: size * 0.03),
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => 
                    Container(color: Colors.grey[300], child: Icon(Icons.person)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color color;
  final double circleDiameter;
  final double tailHeight;

  _PinPainter({
    required this.color,
    required this.circleDiameter,
    required this.tailHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color..style = PaintingStyle.fill;
    
    // Bóng đổ: Vẽ thấp hơn mũi nhọn 3px
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final path = Path();
    final width = circleDiameter;
    final circleCenterY = width / 2; 
    
    // Đỉnh nhọn nằm chính xác ở đáy của phần "heightToTip"
    // Lưu ý: Trong CustomPaint này, ta đang vẽ trong khung rộng hơn
    // nên ta vẫn dùng logic cũ để xác định mũi nhọn
    final tipY = width + tailHeight; 

    // Vẽ hình dáng Pin
    path.moveTo(width / 2, tipY); // Đỉnh nhọn
    path.lineTo(width, circleCenterY);
    path.arcToPoint(Offset(0, circleCenterY), radius: Radius.circular(width/2), clockwise: false);
    path.close();

    // 1. Vẽ bóng trước (Dịch xuống 3px -> Nó sẽ lòi ra khỏi widget cha)
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);
    
    // 2. Vẽ Pin
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}