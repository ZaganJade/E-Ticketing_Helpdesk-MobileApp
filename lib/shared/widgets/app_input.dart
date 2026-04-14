import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// App Input - Redesigned to use shadcn_ui ShadInput
/// A reusable input component with consistent styling
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.destructive,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (type == AppInputType.multiline)
          _buildMultilineInput(context, isTablet)
        else
          ShadInput(
            controller: controller,
            placeholder: hint != null ? Text(hint!) : null,
            obscureText: type == AppInputType.password,
            keyboardType: _getKeyboardType(),
            maxLength: maxLength,
            enabled: enabled,
            autofocus: autofocus,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted?.call(),
          ),
        if (helperText != null && errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ShadcnTheme.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ShadcnTheme.destructive.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: ShadcnTheme.destructive,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorText!,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: ShadcnTheme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultilineInput(BuildContext context, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      maxLines: maxLines ?? 5,
      minLines: 3,
      maxLength: maxLength,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        ),
        filled: true,
        fillColor: isDark ? ShadcnTheme.darkBackground : ShadcnTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? ShadcnTheme.darkBorder : ShadcnTheme.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: ShadcnTheme.accent,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: isTablet ? 16 : 12,
        ),
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (type) {
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.number:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }
}

enum AppInputType {
  text,
  password,
  email,
  multiline,
  number,
}

/// App Password Input - Password input with visibility toggle
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: ShadcnTheme.destructive,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        ShadInput(
          controller: widget.controller,
          placeholder: widget.hint != null ? Text(widget.hint!) : null,
          obscureText: _obscureText,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          trailing: ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ),
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: isTablet ? 13 : 12,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ShadcnTheme.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ShadcnTheme.destructive.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: ShadcnTheme.destructive,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: ShadcnTheme.destructive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// App Search Input - Search input with search icon and clear button
class AppSearchInput extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClear;

  const AppSearchInput({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: Text(hint ?? 'Cari...'),
      leading: const Icon(Icons.search, size: 20),
      trailing: controller?.text.isNotEmpty == true
          ? ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: onClear,
              child: const Icon(Icons.clear, size: 18),
            )
          : null,
      onChanged: onChanged,
      onSubmitted: (_) => onSubmitted?.call(),
    );
  }
}
