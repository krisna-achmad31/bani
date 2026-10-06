import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  01 Login — Google only. After sign-in the router redirects (to the pending
//  invite if the user came from a link, otherwise to Beranda).
// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _pager = PageController();
  var _page = 0;
  var _loading = false;


  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingInviteProvider);
    final t = context.t;
    final slides = [
      (t.loginSlide1Title, t.loginSlide1Body),
      (t.loginSlide2Title, t.loginSlide2Body),
      (t.loginSlide3Title, t.loginSlide3Body),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/icon/icon.png', width: 36, height: 36),
              ),
              const SizedBox(width: 10),
              Text(t.appName, style: AppText.display(24, color: AppColors.primary)),
              const Spacer(),
              const LanguageToggle(),
            ]),
            const SizedBox(height: 24),
            const FadeSlideIn(child: _TreePreview()),
            const SizedBox(height: 24),
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _pager,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slides[i].$1, style: AppText.display(28)),
                    const SizedBox(height: 12),
                    Text(slides[i].$2,
                        style: AppText.body(15, color: AppColors.ink2, height: 1.5)),
                  ],
                ),
              ),
            ),
            Row(children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _page ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.primary : AppColors.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ]),
            const SizedBox(height: 24),
            if (pending != null) ...[
              Pill.gold(t.loginPendingInvite, icon: Icons.mail_outline),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _loading ? null : _signIn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 24, height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Text('G', style: AppText.body(14,
                              weight: FontWeight.w800, color: const Color(0xFF4285F4))),
                        ),
                        const SizedBox(width: 12),
                        Text(t.loginWithGoogle,
                            style: AppText.body(16, weight: FontWeight.w700)),
                      ]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.loginTerms,
              textAlign: TextAlign.center,
              style: AppText.body(12, color: AppColors.ink3, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small silsilah that grows downward, as the Pohon tab shows it.
class _TreePreview extends StatelessWidget {
  const _TreePreview();

  static const _rows = [
    (0, 'Hj. Aminah', 1, false),
    (1, 'Rahmat', 2, false),
    (1, 'Sari', 2, false),
    (2, 'Dimas', 3, true),
    (2, 'Ayu', 3, false),
  ];

  @override
  Widget build(BuildContext context) {
    const rowH = 50.0, indent = 34.0, left = 20.0, avatar = 38.0;
    double cx(int d) => left + avatar / 2 + d * indent;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
          color: AppColors.surface2, borderRadius: BorderRadius.circular(28)),
      child: SizedBox(
        height: rowH * _rows.length,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _PreviewLines(cx, rowH))),
          for (final (i, (d, name, gen, me)) in _rows.indexed)
            Positioned(
              left: cx(d) - avatar / 2 - (me ? 6 : 0),
              right: 16,
              top: i * rowH + (me ? 3 : 0),
              height: rowH - (me ? 6 : 0),
              child: Container(
                padding: EdgeInsets.only(left: me ? 6 : 0),
                decoration: me
                    ? const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(24), right: Radius.circular(12)))
                    : null,
                child: Row(children: [
                  MemberAvatar(
                    name: name,
                    size: avatar,
                    ring: false,
                    background: me ? AppColors.primary : AppColors.surface,
                    foreground: me ? Colors.white : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppText.body(14, weight: FontWeight.w700)),
                        Text(context.t.generation(gen),
                            style: AppText.body(11,
                                color: me ? AppColors.primary : AppColors.ink2)),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class _PreviewLines extends CustomPainter {
  _PreviewLines(this.cx, this.rowH);
  final double Function(int) cx;
  final double rowH;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.branch
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // parent row → child rows, as (depth, from, to) elbows
    void elbow(int depth, int fromRow, int toRow) {
      final x = cx(depth), y0 = fromRow * rowH + rowH / 2 + 19, y1 = toRow * rowH + rowH / 2;
      canvas.drawPath(
        Path()
          ..moveTo(x, y0)
          ..lineTo(x, y1 - 9)
          ..quadraticBezierTo(x, y1, x + 9, y1)
          ..lineTo(cx(depth + 1) - 19, y1),
        p,
      );
    }

    elbow(0, 0, 1);
    elbow(0, 0, 2);
    elbow(1, 2, 3);
    elbow(1, 2, 4);
  }

  @override
  bool shouldRepaint(_PreviewLines old) => false;
}
