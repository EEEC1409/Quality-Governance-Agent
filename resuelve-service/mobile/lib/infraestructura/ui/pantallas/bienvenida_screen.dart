import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../adaptadores/presentadores/bienvenida_presenter.dart';

class BienvenidaScreen extends StatefulWidget {
  final BienvenidaPresenter presenter;
  final VoidCallback? onContinuar;

  const BienvenidaScreen({
    super.key,
    required this.presenter,
    this.onContinuar,
  });

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    widget.presenter.addListener(_onEstadoCambia);
    widget.presenter.cargar();
  }

  @override
  void dispose() {
    widget.presenter.removeListener(_onEstadoCambia);
    _videoController?.dispose();
    super.dispose();
  }

  void _onEstadoCambia() {
    final estado = widget.presenter.estado;
    if (estado is BienvenidaConContenido) {
      _iniciarVideo(estado.videoUrl);
    }
    if (mounted) setState(() {});
  }

  void _iniciarVideo(String url) {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        _videoController!.play();
        _videoController!.addListener(_onVideoProgreso);
        if (mounted) setState(() {});
      }).catchError((_) {
        // fallo silencioso — sin video no bloquea el flujo
      });
  }

  void _onVideoProgreso() {
    final ctrl = _videoController;
    if (ctrl == null) return;
    if (ctrl.value.position >= ctrl.value.duration && ctrl.value.duration > Duration.zero) {
      _continuar();
    }
  }

  Future<void> _continuar() async {
    _videoController?.removeListener(_onVideoProgreso);
    await widget.presenter.continuar();
    widget.onContinuar?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              'assets/images/logo_resuelve.png',
              key: const Key('logo_bienvenida'),
              height: 120,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance,
                key: Key('logo_bienvenida'),
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            _buildVideo(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('boton_continuar'),
                  onPressed: _continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C9A7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    final estado = widget.presenter.estado;
    if (estado is BienvenidaConContenido &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return AspectRatio(
        key: const Key('video_player'),
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }
    return const SizedBox.shrink(key: Key('video_placeholder'));
  }
}
