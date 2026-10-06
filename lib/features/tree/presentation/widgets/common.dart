import 'dart:convert';
import 'dart:typed_data';

import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/core/providers/locale_provider.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Shared building blocks matching bani.pen
// ─────────────────────────────────────────────────────────────────────────────

/// Decoded thumbnails, least-recently-used first; bounded so long sessions
/// on big trees don't keep growing memory.
final _decoded = <int, Uint8List>{}; // insertion-ordered (LinkedHashMap)
const _maxDecoded = 400;

Uint8List? decodeBase64Image(String? data) {
  if (data == null || data.isEmpty) return null;
  final key = data.hashCode;
  final hit = _decoded.remove(key);
  final bytes = hit ?? base64Decode(data);
  _decoded[key] = bytes;
  if (_decoded.length > _maxDecoded) _decoded.remove(_decoded.keys.first);
  return bytes;
}

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.name,
    this.photo,
    this.photoBytes,
    this.size = 52,
    this.ring = true,
    this.deceased = false,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.primary,
  });

  final String name;
  final String? photo;

  /// Already-decoded photo (e.g. from PhotoCache); wins over [photo].
  final Uint8List? photoBytes;
  final double size;
  final bool ring;
  final bool deceased;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes ?? decodeBase64Image(photo);
    Widget child = bytes != null
        ? Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true,
            width: size, height: size)
        : Center(
            child: Text(initialOf(name),
                style: AppText.display(size * 0.42, color: foreground)),
          );
    if (deceased && bytes != null) {
      child = ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: child);
    }
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: deceased ? AppColors.surface2 : background,
        border: ring
            ? Border.all(
                color: deceased ? AppColors.ink3 : AppColors.branch,
                width: size > 80 ? 3 : 2)
            : null,
      ),
      child: child,
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = AppColors.primary,
      this.background = AppColors.primarySoft, this.icon});

  final String text;
  final Color color;
  final Color background;
  final IconData? icon;

  factory Pill.gold(String text, {IconData? icon}) => Pill(text,
      color: AppColors.gold, background: AppColors.goldSoft, icon: icon);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: background, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
          Text(text, style: AppText.body(12, weight: FontWeight.w700, color: color)),
        ]),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(18),
      this.color = AppColors.surface, this.onTap, this.border = true});

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final bool border;

  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: border ? const BorderSide(color: AppColors.line) : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.line)),
        child: IconButton(
            icon: Icon(icon, size: 20, color: AppColors.ink),
            tooltip: tooltip,
            onPressed: onPressed),
      );
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (subtitle != null)
                Text(subtitle!, style: AppText.body(14, color: AppColors.ink2)),
              Text(title, style: AppText.display(28)),
            ]),
          ),
          ?trailing,
        ],
      );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(text, style: AppText.body(16, weight: FontWeight.w700))),
        ?trailing,
      ]);
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: AppText.body(13, weight: FontWeight.w600, color: AppColors.ink2)),
      );
}

/// Segmented control styled like the design ("Laki-laki | Perempuan").
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value,
      required this.onChanged, required this.labelOf});

  final List<T> options;
  final T value;
  final ValueChanged<T> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.surface2, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o == value ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: o == value
                        ? const [BoxShadow(color: Color(0x141F2A24), blurRadius: 3, offset: Offset(0, 1))]
                        : null,
                  ),
                  child: Text(labelOf(o),
                      style: AppText.body(14,
                          weight: o == value ? FontWeight.w700 : FontWeight.w500,
                          color: o == value ? AppColors.ink : AppColors.ink2)),
                ),
              ),
            ),
        ]),
      );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.icon, required this.title,
      this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                  color: AppColors.goldSoft, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: AppColors.gold, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: AppText.display(22)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, textAlign: TextAlign.center,
                  style: AppText.body(14, color: AppColors.ink2, height: 1.45)),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ]),
        ),
      );
}

void showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(AppFailure.from(error).message)));
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// "Paket Gratis" / "Keluarga" / "Keluarga Besar".
String planLabel(BuildContext context, String plan) => switch (plan) {
      'keluarga' => context.t.planFamily,
      'keluarga_besar' => context.t.planBigFamily,
      _ => context.t.planFree,
    };

/// Small "ID | EN" switch (Login page); Profil has the full picker.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    Widget item(String c) => GestureDetector(
          onTap: () => ref.read(localeProvider.notifier).set(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: code == c ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(c.toUpperCase(),
                style: AppText.body(12,
                    weight: FontWeight.w700,
                    color: code == c ? Colors.white : AppColors.ink2)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [item('id'), item('en')]),
    );
  }
}

/// One-shot fade + slight rise when a widget first appears. Cheap: a single
/// implicit tween, no controllers; [index] staggers items in a list.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 320 + 60 * index.clamp(0, 6)),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: c),
        ),
        child: child,
      );
}
