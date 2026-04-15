import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/shadcn_theme.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../cubit/komentar_input_cubit.dart';
import '../cubit/komentar_cubit.dart';
import 'komentar_list.dart';

/// Fixed bottom input widget for komentar - Redesigned with shadcn_ui
class KomentarInput extends StatelessWidget {
  final String tiketId;
  final Function(Komentar)? onKomentarSubmitted;

  const KomentarInput({
    super.key,
    required this.tiketId,
    this.onKomentarSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Use BlocProvider.value to avoid creating a new scope
    return BlocProvider<KomentarInputCubit>(
      create: (context) => KomentarInputCubit(
        komentarRepository: getIt<KomentarRepository>(),
      ),
      child: Builder(
        builder: (context) => KomentarInputView(
          tiketId: tiketId,
          onKomentarSubmitted: onKomentarSubmitted,
        ),
      ),
    );
  }
}

class KomentarInputView extends StatefulWidget {
  final String tiketId;
  final Function(Komentar)? onKomentarSubmitted;

  const KomentarInputView({
    super.key,
    required this.tiketId,
    this.onKomentarSubmitted,
  });

  @override
  State<KomentarInputView> createState() => _KomentarInputViewState();
}

class _KomentarInputViewState extends State<KomentarInputView> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    context.read<KomentarInputCubit>().messageChanged(_textController.text);
  }

  void _clearText() {
    _textController.clear();
    context.read<KomentarInputCubit>().clearMessage();
  }

  Future<void> _submit() async {
    _focusNode.unfocus();

    final inputCubit = context.read<KomentarInputCubit>();

    if (inputCubit.state.isValid) {
      final message = inputCubit.state.message.trim();
      debugPrint('KomentarInput: Submitting message: $message');

      // Clear input immediately for better UX
      _textController.clear();

      // Clear input cubit state
      inputCubit.clearMessage();

      // Call addKomentar on KomentarCubit which has optimistic update
      // Don't await - let it run in background for instant UI feedback
      unawaited(_addKomentar(message));
    }
  }

  Future<void> _addKomentar(String message) async {
    try {
      final listCubit = context.read<KomentarCubit>();
      debugPrint('KomentarInput: Found KomentarCubit, state: ${listCubit.state.runtimeType}');

      await listCubit.addKomentar(
        tiketId: widget.tiketId,
        isiPesan: message,
      );

      debugPrint('KomentarInput: addKomentar completed');
    } catch (e) {
      debugPrint('KomentarInput: ERROR - $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim komentar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocConsumer<KomentarInputCubit, KomentarInputState>(
      listener: (context, state) {
        if (state.status == KomentarInputStatus.error &&
            state.errorMessage != null) {
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Error'),
              description: Text(state.errorMessage!),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: isTablet ? 24 : 16,
            right: isTablet ? 24 : 16,
            top: isTablet ? 16 : 12,
            bottom: (isTablet ? 24 : 16) +
                MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? ShadcnTheme.darkCard : ShadcnTheme.card,
            border: Border(
              top: BorderSide(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field using ShadInput
                Expanded(
                  child: ShadInput(
                    placeholder: const Text('Tulis komentar...'),
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !state.isSubmitting,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                // Send button
                _buildSendButton(state, isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton(KomentarInputState state, bool isTablet) {
    final isDisabled = !state.isValid || state.isSubmitting;

    return SizedBox(
      width: isTablet ? 52 : 48,
      height: isTablet ? 52 : 48,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDisabled
              ? (Theme.of(context).brightness == Brightness.dark
                  ? ShadcnTheme.darkBorder
                  : ShadcnTheme.border)
              : ShadcnTheme.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: state.isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: isTablet ? 22 : 20,
                ),
                onPressed: isDisabled ? null : _submit,
                splashRadius: 24,
              ),
      ),
    );
  }
}

/// Combined widget for komentar section (list + input) - Redesigned with shadcn_ui
class KomentarSection extends StatelessWidget {
  final String tiketId;
  final String currentUserId;

  const KomentarSection({
    super.key,
    required this.tiketId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Column(
      children: [
        // Header with gradient icon
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ShadcnTheme.accent.withValues(alpha: 0.2),
                      ShadcnTheme.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: ShadcnTheme.accent,
                  size: isTablet ? 24 : 20,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                'Komentar',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),

        // Komentar list
        Expanded(
          child: KomentarList(
            tiketId: tiketId,
            currentUserId: currentUserId,
          ),
        ),

        // Input
        KomentarInput(
          tiketId: tiketId,
        ),
      ],
    );
  }
}
