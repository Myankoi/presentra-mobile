import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'guru_provider.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> with TickerProviderStateMixin {
  bool _hasPermission = false;
  bool _isFlashOn = false;
  bool _isProcessing = false;
  MobileScannerController? _scannerController;

  _ScanResult? _result;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
    );
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() => _hasPermission = status.isGranted);
    if (!_hasPermission) _showPermissionDialog();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: Text('Izin Kamera', style: AppTheme.titleMedium(context)),
        content: Text('Aplikasi memerlukan akses kamera untuk memindai QR Code.', style: AppTheme.bodyMedium(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async { Navigator.pop(ctx); await openAppSettings(); },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _scannerController?.stop();

    final result = await context.read<GuruProvider>().scanAbsen(qrData);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() { _result = _ScanResult.success; _isProcessing = false; });
    } else {
      final msg = result['message'] as String? ?? 'QR Code tidak valid';
      if (msg.toLowerCase().contains('jadwal') || msg.toLowerCase().contains('scheduled')) {
        setState(() { _result = _ScanResult.notScheduled; _isProcessing = false; });
      } else {
        setState(() { _result = _ScanResult.error; _isProcessing = false; });
      }
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing || _result != null) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) { _processQRCode(barcode.rawValue!); break; }
    }
  }

  void _resetScan() {
    setState(() { _result = null; _isProcessing = false; });
    _scannerController?.start();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Camera ────────────────────────────────────────
            if (_hasPermission)
              MobileScanner(
                controller: _scannerController,
                onDetect: _handleBarcode,
                scanWindow: Rect.fromLTWH(
                  MediaQuery.of(context).size.width * 0.1,
                  MediaQuery.of(context).size.height * 0.2,
                  MediaQuery.of(context).size.width * 0.8,
                  MediaQuery.of(context).size.width * 0.8,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography, size: 64, color: Colors.white54),
                    const SizedBox(height: AppTheme.cardPadding),
                    Text('Kamera tidak tersedia', style: AppTheme.bodyMedium(context).copyWith(color: Colors.white54)),
                    const SizedBox(height: AppTheme.itemGap),
                    ElevatedButton(onPressed: _checkPermission, child: const Text('Minta Izin')),
                  ],
                ),
              ),

            // ── Overlay + UI ──────────────────────────────────
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
                      Expanded(child: Text('Scan Kehadiran', style: AppTheme.titleMedium(context).copyWith(color: Colors.white), textAlign: TextAlign.center)),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.sectionGap),
                Text('Arahkan kamera ke QR Code kelas', style: AppTheme.bodyMedium(context).copyWith(color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: AppTheme.sectionGap),

                // ── Scan Frame ────────────────────────────────
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.width * 0.7,
                    child: Stack(
                      children: [
                        _Corner(alignment: Alignment.topLeft, rotate: false),
                        _Corner(alignment: Alignment.topRight, rotate: true),
                        _Corner(alignment: Alignment.bottomLeft, rotate: false, flipV: true),
                        _Corner(alignment: Alignment.bottomRight, rotate: true, flipV: true),
                        if (_result == null && !_isProcessing)
                          AnimatedBuilder(
                            animation: _scanLineAnim,
                            builder: (context, _) => Positioned(
                              top: _scanLineAnim.value * (MediaQuery.of(context).size.width * 0.7 - 4),
                              left: 0, right: 0,
                              child: Container(
                                height: 2,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.transparent, AppTheme.primaryBlue, Colors.transparent]),
                                ),
                              ),
                            ),
                          ),
                        if (_isProcessing)
                          const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),

                // ── Controls ─────────────────────────────────
                if (_result == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlPill(icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, label: _isFlashOn ? 'Flash On' : 'Flash Off', onTap: () { setState(() => _isFlashOn = !_isFlashOn); _scannerController?.toggleTorch(); }),
                        const SizedBox(width: AppTheme.cardPadding),
                        _ControlPill(icon: Icons.flip_camera_android_rounded, label: 'Balik', onTap: () => _scannerController?.switchCamera()),
                      ],
                    ),
                  ),

                // ── Result Panel ──────────────────────────────
                if (_result != null)
                  _ResultPanel(result: _result!, onRetry: _resetScan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────
enum _ScanResult { success, error, notScheduled }

class _Corner extends StatelessWidget {
  final AlignmentGeometry alignment;
  final bool rotate;
  final bool flipV;
  const _Corner({required this.alignment, required this.rotate, this.flipV = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.scale(
        scaleX: rotate ? -1 : 1,
        scaleY: flipV ? -1 : 1,
        child: SizedBox(width: 36, height: 36, child: CustomPaint(painter: _CornerPainter())),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primaryBlue..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * 0.6), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.6, 0), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ControlPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ControlPill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: AppTheme.bodySmall(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final _ScanResult result;
  final VoidCallback onRetry;
  const _ResultPanel({required this.result, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (IconData icon, Color iconColor, String title, String subtitle) = switch (result) {
      _ScanResult.success => (Icons.check_circle_rounded, AppTheme.success, 'Kehadiran Berhasil Dicatat', 'Data kehadiran Anda telah diperbarui secara otomatis.'),
      _ScanResult.notScheduled => (Icons.event_busy_rounded, AppTheme.warning, 'Tidak Terjadwal', 'Anda tidak terjadwal di kelas ini sekarang.'),
      _ScanResult.error => (Icons.error_rounded, AppTheme.danger, 'QR Code Tidak Valid', 'Silakan coba scan ulang kode yang benar.'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppTheme.sectionGap, AppTheme.sectionGap, AppTheme.sectionGap, 32),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppTheme.screenPadding),
          Icon(icon, color: iconColor, size: 52),
          const SizedBox(height: AppTheme.itemGap),
          Text(title, style: AppTheme.titleMedium(context), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(subtitle, style: AppTheme.bodySmall(context), textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.sectionGap),
          Row(
            children: [
              if (result != _ScanResult.success) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.inputBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Tutup', style: AppTheme.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: AppTheme.itemGap),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: result == _ScanResult.success ? () => Navigator.pop(context) : onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: result == _ScanResult.success ? AppTheme.success : AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    result == _ScanResult.success ? 'Selesai' : 'Scan Ulang',
                    style: AppTheme.labelBold(context).copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}