import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../cubit/komentar_input_cubit.dart';
import 'komentar_list.dart';

/// Fixed bottom input widget for komentar
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
    return BlocProvider(
      create: (context) => KomentarInputCubit(
        komentarRepository: getIt<KomentarRepository>(),
      ),
      child: KomentarInputView(
        tiketId: tiketId,
        onKomentarSubmitted: onKomentarSubmitted,
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

    final cubit = context.read<KomentarInputCubit>();

    if (cubit.state.isValid) {
      final komentar = await cubit.submit(widget.tiketId);

      if (komentar != null && mounted) {
        _textController.clear();
        widget.onKomentarSubmitted?.call(komentar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KomentarInputCubit, KomentarInputState>(
      listener: (context, state) {
        if (state.status == KomentarInputStatus.error &&
            state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            left: AppSpacing.default_,
            right: AppSpacing.default_,
            top: AppSpacing.md,
            bottom: AppSpacing.default_ +
                MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.overlay.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppBorderRadius.inputRadius,
                      border: Border.all(
                        color: state.status == KomentarInputStatus.error
                            ? AppColors.error
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            maxLines: 5,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.default_,
                                vertical: AppSpacing.md,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            enabled: !state.isSubmitting,
                          ),
                        ),
                        // Clear button (shown when text is not empty)
                        if (!state.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onPressed: _clearText,
                              splashRadius: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Send button
                _buildSendButton(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton(KomentarInputState state) {
    final isDisabled = !state.isValid || state.isSubmitting;

    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.border
              : AppColors.primary,
          borderRadius: AppBorderRadius.buttonRadius,
        ),
        child: state.isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.white,
                    ),
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(
                  Icons.send,
                  color: AppColors.white,
                ),
                onPressed: isDisabled ? null : _submit,
                splashRadius: 24,
              ),
      ),
    );
  }
}

/// Combined widget for komentar section (list + input)
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
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.default_),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Komentar',
                style: AppTextStyles.title,
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
