import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppInputType {
  text,
  password,
  email,
  multiline,
  number,
}

class AppInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final AppInputType type;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.type = AppInputType.text,
    this.isRequired = false,
    this.onChanged,
    this.onClear,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            isRequired ? '$label *' : label!,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          obscureText: type == AppInputType.password,
          keyboardType: _getKeyboardType(),
          maxLines: type == AppInputType.multiline ? (maxLines ?? 3) : 1,
          minLines: type == AppInputType.multiline ? 3 : 1,
          maxLength: maxLength,
          enabled: enabled,
          autofocus: autofocus,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            filled: true,
            suffixIcon: _buildSuffixIcon(),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (onClear != null && controller != null && controller!.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: onClear,
      );
    }

    if (type == AppInputType.password) {
      // Would need stateful widget for password visibility toggle
      return null;
    }

    return null;
  }

  TextInputType _getKeyboardType() {
    switch (type) {
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.multiline:
        return TextInputType.multiline;
      case AppInputType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}

class AppPasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AppPasswordInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.isRequired = false,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppPasswordInput> createState() => _AppPasswordInputState();
}

class _AppPasswordInputState extends State<AppPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.isRequired ? '${widget.label} *' : widget.label!,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
