import 'package:flutter/material.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final String? errorText;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: AppBorderRadius.buttonRadius,
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: hint != null
                  ? Text(
                      hint!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: items,
              onChanged: enabled ? onChanged : null,
              style: AppTextStyles.body,
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.surface,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class AppStatusDropdown extends StatelessWidget {
  final String? label;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final bool enabled;

  const AppStatusDropdown({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusOptions = [
      ('TERBUKA', 'Terbuka', AppColors.statusTerbuka, Icons.access_time),
      ('DIPROSES', 'Diproses', AppColors.statusDiproses, Icons.sync),
      ('SELESAI', 'Selesai', AppColors.statusSelesai, Icons.check_circle),
    ];

    return AppDropdown<String>(
      label: label,
      hint: 'Pilih status',
      value: value,
      isRequired: isRequired,
      enabled: enabled,
      items: statusOptions.map((option) {
        final (statusValue, label, color, icon) = option;
        return DropdownMenuItem(
          value: statusValue,
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.body.copyWith(color: color),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class AppRoleDropdown extends StatelessWidget {
  final String? label;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final bool enabled;

  const AppRoleDropdown({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final roleOptions = [
      ('pengguna', 'Pengguna', Icons.person),
      ('helpdesk', 'Helpdesk', Icons.support_agent),
      ('admin', 'Admin', Icons.admin_panel_settings),
    ];

    return AppDropdown<String>(
      label: label ?? 'Peran',
      hint: 'Pilih peran',
      value: value,
      isRequired: isRequired,
      enabled: enabled,
      items: roleOptions.map((option) {
        final (roleValue, label, icon) = option;
        return DropdownMenuItem(
          value: roleValue,
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.body),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
