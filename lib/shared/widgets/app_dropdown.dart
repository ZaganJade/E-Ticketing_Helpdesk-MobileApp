import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/theme/shadcn_theme.dart';

/// App Dropdown - Redesigned with shadcn_ui ShadSelect
/// A reusable dropdown component following AGENTS.md guidelines
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<ShadOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final String? errorText;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.options,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            isRequired ? '$label *' : label!,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: ShadTheme.of(context).colorScheme.foreground,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
        ],
        ShadSelect<T>(
          enabled: enabled,
          placeholder: Text(
            hint ?? 'Pilih...',
            style: TextStyle(
              fontSize: isTablet ? 15 : 14,
              color: ShadTheme.of(context).colorScheme.mutedForeground,
            ),
          ),
          initialValue: value,
          onChanged: onChanged,
          options: options,
          selectedOptionBuilder: (context, value) {
            final option = options.firstWhere(
              (opt) => opt.value == value,
              orElse: () => ShadOption(value: value, child: Text(value.toString())),
            );
            return option.child;
          },
        ),
        if (errorText != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: isTablet ? 12 : 11,
              color: ShadcnTheme.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

/// App Status Dropdown - Pre-configured dropdown for ticket status
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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final statusOptions = [
      (
        'TERBUKA',
        'Terbuka',
        ShadcnTheme.statusOpen,
        Icons.radio_button_unchecked_rounded
      ),
      (
        'DIPROSES',
        'Diproses',
        ShadcnTheme.statusInProgress,
        Icons.sync_rounded
      ),
      (
        'SELESAI',
        'Selesai',
        ShadcnTheme.statusDone,
        Icons.check_circle_rounded
      ),
    ];

    return AppDropdown<String>(
      label: label,
      hint: 'Pilih status',
      value: value,
      isRequired: isRequired,
      enabled: enabled,
      options: statusOptions.map((option) {
        final (statusValue, label, color, icon) = option;
        return ShadOption(
          value: statusValue,
          child: Row(
            children: [
              Icon(icon, size: isTablet ? 18 : 16, color: color),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// App Role Dropdown - Pre-configured dropdown for user roles
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
    final isTablet = MediaQuery.of(context).size.width >= 600;

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
      options: roleOptions.map((option) {
        final (roleValue, label, icon) = option;
        return ShadOption(
          value: roleValue,
          child: Row(
            children: [
              Icon(
                icon,
                size: isTablet ? 18 : 16,
                color: ShadcnTheme.getMutedForeground(context),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  color: ShadTheme.of(context).colorScheme.foreground,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

/// App Priority Dropdown - Pre-configured dropdown for ticket priority
class AppPriorityDropdown extends StatelessWidget {
  final String? label;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final bool enabled;

  const AppPriorityDropdown({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final priorityOptions = [
      ('rendah', 'Rendah', ShadcnTheme.statusDone, Icons.arrow_downward_rounded),
      ('sedang', 'Sedang', ShadcnTheme.statusInProgress, Icons.remove_rounded),
      ('tinggi', 'Tinggi', ShadcnTheme.statusOpen, Icons.arrow_upward_rounded),
    ];

    return AppDropdown<String>(
      label: label ?? 'Prioritas',
      hint: 'Pilih prioritas',
      value: value,
      isRequired: isRequired,
      enabled: enabled,
      options: priorityOptions.map((option) {
        final (priorityValue, label, color, icon) = option;
        return ShadOption(
          value: priorityValue,
          child: Row(
            children: [
              Icon(icon, size: isTablet ? 18 : 16, color: color),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
