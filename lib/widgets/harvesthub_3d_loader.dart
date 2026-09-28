import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A continuous, single-shot 3D camera loading animation for HarvestHub.
///
/// Visualizes the complete journey:
/// Seed in Soil -> Sprouting Crops -> Multi-Farm Landscape & Tractor ->
/// Harvest Crates Converging from Multiple Farms -> Central HarvestHub Marketplace ->
/// Customer Package Handover -> Seamless 3D Camera Loop back to Seed in Soil.
class HarvestHub3DLoader extends StatefulWidget {
  final double? width;
  final double? height;

  const HarvestHub3DLoader({
    super.key,
    this.width,
    this.height,
  });

  @override
  State<HarvestHub3DLoader> createState() => _HarvestHub3DLoaderState();
}

class _HarvestHub3DLoaderState extends State<HarvestHub3DLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HarvestWorld3DPainter(t: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Vec3 {
  final double x;
  final double y;
  final double z;

  const _Vec3(this.x, this.y, this.z);

  _Vec3 operator +(_Vec3 o) => _Vec3(x + o.x, y + o.y, z + o.z);
  _Vec3 operator -(_Vec3 o) => _Vec3(x - o.x, y - o.y, z - o.z);
  _Vec3 operator *(double s) => _Vec3(x * s, y * s, z * s);

  double dot(_Vec3 o) => x * o.x + y * o.y + z * o.z;

  _Vec3 cross(_Vec3 o) => _Vec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => math.sqrt(x * x + y * y + z * z);

  _Vec3 get normalized {
    final l = length;
    if (l < 1e-6) return const _Vec3(0, 1, 0);
    return _Vec3(x / l, y / l, z / l);
  }

  static _Vec3 lerp(_Vec3 a, _Vec3 b, double t) {
    return _Vec3(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }
}

class _ProjPt {
  final Offset screen;
  final double depth;
  final double scale;
  final bool visible;

  const _ProjPt({
    required this.screen,
    required this.depth,
    required this.scale,
    required this.visible,
  });
}

class _RenderCommand {
  final double depth;
  final void Function(Canvas canvas) draw;

  const _RenderCommand({required this.depth, required this.draw});
}

class _HarvestWorld3DPainter extends CustomPainter {
  final double t; // [0.0, 1.0) continuous seamless loop parameter

  _HarvestWorld3DPainter({required this.t});

  // Closed periodic Catmull-Rom spline evaluation so t=0.0 and t=1.0 match in position, velocity & curvature
  _Vec3 _evalClosedSpline(List<_Vec3> pts, double u) {
    final int n = pts.length;
    final double scaled = (u % 1.0) * n;
    final int i1 = scaled.floor() % n;
    final int i0 = (i1 - 1 + n) % n;
    final int i2 = (i1 + 1) % n;
    final int i3 = (i1 + 2) % n;
    final double f = scaled - scaled.floor();
    final double f2 = f * f;
    final double f3 = f2 * f;

    final p0 = pts[i0];
    final p1 = pts[i1];
    final p2 = pts[i2];
    final p3 = pts[i3];

    double catmull(double v0, double v1, double v2, double v3) {
      return 0.5 *
          ((2.0 * v1) +
              (-v0 + v2) * f +
              (2.0 * v0 - 5.0 * v1 + 4.0 * v2 - v3) * f2 +
              (-v0 + 3.0 * v1 - 3.0 * v2 + v3) * f3);
    }

    return _Vec3(
      catmull(p0.x, p1.x, p2.x, p3.x),
      catmull(p0.y, p1.y, p2.y, p3.y),
      catmull(p0.z, p1.z, p2.z, p3.z),
    );
  }


  double _smoothRise(double u, double start, double peak, double end) {
    if (u < start || u > end) return 0.0;
    if (u <= peak) {
      final s = ((u - start) / (peak - start)).clamp(0.0, 1.0);
      return s * s * (3 - 2 * s);
    } else {
      final s = ((end - u) / (end - peak)).clamp(0.0, 1.0);
      return s * s * (3 - 2 * s);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Minimal clean background with soft natural studio atmosphere
    final Rect fullRect = Offset.zero & size;
    final Paint bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.44),
        size.longestSide * 0.72,
        const [
          Color(0xFFFBFDFB),
          Color(0xFFF1F7F1),
          Color(0xFFE3EFE4),
        ],
        const [0.0, 0.62, 1.0],
      );
    canvas.drawRect(fullRect, bgPaint);

    // Subtle warm sun-glow in upper studio space
    final Paint sunGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(
          size.width * (0.48 + 0.08 * math.sin(t * math.pi * 2)),
          size.height * (0.30 + 0.04 * math.cos(t * math.pi * 2)),
        ),
        size.shortestSide * 0.65,
        const [
          Color(0x38FFF9E6),
          Color(0x14CDEBC8),
          Color(0x00FFFFFF),
        ],
        const [0.0, 0.55, 1.0],
      );
    canvas.drawRect(fullRect, sunGlowPaint);

    // 2. Define the Continuous 3D Camera Path (Closed Periodic Spline)
    // World coordinates:
    // Zone 0 (0.0, 0.0, 0.0): Seed Furrow & Rich Soil Bed
    // Zone 1 (0.0, 0.0, 11.0): Multi-Farm Terraces (Left Wheat Farm, Center Vegetable Farm, Right Orchard Farm) & Tractor Lane
    // Zone 2 (0.0, 0.2, 23.0): Converging Farm Lanes & Central HarvestHub Marketplace Canopy
    // Zone 3 (0.0, 0.1, 33.0): Customer Handover Pedestal -> Arcing back to Zone 0 (0.0, 0.0, 0.0)
    // Wait: to make the loop 100% geometrically identical at t=0 and t=1, we place the 4 zones around a gentle 3D oval circuit
    // of radius R_x = 9.5, R_z = 11.0 so the camera physically completes a smooth 360-degree continuous gliding shot!
    const double rx = 9.2;
    const double rz = 10.5;

    _Vec3 circuitCenter(double angle) {
      return _Vec3(
        rx * math.sin(angle),
        0.0,
        rz * (1.0 - math.cos(angle)),
      );
    }

    // Camera target (look-at) control points along the 3D agricultural world circuit
    final List<_Vec3> lookAtPts = [
      circuitCenter(0.0 * math.pi) + const _Vec3(0.0, 0.35, 0.0), // t=0.00: Close macro on Seed in Soil
      circuitCenter(0.35 * math.pi) + const _Vec3(0.0, 0.85, 0.0), // t=0.17: Sprouting & Multi-farm fields
      circuitCenter(0.75 * math.pi) + const _Vec3(0.0, 1.05, 0.0), // t=0.38: Tractor & Harvesting into crates
      circuitCenter(1.18 * math.pi) + const _Vec3(0.0, 1.25, 0.0), // t=0.59: Converging at Central HarvestHub Hub
      circuitCenter(1.58 * math.pi) + const _Vec3(0.0, 0.95, 0.0), // t=0.79: Customer package handover
      circuitCenter(1.85 * math.pi) + const _Vec3(0.0, 0.55, 0.0), // t=0.92: Seed drifting back into rich soil
    ];

    final List<_Vec3> camPosPts = [
      circuitCenter(0.0 * math.pi) + const _Vec3(0.0, 3.1, -5.2), // Low close macro view of seed bed
      circuitCenter(0.35 * math.pi) + const _Vec3(-5.8, 5.6, -6.2), // Sweeping wider aerial-isometric over farms
      circuitCenter(0.75 * math.pi) + const _Vec3(-6.4, 5.8, 4.8), // Tracking tractor & harvest crates
      circuitCenter(1.18 * math.pi) + const _Vec3(1.2, 6.0, 8.2), // Framing multiple farm lanes converging into Hub
      circuitCenter(1.58 * math.pi) + const _Vec3(6.8, 4.7, 2.2), // Framing customer delivery package transition
      circuitCenter(1.85 * math.pi) + const _Vec3(4.2, 3.6, -4.4), // Gliding smoothly back to macro seed furrow
    ];

    final _Vec3 camLookAt = _evalClosedSpline(lookAtPts, t);
    final _Vec3 camPos = _evalClosedSpline(camPosPts, t);

    // Camera basis vectors
    final _Vec3 forward = (camLookAt - camPos).normalized;
    final _Vec3 worldUp = const _Vec3(0.0, 1.0, 0.0);
    final _Vec3 right = worldUp.cross(forward).normalized;
    final _Vec3 up = forward.cross(right).normalized;

    final double fovScale = size.shortestSide * 1.12;
    final Offset screenCenter = Offset(size.width * 0.5, size.height * 0.50);

    _ProjPt project(_Vec3 worldPt) {
      final _Vec3 rel = worldPt - camPos;
      final double zCam = rel.dot(forward);
      if (zCam <= 0.4) {
        return const _ProjPt(
          screen: Offset.zero,
          depth: 9999,
          scale: 0,
          visible: false,
        );
      }
      final double xCam = rel.dot(right);
      final double yCam = rel.dot(up);
      final double scale = fovScale / zCam;
      return _ProjPt(
        screen: Offset(
          screenCenter.dx + xCam * scale,
          screenCenter.dy - yCam * scale,
        ),
        depth: zCam,
        scale: scale,
        visible: true,
      );
    }

    final List<_RenderCommand> commands = [];

    // Helper: Draw a stylized 3D shaded sphere/orb (crops, foliage, tomatoes, seeds, particles)
    void addSphere3D(
      _Vec3 center,
      double radius,
      Color highlightColor,
      Color midColor,
      Color shadowColor, {
      double opacity = 1.0,
      bool castShadow = true,
    }) {
      if (opacity <= 0.01 || radius <= 0.002) return;
      final p = project(center);
      if (!p.visible) return;
      final double rPx = (radius * p.scale).clamp(0.5, 240.0);

      // Subtle Depth of Field attenuation
      final double focalDist = (camLookAt - camPos).length;
      final double dofBlur = ((p.depth - focalDist).abs() - 5.5).clamp(0.0, 8.0) * 0.45;
      final double dofAlpha = (opacity * (1.0 - ((p.depth - focalDist).abs() / 22.0).clamp(0.0, 0.55))).clamp(0.0, 1.0);

      if (castShadow && center.y > 0.02) {
        final shadowPt = project(_Vec3(center.x, 0.01, center.z));
        if (shadowPt.visible) {
          commands.add(
            _RenderCommand(
              depth: shadowPt.depth + 0.15,
              draw: (c) {
                final double sr = rPx * 0.95;
                c.drawOval(
                  Rect.fromCenter(
                    center: shadowPt.screen,
                    width: sr * 2.1,
                    height: sr * 0.95,
                  ),
                  Paint()
                    ..color = const Color(0xFF1A2E1B).withValues(alpha: 0.16 * dofAlpha)
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0),
                );
              },
            ),
          );
        }
      }

      commands.add(
        _RenderCommand(
          depth: p.depth,
          draw: (c) {
            final Paint paint = Paint()
              ..shader = ui.Gradient.radial(
                p.screen + Offset(-rPx * 0.32, -rPx * 0.35),
                rPx * 1.35,
                [
                  highlightColor.withValues(alpha: dofAlpha),
                  midColor.withValues(alpha: dofAlpha),
                  shadowColor.withValues(alpha: dofAlpha),
                ],
                const [0.0, 0.58, 1.0],
              );
            if (dofBlur > 0.4) {
              paint.maskFilter = MaskFilter.blur(BlurStyle.normal, dofBlur);
            }
            c.drawCircle(p.screen, rPx, paint);
          },
        ),
      );
    }

    // Helper: Draw a 3D extruded rounded block / prism (soil beds, farm plots, crates, tractor body, hub canopy, package)
    void addPrism3D({
      required _Vec3 center,
      required double widthX,
      required double heightY,
      required double depthZ,
      required double yaw,
      required Color topColor,
      required Color leftColor,
      required Color rightColor,
      double opacity = 1.0,
      bool castShadow = true,
    }) {
      if (opacity <= 0.01) return;
      final pCenter = project(center);
      if (!pCenter.visible) return;

      final double focalDist = (camLookAt - camPos).length;
      final double dofAlpha = (opacity * (1.0 - ((pCenter.depth - focalDist).abs() / 24.0).clamp(0.0, 0.55))).clamp(0.0, 1.0);
      if (dofAlpha <= 0.01) return;

      final double cosY = math.cos(yaw);
      final double sinY = math.sin(yaw);

      _Vec3 localToWorld(double lx, double ly, double lz) {
        return _Vec3(
          center.x + lx * cosY - lz * sinY,
          center.y + ly,
          center.z + lx * sinY + lz * cosY,
        );
      }

      final double hx = widthX * 0.5;
      final double hy = heightY * 0.5;
      final double hz = depthZ * 0.5;

      // 8 corners of the box
      final List<_ProjPt> corners = [
        project(localToWorld(-hx, -hy, -hz)), // 0: bottom-left-back
        project(localToWorld(hx, -hy, -hz)),  // 1: bottom-right-back
        project(localToWorld(hx, -hy, hz)),   // 2: bottom-right-front
        project(localToWorld(-hx, -hy, hz)),  // 3: bottom-left-front
        project(localToWorld(-hx, hy, -hz)),  // 4: top-left-back
        project(localToWorld(hx, hy, -hz)),   // 5: top-right-back
        project(localToWorld(hx, hy, hz)),    // 6: top-right-front
        project(localToWorld(-hx, hy, hz)),   // 7: top-left-front
      ];

      if (corners.any((pt) => !pt.visible)) return;

      if (castShadow) {
        final shadowCenter = project(_Vec3(center.x, 0.0, center.z));
        if (shadowCenter.visible) {
          commands.add(
            _RenderCommand(
              depth: shadowCenter.depth + 0.25,
              draw: (c) {
                final double rxPx = math.max(widthX, depthZ) * shadowCenter.scale * 0.68;
                c.drawOval(
                  Rect.fromCenter(
                    center: shadowCenter.screen,
                    width: rxPx * 2.1,
                    height: rxPx * 1.05,
                  ),
                  Paint()
                    ..color = const Color(0xFF1A2F1C).withValues(alpha: 0.18 * dofAlpha)
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
                );
              },
            ),
          );
        }
      }

      void drawQuad(int a, int b, int cIdx, int d, Color col) {
        final pa = corners[a].screen;
        final pb = corners[b].screen;
        final pc = corners[cIdx].screen;
        final pd = corners[d].screen;
        // Backface culling via 2D cross product
        final double cross2D = (pb.dx - pa.dx) * (pc.dy - pa.dy) - (pb.dy - pa.dy) * (pc.dx - pa.dx);
        if (cross2D > 0) return;

        final double faceDepth = (corners[a].depth + corners[b].depth + corners[cIdx].depth + corners[d].depth) * 0.25;
        commands.add(
          _RenderCommand(
            depth: faceDepth,
            draw: (canvas) {
              final path = Path()
                ..moveTo(pa.dx, pa.dy)
                ..lineTo(pb.dx, pb.dy)
                ..lineTo(pc.dx, pc.dy)
                ..lineTo(pd.dx, pd.dy)
                ..close();
              canvas.drawPath(
                path,
                Paint()
                  ..color = col.withValues(alpha: dofAlpha)
                  ..style = PaintingStyle.fill,
              );
              canvas.drawPath(
                path,
                Paint()
                  ..color = col.withValues(alpha: dofAlpha * 0.5)
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 0.7
                  ..strokeJoin = StrokeJoin.round,
              );
            },
          ),
        );
      }

      // 4 Side faces + Top face
      drawQuad(3, 2, 6, 7, rightColor); // Front (+Z)
      drawQuad(1, 0, 4, 5, leftColor);  // Back (-Z)
      drawQuad(0, 3, 7, 4, leftColor);  // Left (-X)
      drawQuad(2, 1, 5, 6, rightColor); // Right (+X)
      drawQuad(4, 7, 6, 5, topColor);   // Top (+Y)
    }

    // -------------------------------------------------------------------------
    // 3. BUILD THE CONTINUOUS LIVING 3D AGRICULTURAL WORLD
    // -------------------------------------------------------------------------

    // A. Continuous 3D Terrain Ribbon & Soil/Meadow Islands along the closed loop
    const int terrainSegments = 64;
    for (int i = 0; i < terrainSegments; i++) {
      final double u = i / terrainSegments;
      final double angle = u * math.pi * 2.0;
      final _Vec3 pt = circuitCenter(angle);
      final double tangentAngle = math.atan2(
        rx * math.cos(angle),
        rz * math.sin(angle),
      );

      // Rich earthy soil base + lush meadow border along the entire continuous path
      final bool isSoilZone = (u < 0.16 || u > 0.88);
      final Color topTurf = isSoilZone
          ? Color.lerp(const Color(0xFF7A5236), const Color(0xFF6B8F4E), (u < 0.16 ? u / 0.16 : (1.0 - u) / 0.12).clamp(0.0, 1.0))!
          : const Color(0xFF78B85C);
      final Color sideEarthL = const Color(0xFF5D3E28);
      final Color sideEarthR = const Color(0xFF4B301E);

      addPrism3D(
        center: pt + const _Vec3(0, -0.22, 0),
        widthX: 4.8,
        heightY: 0.42,
        depthZ: 1.45,
        yaw: -tangentAngle,
        topColor: topTurf,
        leftColor: sideEarthL,
        rightColor: sideEarthR,
        castShadow: i % 2 == 0,
      );
    }

    // B. ZONE 0 (angle = 0.0): Rich Agricultural Soil Furrows, Seed & Sprouting Crop Growth
    final _Vec3 seedZoneCenter = circuitCenter(0.0);
    // Raised rich soil furrows
    for (int row = -2; row <= 2; row++) {
      addPrism3D(
        center: seedZoneCenter + _Vec3(row * 0.72, 0.08, 0.0),
        widthX: 0.52,
        heightY: 0.18,
        depthZ: 3.6,
        yaw: 0.0,
        topColor: const Color(0xFF6E472D),
        leftColor: const Color(0xFF583822),
        rightColor: const Color(0xFF472C1A),
        castShadow: false,
      );
    }

    // Seed settling & sprouting continuously (seamless across t=0.90 -> 1.00 -> 0.00 -> 0.30)
    // Growth progress g in [0..1]
    double sproutGrowth;
    if (t < 0.32) {
      sproutGrowth = (t / 0.24).clamp(0.0, 1.0);
    } else if (t > 0.86) {
      sproutGrowth = 0.0;
    } else {
      sproutGrowth = (1.0 - ((t - 0.32) / 0.45)).clamp(0.0, 1.0);
    }
    sproutGrowth = sproutGrowth * sproutGrowth * (3 - 2 * sproutGrowth);

    // Falling/settling golden seed at t in [0.88 .. 1.00] and [0.00 .. 0.08]
    double seedDropProg = 0.0;
    bool showSeed = false;
    if (t >= 0.88) {
      showSeed = true;
      seedDropProg = ((t - 0.88) / 0.12).clamp(0.0, 1.0);
    } else if (t <= 0.08) {
      showSeed = true;
      seedDropProg = 1.0;
    }
    if (showSeed) {
      final double seedY = ui.lerpDouble(2.2, 0.24, Curves.easeOutCubic.transform(seedDropProg))!;
      final double seedScale = t <= 0.08 ? (1.0 - t / 0.08) : 1.0;
      addSphere3D(
        seedZoneCenter + _Vec3(0.0, seedY, 0.0),
        0.22 * (0.6 + 0.4 * seedScale),
        const Color(0xFFFFF3B0),
        const Color(0xFFE5A93B),
        const Color(0xFF9C6615),
      );
    }

    // Growing seedlings & healthy crop rows in Zone 0 -> Zone 1
    if (sproutGrowth > 0.01) {
      for (int r = -1; r <= 1; r++) {
        for (int c = -2; c <= 2; c++) {
          final double delay = (r.abs() * 0.12 + (c + 2) * 0.08);
          final double localG = ((sproutGrowth * 1.35) - delay).clamp(0.0, 1.0);
          if (localG <= 0.01) continue;

          final _Vec3 base = seedZoneCenter + _Vec3(r * 0.72, 0.18, c * 0.65);
          final double stemH = 0.95 * localG;
          // Stem
          addPrism3D(
            center: base + _Vec3(0, stemH * 0.5, 0),
            widthX: 0.10 * localG,
            heightY: stemH,
            depthZ: 0.10 * localG,
            yaw: 0.2 * c,
            topColor: const Color(0xFF7BD45A),
            leftColor: const Color(0xFF4CA634),
            rightColor: const Color(0xFF398524),
            castShadow: false,
          );
          // Lush 3D foliage crown
          addSphere3D(
            base + _Vec3(0, stemH + 0.16 * localG, 0),
            0.28 * localG,
            const Color(0xFFA8F07A),
            const Color(0xFF52B83C),
            const Color(0xFF28751B),
          );
          addSphere3D(
            base + _Vec3(-0.14 * localG, stemH * 0.78, 0.08 * localG),
            0.19 * localG,
            const Color(0xFFB5F58C),
            const Color(0xFF62C449),
            const Color(0xFF2F8220),
            castShadow: false,
          );
          addSphere3D(
            base + _Vec3(0.14 * localG, stemH * 0.82, -0.08 * localG),
            0.18 * localG,
            const Color(0xFFB5F58C),
            const Color(0xFF62C449),
            const Color(0xFF2F8220),
            castShadow: false,
          );
        }
      }
    }

    // C. MULTIPLE FARMS / GROWING AREAS (Zone 1: angle = 0.25*pi .. 0.90*pi)
    // Visually communicates that MULTIPLE local farmers cultivate distinct crops around the landscape!
    final List<Map<String, dynamic>> multiFarms = [
      {
        // Farm 1 (Outer Left Terrace): Golden Wheat & Grain Farm + Red Barn
        'center': circuitCenter(0.38 * math.pi) + const _Vec3(-4.2, 0.15, -1.2),
        'yaw': 0.35,
        'soilColor': const Color(0xFF8C6B3F),
        'cropHi': const Color(0xFFFFF099),
        'cropMid': const Color(0xFFE6B832),
        'cropLo': const Color(0xFFA87B14),
        'barnColor': const Color(0xFFC84B31),
      },
      {
        // Farm 2 (Inner Right Terrace): Fresh Tomato & Leafy Greens Farm + Green Farmhouse
        'center': circuitCenter(0.55 * math.pi) + const _Vec3(4.0, 0.20, 0.8),
        'yaw': -0.45,
        'soilColor': const Color(0xFF63442B),
        'cropHi': const Color(0xFFFF8A75),
        'cropMid': const Color(0xFFE03E26),
        'cropLo': const Color(0xFF941B0C),
        'barnColor': const Color(0xFF3B873E),
      },
      {
        // Farm 3 (Outer Upper Terrace): Orchard & Golden Root Farm + Warm Timber Shed
        'center': circuitCenter(0.82 * math.pi) + const _Vec3(-4.3, 0.18, 2.2),
        'yaw': 0.85,
        'soilColor': const Color(0xFF6E4E32),
        'cropHi': const Color(0xFFFFB86B),
        'cropMid': const Color(0xFFE87A24),
        'cropLo': const Color(0xFF9E4709),
        'barnColor': const Color(0xFFD98A3C),
      },
    ];

    for (final farm in multiFarms) {
      final _Vec3 fc = farm['center'] as _Vec3;
      final double fyaw = farm['yaw'] as double;
      final Color barnCol = farm['barnColor'] as Color;

      // Terraced farm island base
      addPrism3D(
        center: fc + const _Vec3(0, -0.15, 0),
        widthX: 3.6,
        heightY: 0.38,
        depthZ: 3.2,
        yaw: fyaw,
        topColor: const Color(0xFF82C264),
        leftColor: const Color(0xFF61422B),
        rightColor: const Color(0xFF4D321E),
      );

      // Miniature Farm Barn / Homestead on each farm plot
      addPrism3D(
        center: fc + const _Vec3(-0.9, 0.42, -0.7),
        widthX: 1.05,
        heightY: 0.76,
        depthZ: 0.95,
        yaw: fyaw,
        topColor: barnCol,
        leftColor: Color.lerp(barnCol, Colors.black, 0.18)!,
        rightColor: Color.lerp(barnCol, Colors.black, 0.34)!,
      );
      // Barn Roof Crest
      addPrism3D(
        center: fc + const _Vec3(-0.9, 0.88, -0.7),
        widthX: 1.18,
        heightY: 0.22,
        depthZ: 1.08,
        yaw: fyaw,
        topColor: const Color(0xFFF4F1EA),
        leftColor: const Color(0xFFD6CFC2),
        rightColor: const Color(0xFFB8B0A0),
        castShadow: false,
      );

      // Crop rows on this farmer's plot
      final double wave = math.sin(t * math.pi * 4 + fyaw) * 0.05;
      for (int r = 0; r < 3; r++) {
        for (int c = -1; c <= 1; c++) {
          final _Vec3 cropPos = fc + _Vec3(0.35 + r * 0.55, 0.22 + wave, c * 0.65);
          addSphere3D(
            cropPos,
            0.25,
            farm['cropHi'] as Color,
            farm['cropMid'] as Color,
            farm['cropLo'] as Color,
          );
          addSphere3D(
            cropPos + const _Vec3(0, -0.08, 0),
            0.27,
            const Color(0xFF9EE874),
            const Color(0xFF4DB335),
            const Color(0xFF287318),
            castShadow: false,
          );
        }
      }
    }

    // D. MODERN 3D TRACTOR DRIVING CONTINUOUSLY THROUGH THE FIELD
    // Moves smoothly along the farming & harvesting stretch (angle 0.20*pi -> 0.95*pi)
    final double tractorCycle = (t * 1.0) % 1.0;
    final double tractorAngle = ui.lerpDouble(0.18 * math.pi, 0.98 * math.pi, tractorCycle)!;
    final double tractorAlpha = _smoothRise(t, 0.06, 0.38, 0.72);
    if (tractorAlpha > 0.02) {
      final _Vec3 tPos = circuitCenter(tractorAngle) + const _Vec3(0.0, 0.12, 0.0);
      final double tYaw = -math.atan2(
        rx * math.cos(tractorAngle),
        rz * math.sin(tractorAngle),
      );

      // Tractor chassis (HarvestHub signature green)
      addPrism3D(
        center: tPos + const _Vec3(0, 0.34, 0),
        widthX: 0.92,
        heightY: 0.42,
        depthZ: 1.45,
        yaw: tYaw,
        topColor: const Color(0xFF47B84F),
        leftColor: const Color(0xFF33963B),
        rightColor: const Color(0xFF237329),
        opacity: tractorAlpha,
      );
      // Tractor Glass Cabin
      addPrism3D(
        center: tPos + const _Vec3(0, 0.72, -0.18),
        widthX: 0.76,
        heightY: 0.44,
        depthZ: 0.78,
        yaw: tYaw,
        topColor: const Color(0xFFEAF7EC),
        leftColor: const Color(0xFFA8D8B9),
        rightColor: const Color(0xFF7AB892),
        opacity: tractorAlpha,
        castShadow: false,
      );
      // Cabin Roof
      addPrism3D(
        center: tPos + const _Vec3(0, 0.98, -0.18),
        widthX: 0.84,
        heightY: 0.10,
        depthZ: 0.86,
        yaw: tYaw,
        topColor: const Color(0xFF389E41),
        leftColor: const Color(0xFF287D2F),
        rightColor: const Color(0xFF1E6124),
        opacity: tractorAlpha,
        castShadow: false,
      );
      // 4 Stylized 3D Tractor Wheels with golden-yellow hubs
      final double cosT = math.cos(tYaw);
      final double sinT = math.sin(tYaw);
      for (final wx in [-0.54, 0.54]) {
        for (final wz in [-0.45, 0.48]) {
          final _Vec3 wWorld = _Vec3(
            tPos.x + wx * cosT - wz * sinT,
            tPos.y + (wz < 0 ? 0.28 : 0.22),
            tPos.z + wx * sinT + wz * cosT,
          );
          addSphere3D(
            wWorld,
            wz < 0 ? 0.29 : 0.22,
            const Color(0xFF4A524C),
            const Color(0xFF282E2A),
            const Color(0xFF141715),
            opacity: tractorAlpha,
            castShadow: false,
          );
          addSphere3D(
            wWorld + _Vec3(wx.sign * 0.08 * cosT, 0, wx.sign * 0.08 * sinT),
            wz < 0 ? 0.14 : 0.10,
            const Color(0xFFFFEA75),
            const Color(0xFFE6B822),
            const Color(0xFFA37C0A),
            opacity: tractorAlpha,
            castShadow: false,
          );
        }
      }
    }

    // E. HARVESTED CRATES CONVERGING FROM MULTIPLE FARMS -> CENTRAL HARVESTHUB MARKETPLACE
    // Three distinct crate streams originate from Farm 1, Farm 2, and Farm 3 and converge into the Central Hub at angle = 1.22 * pi!
    final _Vec3 hubCenter = circuitCenter(1.22 * math.pi) + const _Vec3(0.0, 0.18, 0.0);

    for (int fIdx = 0; fIdx < multiFarms.length; fIdx++) {
      final _Vec3 farmStart = (multiFarms[fIdx]['center'] as _Vec3) + const _Vec3(0, 0.32, 0);
      final Color produceHi = multiFarms[fIdx]['cropHi'] as Color;
      final Color produceMid = multiFarms[fIdx]['cropMid'] as Color;
      final Color produceLo = multiFarms[fIdx]['cropLo'] as Color;

      // 2 crates per farm stream flowing continuously toward the central hub
      for (int k = 0; k < 2; k++) {
        final double flowT = ((t * 1.4 + fIdx * 0.27 + k * 0.48) % 1.0);
        final double crateAlpha = _smoothRise(flowT, 0.0, 0.5, 1.0);
        if (crateAlpha <= 0.02) continue;

        // Parabolic arc from each farmer's plot into the central HarvestHub marketplace
        final _Vec3 cratePos = _Vec3.lerp(farmStart, hubCenter + const _Vec3(0, 0.25, 0), flowT) +
            _Vec3(0, math.sin(flowT * math.pi) * 0.85, 0);

        // Wooden agricultural crate
        addPrism3D(
          center: cratePos,
          widthX: 0.62,
          heightY: 0.34,
          depthZ: 0.48,
          yaw: flowT * math.pi,
          topColor: const Color(0xFFE5B578),
          leftColor: const Color(0xFFC48E4F),
          rightColor: const Color(0xFF9E6D34),
          opacity: crateAlpha,
        );
        // Fresh produce inside crate
        addSphere3D(
          cratePos + const _Vec3(-0.12, 0.22, 0),
          0.16,
          produceHi,
          produceMid,
          produceLo,
          opacity: crateAlpha,
          castShadow: false,
        );
        addSphere3D(
          cratePos + const _Vec3(0.12, 0.22, 0.05),
          0.15,
          const Color(0xFFA8F07A),
          const Color(0xFF4EB839),
          const Color(0xFF287519),
          opacity: crateAlpha,
          castShadow: false,
        );
      }
    }

    // F. CENTRAL HARVESTHUB MARKETPLACE PAVILION (angle = 1.22 * pi)
    // Architectural modern timber-and-emerald pavilion where all farmers' produce converges
    // Platform base
    addPrism3D(
      center: hubCenter + const _Vec3(0, -0.04, 0),
      widthX: 4.2,
      heightY: 0.28,
      depthZ: 3.8,
      yaw: 0.25,
      topColor: const Color(0xFFF3EFE6),
      leftColor: const Color(0xFFD6CEC0),
      rightColor: const Color(0xFFB8B0A0),
    );
    // 4 Timber Pillars
    for (final px in [-1.35, 1.35]) {
      for (final pz in [-1.15, 1.15]) {
        addPrism3D(
          center: hubCenter + _Vec3(px, 0.72, pz),
          widthX: 0.22,
          heightY: 1.28,
          depthZ: 0.22,
          yaw: 0.25,
          topColor: const Color(0xFFD99B56),
          leftColor: const Color(0xFFB87B38),
          rightColor: const Color(0xFF8F5B22),
          castShadow: false,
        );
      }
    }
    // Modern Emerald Marketplace Canopy Roof
    addPrism3D(
      center: hubCenter + const _Vec3(0, 1.48, 0),
      widthX: 3.45,
      heightY: 0.32,
      depthZ: 3.15,
      yaw: 0.25,
      topColor: const Color(0xFF38A844),
      leftColor: const Color(0xFF2B8735),
      rightColor: const Color(0xFF1E6626),
    );
    // Upper Skylight Crown with subtle HarvestHub organic leaf emblem
    addPrism3D(
      center: hubCenter + const _Vec3(0, 1.76, 0),
      widthX: 1.85,
      heightY: 0.24,
      depthZ: 1.65,
      yaw: 0.25,
      topColor: const Color(0xFFF9FBF9),
      leftColor: const Color(0xFFDCEEE0),
      rightColor: const Color(0xFFBDD9C3),
      castShadow: false,
    );
    // Subtle organic leaf emblem on top of the central hub crown (not a logo reveal)
    addSphere3D(
      hubCenter + const _Vec3(0, 2.02, 0),
      0.26,
      const Color(0xFFB5F78D),
      const Color(0xFF43B251),
      const Color(0xFF1F6E29),
      castShadow: false,
    );

    // G. MARKETPLACE -> CLEAN CUSTOMER HANDOVER PACKAGE -> SEAMLESS LOOP TO SEED
    // Between angle 1.22*pi (Hub) -> 1.62*pi (Customer Terrace) -> 2.00*pi (Seed Bed)
    final _Vec3 customerTerrace = circuitCenter(1.62 * math.pi) + const _Vec3(0, 0.18, 0);

    // Customer pickup / delivery terrace pad
    addPrism3D(
      center: customerTerrace,
      widthX: 2.8,
      heightY: 0.24,
      depthZ: 2.6,
      yaw: -0.4,
      topColor: const Color(0xFFEAF4EC),
      leftColor: const Color(0xFFC8DEC9),
      rightColor: const Color(0xFFA9C4AB),
    );

    // Clean 3D Customer Package gliding out of Central Hub to Customer Terrace
    final double pkgProgress = ((t - 0.56) / 0.34).clamp(0.0, 1.0);
    final double pkgAlpha = _smoothRise(t, 0.52, 0.74, 0.92);
    if (pkgAlpha > 0.02) {
      final double smoothPkg = Curves.easeInOutCubic.transform(pkgProgress);
      final _Vec3 pkgPos = _Vec3.lerp(
            hubCenter + const _Vec3(0, 0.52, 0),
            customerTerrace + const _Vec3(0, 0.52, 0),
            smoothPkg,
          ) +
          _Vec3(0, math.sin(smoothPkg * math.pi) * 0.55, 0);

      // Clean warm kraft 3D customer box
      addPrism3D(
        center: pkgPos,
        widthX: 0.88,
        heightY: 0.68,
        depthZ: 0.82,
        yaw: -0.4 + smoothPkg * 0.8,
        topColor: const Color(0xFFF5DFC0),
        leftColor: const Color(0xFFD9B88C),
        rightColor: const Color(0xFFB89465),
        opacity: pkgAlpha,
      );
      // Fresh emerald HarvestHub seal band across package top
      addPrism3D(
        center: pkgPos + const _Vec3(0, 0.35, 0),
        widthX: 0.90,
        heightY: 0.06,
        depthZ: 0.26,
        yaw: -0.4 + smoothPkg * 0.8,
        topColor: const Color(0xFF43B251),
        leftColor: const Color(0xFF328F3E),
        rightColor: const Color(0xFF246B2D),
        opacity: pkgAlpha,
        castShadow: false,
      );
      // Glowing fresh sprout/seed token rising from customer package and arcing back into Zone 0 soil!
      if (t > 0.76) {
        final double arcToSeed = ((t - 0.76) / 0.24).clamp(0.0, 1.0);
        final _Vec3 arcPos = _Vec3.lerp(
              pkgPos + const _Vec3(0, 0.45, 0),
              seedZoneCenter + const _Vec3(0, 0.35, 0),
              Curves.easeInOutSine.transform(arcToSeed),
            ) +
            _Vec3(0, math.sin(arcToSeed * math.pi) * 1.65, 0);
        addSphere3D(
          arcPos,
          0.20,
          const Color(0xFFFFF6B8),
          const Color(0xFF7AD956),
          const Color(0xFF348C2B),
        );
      }
    }

    // -------------------------------------------------------------------------
    // 4. PAINTER'S ALGORITHM Z-SORT & EXECUTE 3D RENDER QUEUE
    // -------------------------------------------------------------------------
    commands.sort((a, b) => b.depth.compareTo(a.depth));
    for (final cmd in commands) {
      cmd.draw(canvas);
    }

    // 5. Subtle vignette & minimal bottom progress pulse (no random UI elements or text clutter)
    final double barWidth = size.width * 0.22;
    final double barLeft = (size.width - barWidth) * 0.5;
    final double barTop = size.height - 36.0;
    final RRect trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft, barTop, barWidth, 3.5),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      trackRRect,
      Paint()..color = const Color(0xFF2D6A35).withValues(alpha: 0.12),
    );
    final double pulsePos = (math.sin(t * math.pi * 2 - math.pi / 2) + 1.0) * 0.5;
    final RRect fillRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(barLeft + barWidth * 0.15 * pulsePos, barTop, barWidth * 0.70, 3.5),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      fillRRect,
      Paint()..color = const Color(0xFF43B251).withValues(alpha: 0.65),
    );
  }

  @override
  bool shouldRepaint(covariant _HarvestWorld3DPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
