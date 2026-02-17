import 'package:flutter/material.dart';

class PostLocationPin extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;

  const PostLocationPin({
    super.key,
    required this.imageUrl,
    this.size = 60.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Chiều cao đuôi = 35% của size
    final tailHeight = size * 0.35;
    
    // Tổng chiều cao đến mũi nhọn
    final heightToTip = size + tailHeight;

    return SizedBox(
      width: size,
      height: heightToTip,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // Lớp vẽ Pin + Bóng
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -20,
              child: CustomPaint(
                painter: _PostPinPainter(
                  size: size,
                  tailHeight: tailHeight,
                ),
              ),
            ),

            // Lớp hình ảnh bài post
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image,
                      size: size * 0.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),

            // Icon post nhỏ ở góc trên phải
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.article,
                  size: size * 0.25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostPinPainter extends CustomPainter {
  final double size;
  final double tailHeight;

  _PostPinPainter({
    required this.size,
    required this.tailHeight,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final path = Path();

    // Vẽ hình chữ nhật (phần pin trên)
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(8),
    );

    // Tính toán điểm đỉnh nhọn
    final tipX = size / 2;
    final tipY = size + tailHeight;

    // Vẽ phần đuôi (tam giác)
    path.moveTo(tipX, tipY); // Đỉnh nhọn
    path.lineTo(size * 0.65, size); // Góc phải dưới của hình chữ nhật
    path.lineTo(size * 0.35, size); // Góc trái dưới của hình chữ nhật
    path.close();

    // Vẽ bóng
    canvas.drawRRect(rect.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(path.shift(const Offset(0, 3)), shadowPaint);

    // Vẽ pin
    canvas.drawRRect(rect, paint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
