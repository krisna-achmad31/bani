import 'package:bani/core/providers/app_providers.dart';
import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/tree/data/models/feedback_model.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:bani/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Kirim saran (everyone) + Saran masuk (Super Admin)
// ─────────────────────────────────────────────────────────────────────────────

String feedbackTypeLabel(BuildContext context, FeedbackType t) => switch (t) {
      FeedbackType.idea => context.t.fbTypeIdea,
      FeedbackType.bug => context.t.fbTypeBug,
      FeedbackType.other => context.t.fbTypeOther,
    };

Future<void> showFeedbackSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FeedbackSheet(),
    );

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet();

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  final _text = TextEditingController();
  var _type = FeedbackType.idea;
  var _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = context.t;
    if (_text.text.trim().length < 5) {
      showMessage(context, t.fbTooShort);
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await ref.read(treeRepositoryProvider).sendFeedback(
            user: user,
            type: _type,
            message: _text.text,
            appVersion: ref.read(appVersionProvider).value,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showMessage(context, t.fbThanks);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(t.fbTitle, style: AppText.display(22)),
        const SizedBox(height: 6),
        Text(t.fbBody, style: AppText.body(14, color: AppColors.ink2, height: 1.45)),
        const SizedBox(height: 16),
        Segmented<FeedbackType>(
          options: FeedbackType.values,
          value: _type,
          labelOf: (v) => feedbackTypeLabel(context, v),
          onChanged: (v) => setState(() => _type = v),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _text,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          maxLength: 2000,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: t.fbHint),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _sending ? null : _send,
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(_sending ? t.saving : t.fbSend),
        ),
      ]),
    );
  }
}

final feedbackProvider = StreamProvider<List<FeedbackModel>>(
    (ref) => ref.watch(treeRepositoryProvider).watchFeedback());

class FeedbackInboxPage extends ConsumerWidget {
  const FeedbackInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final async = ref.watch(feedbackProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.fbInboxTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => MessageView(icon: Icons.lock_outline, title: t.loadFailed, message: '$e'),
        data: (items) => items.isEmpty
            ? MessageView(icon: Icons.inbox_outlined, title: t.fbInboxEmpty)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final f = items[i];
                  return FadeSlideIn(
                    index: i,
                    child: AppCard(
                      color: f.done ? AppColors.bg : AppColors.surface,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          f.type == FeedbackType.bug
                              ? Pill(feedbackTypeLabel(context, f.type),
                                  color: AppColors.danger, background: AppColors.dangerSoft)
                              : Pill(feedbackTypeLabel(context, f.type)),
                          const SizedBox(width: 8),
                          f.done ? Pill.gold(t.fbDone) : Pill.gold(t.fbNew),
                          const Spacer(),
                          Text(formatDate(f.createdAt),
                              style: AppText.body(12, color: AppColors.ink3)),
                        ]),
                        const SizedBox(height: 10),
                        Text(f.message, style: AppText.body(15, height: 1.45)),
                        const SizedBox(height: 10),
                        Text(
                          [f.userName, f.userEmail, if (f.appVersion != null) 'v${f.appVersion}']
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          style: AppText.body(12, color: AppColors.ink3),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => ref
                                .read(treeRepositoryProvider)
                                .setFeedbackDone(f.id, !f.done),
                            child: Text(f.done ? t.fbNew : t.fbMarkDone),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
