/// Script Dart standalone per generare l'icona app 1024x1024
/// Usa solo dart:io e dart:math — zero dipendenze esterne
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

void main() {
  const int W = 1024;
  const int H = 1024;

  // Buffer RGBA
  final pixels = Uint8List(W * H * 4);

  // ── Funzioni helper ────────────────────────────────────────────
  void setPixel(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= W || y < 0 || y >= H) return;
    final i = (y * W + x) * 4;
    pixels[i]     = r;
    pixels[i + 1] = g;
    pixels[i + 2] = b;
    pixels[i + 3] = a;
  }

  int lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

  // ── Sfondo: gradiente radiale scuro ───────────────────────────
  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      final dx = (x - W / 2) / (W / 2);
      final dy = (y - H / 2) / (H / 2);
      final dist = math.sqrt(dx * dx + dy * dy).clamp(0.0, 1.0);

      // Da centro (#141420) a bordo (#050508)
      final r = lerp(0x14, 0x05, dist);
      final g = lerp(0x14, 0x05, dist);
      final b = lerp(0x20, 0x08, dist);
      setPixel(x, y, r, g, b, 255);
    }
  }

  // ── Cerchio principale con colore rosso Marathon ───────────────
  const cx = W ~/ 2;
  const cy = H ~/ 2;
  const radius = 300.0;
  const innerR = 270.0;

  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      final dx = x - cx.toDouble();
      final dy = y - cy.toDouble();
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist <= radius) {
        // Gradiente radiale dentro il cerchio
        final t = (dist / radius).clamp(0.0, 1.0);
        // Rosso ossidato Marathon: #E85235 → #A02010
        final r = lerp(0xE8, 0xA0, t);
        final g = lerp(0x52, 0x20, t);
        final b = lerp(0x35, 0x10, t);

        // Glow sfumato
        final glowAlpha = dist > innerR
            ? (1.0 - (dist - innerR) / (radius - innerR))
            : 1.0;
        final idx = (y * W + x) * 4;
        final bgR = pixels[idx];
        final bgG = pixels[idx + 1];
        final bgB = pixels[idx + 2];

        pixels[idx]     = lerp(bgR, r, glowAlpha);
        pixels[idx + 1] = lerp(bgG, g, glowAlpha);
        pixels[idx + 2] = lerp(bgB, b, glowAlpha);
      }
    }
  }

  // ── Simbolo € (disegnato come pixel art 200x200 centrato) ─────
  // Usa Bresenham per linee e archi
  void drawLine(int x0, int y0, int x1, int y1, int r, int g, int b, int thick) {
    final steps = math.max((x1 - x0).abs(), (y1 - y0).abs());
    if (steps == 0) {
      for (int dy = -thick; dy <= thick; dy++) {
        for (int dx = -thick; dx <= thick; dx++) {
          setPixel(x0 + dx, y0 + dy, r, g, b, 255);
        }
      }
      return;
    }
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final px = (x0 + (x1 - x0) * t).round();
      final py = (y0 + (y1 - y0) * t).round();
      for (int dy = -thick; dy <= thick; dy++) {
        for (int dx = -thick; dx <= thick; dx++) {
          setPixel(px + dx, py + dy, r, g, b, 255);
        }
      }
    }
  }

  void drawArc(int cx, int cy, int rad, double startAngle, double endAngle,
      int r, int g, int b, int thick) {
    final steps = (rad * (endAngle - startAngle)).abs().round().clamp(60, 500);
    for (int i = 0; i <= steps; i++) {
      final angle = startAngle + (endAngle - startAngle) * i / steps;
      final px = (cx + rad * math.cos(angle)).round();
      final py = (cy + rad * math.sin(angle)).round();
      for (int dy = -thick; dy <= thick; dy++) {
        for (int dx = -thick; dx <= thick; dx++) {
          setPixel(px + dx, py + dy, r, g, b, 255);
        }
      }
    }
  }

  // Simbolo € bianco, centrato
  const eR = 255, eG = 255, eB = 255;
  const T = 22; // spessore linee
  const eCx = cx - 20;
  const eCy = cy;
  const eRad = 140;

  // Arco principale della C
  drawArc(eCx, eCy, eRad, math.pi * 0.35, math.pi * 1.65, eR, eG, eB, T);

  // Due linee orizzontali (le sbarre della €)
  drawLine(eCx - eRad - 30, eCy - 40, eCx + 40, eCy - 40, eR, eG, eB, T - 4);
  drawLine(eCx - eRad - 30, eCy + 40, eCx + 40, eCy + 40, eR, eG, eB, T - 4);

  // ── Piccole barre grafico in basso al cerchio ──────────────────
  final barData = [
    (cx - 130, 90, 0x00, 0xD5, 0xBB), // ciano
    (cx - 50,  120, 0xFF, 0xFF, 0xFF), // bianco
    (cx + 30,  70,  0x00, 0xD5, 0xBB), // ciano
    (cx + 110, 100, 0xFF, 0xFF, 0xFF), // bianco
  ];

  const barBottom = cy + 240;
  const barWidth = 50;
  for (final bar in barData) {
    final bx = bar.$1;
    final bh = bar.$2;
    final br2 = bar.$3;
    final bg2 = bar.$4;
    final bb2 = bar.$5;
    for (int y = barBottom - bh; y <= barBottom; y++) {
      for (int x = bx; x < bx + barWidth; x++) {
        final dx = x - cx.toDouble();
        final dy = y - cy.toDouble();
        if (math.sqrt(dx * dx + dy * dy) <= radius + 20) {
          setPixel(x, y, br2, bg2, bb2, 180);
        }
      }
    }
  }

  // ── Bordo luminoso cerchio ─────────────────────────────────────
  for (int y = 0; y < H; y++) {
    for (int x = 0; x < W; x++) {
      final dx = x - cx.toDouble();
      final dy = y - cy.toDouble();
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist >= radius - 3 && dist <= radius + 3) {
        final alpha = 1.0 - ((dist - radius).abs() / 3.0);
        final idx = (y * W + x) * 4;
        pixels[idx]     = lerp(pixels[idx],     0xFF, alpha * 0.3);
        pixels[idx + 1] = lerp(pixels[idx + 1], 0x80, alpha * 0.3);
        pixels[idx + 2] = lerp(pixels[idx + 2], 0x60, alpha * 0.3);
      }
    }
  }

  // ── Scrivi PNG con header minimale ────────────────────────────
  writePng(pixels, W, H, '/Users/tommaso/StudioProjects/finance_prj/assets/app_icon.png');
  print('Icona generata: assets/app_icon.png');
}

// ── PNG Writer minimale (RGBA non-compressed Deflate) ─────────────
void writePng(Uint8List rgba, int w, int h, String path) {
  final out = BytesBuilder();

  // PNG signature
  out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR
  final ihdr = BytesBuilder();
  ihdr.add(_int32(w));
  ihdr.add(_int32(h));
  ihdr.addByte(8); // bit depth
  ihdr.addByte(2); // color type RGB (no alpha per iOS)
  ihdr.addByte(0); // compression
  ihdr.addByte(0); // filter
  ihdr.addByte(0); // interlace
  _writeChunk(out, 'IHDR', ihdr.toBytes());

  // IDAT - raw image data con filtro None (0) per ogni scanline
  final rawLines = BytesBuilder();
  for (int y = 0; y < h; y++) {
    rawLines.addByte(0); // filter type None
    for (int x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      rawLines.addByte(rgba[i]);
      rawLines.addByte(rgba[i + 1]);
      rawLines.addByte(rgba[i + 2]);
      // Skip alpha (RGB only per iOS)
    }
  }

  // Compress con zlib (usa dart:io ZLibEncoder)
  final compressed = ZLibEncoder().convert(rawLines.toBytes());
  _writeChunk(out, 'IDAT', compressed);

  // IEND
  _writeChunk(out, 'IEND', Uint8List(0));

  File(path).writeAsBytesSync(out.toBytes());
}

List<int> _int32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];

void _writeChunk(BytesBuilder out, String type, List<int> data) {
  out.add(_int32(data.length));
  final typeBytes = type.codeUnits;
  out.add(typeBytes);
  out.add(data);
  // CRC32
  final crcData = [...typeBytes, ...data];
  out.add(_int32(_crc32(crcData)));
}

int _crc32(List<int> data) {
  int crc = 0xFFFFFFFF;
  for (final b in data) {
    crc ^= b;
    for (int i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}

