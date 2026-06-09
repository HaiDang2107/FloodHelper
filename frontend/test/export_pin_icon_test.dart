import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:antiflood/ui/home/widgets/campaign_pin.dart';
import 'package:antiflood/ui/home/widgets/user_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    // 1. Load Material Icons font
    final iconFile = File('/home/haidang/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    if (await iconFile.exists()) {
      final fontData = await iconFile.readAsBytes();
      final fontLoader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(fontData)));
      await fontLoader.load();
    }

    // 2. Load Roboto font for text rendering
    final robotoLoader = FontLoader('Roboto');
    final robotoFile = File('/home/haidang/flutter/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    if (await robotoFile.exists()) {
      final fontData = await robotoFile.readAsBytes();
      robotoLoader.addFont(Future.value(ByteData.sublistView(fontData)));
    }
    final robotoBoldFile = File('/home/haidang/flutter/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf');
    if (await robotoBoldFile.exists()) {
      final fontData = await robotoBoldFile.readAsBytes();
      robotoLoader.addFont(Future.value(ByteData.sublistView(fontData)));
    }
    await robotoLoader.load();
  });

  // Custom helper to capture and save the widget at a high pixel ratio
  Future<void> exportHighResImage(WidgetTester tester, String fileName) async {
    final RenderRepaintBoundary boundary = tester.renderObject(find.byKey(const ValueKey('export_key')));
    
    // Wrap asynchronous platform calls in runAsync to prevent tests hanging
    await tester.runAsync(() async {
      // Render at 6x resolution
      final ui.Image image = await boundary.toImage(pixelRatio: 6.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      final file = File('test/goldens/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(pngBytes);
    });
  }

  Widget buildPinTestWidget({
    required Color color,
    required bool isSosState,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: RepaintBoundary(
            key: const ValueKey('export_key'),
            child: Padding(
              padding: const EdgeInsets.all(40.0), // Padding to prevent clipping of absolute-positioned badges
              child: UserLocationPin(
                imageUrl: '',
                size: 100.0,
                color: color,
                isSosState: isSosState,
                isFriend: false,
                roles: const [],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBadgeTestWidget({
    required Color color,
    required IconData iconData,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: RepaintBoundary(
            key: const ValueKey('export_key'),
            child: Padding(
              padding: const EdgeInsets.all(10.0), // Padding to prevent shadow clipping
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  iconData,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 5 USER STATE PINS ---
  testWidgets('Export Pin Online', (WidgetTester tester) async {
    await tester.pumpWidget(buildPinTestWidget(
      color: const Color(0xFF00E676),
      isSosState: false,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'pin_online.png');
  });

  testWidgets('Export Pin Offline', (WidgetTester tester) async {
    await tester.pumpWidget(buildPinTestWidget(
      color: const Color.fromARGB(255, 0, 0, 0),
      isSosState: false,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'pin_offline.png');
  });

  testWidgets('Export Pin SOS', (WidgetTester tester) async {
    await tester.pumpWidget(buildPinTestWidget(
      color: const Color(0xFFFF1744),
      isSosState: true,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'pin_sos.png');
  });

  testWidgets('Export Pin Me', (WidgetTester tester) async {
    await tester.pumpWidget(buildPinTestWidget(
      color: const Color.fromARGB(255, 17, 123, 3),
      isSosState: false,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'pin_me.png');
  });

  testWidgets('Export Pin Unknown', (WidgetTester tester) async {
    await tester.pumpWidget(buildPinTestWidget(
      color: Colors.grey,
      isSosState: false,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'pin_unknown.png');
  });

  // --- 5 ROLE BADGES ---
  testWidgets('Export Role Friend Icon', (WidgetTester tester) async {
    await tester.pumpWidget(buildBadgeTestWidget(
      color: Colors.blue,
      iconData: Icons.people,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'role_friend.png');
  });

  testWidgets('Export Role Rescuer Icon', (WidgetTester tester) async {
    await tester.pumpWidget(buildBadgeTestWidget(
      color: Colors.orange,
      iconData: Icons.shield,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'role_rescuer.png');
  });

  testWidgets('Export Role Benefactor Icon', (WidgetTester tester) async {
    await tester.pumpWidget(buildBadgeTestWidget(
      color: Colors.blue,
      iconData: Icons.volunteer_activism,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'role_benefactor.png');
  });

  testWidgets('Export Role Authority Icon', (WidgetTester tester) async {
    await tester.pumpWidget(buildBadgeTestWidget(
      color: Colors.indigo,
      iconData: Icons.badge,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'role_authority.png');
  });

  testWidgets('Export Role Admin Icon', (WidgetTester tester) async {
    await tester.pumpWidget(buildBadgeTestWidget(
      color: Colors.black87,
      iconData: Icons.admin_panel_settings,
    ));
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'role_admin.png');
  });

  // --- CAMPAIGN PIN ---
  testWidgets('Export Campaign Pin', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: RepaintBoundary(
              key: ValueKey('export_key'),
              child: Padding(
                padding: EdgeInsets.all(40.0), // Padding to prevent clipping of absolute-positioned badges
                child: CampaignLocationPin(
                  imageUrl: '', // Renders the default campaign fallback icon
                  size: 100.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await exportHighResImage(tester, 'campaign_pin.png');
  });
}
