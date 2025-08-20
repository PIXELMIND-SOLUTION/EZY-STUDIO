
import 'package:edit_ezy_project/providers/language/language_provider.dart';
import 'package:edit_ezy_project/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
          color: theme.colorScheme.onSurface,
        ),
        title: AppText(
          'settings',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.12),
                    theme.colorScheme.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.settings_suggest_rounded,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          AppText.translate(context, 'settings'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppText.translate(
                              context, 'Customize your experience'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Appearance Section
          _buildSectionTitle(context, AppText.translate(context, 'appearance')),
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _SwitchRow(
                  icon: Icons.dark_mode,
                  label: AppText.translate(context, 'dark_mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (v) => themeProvider.toggleTheme(v),
                ),
              ],
            ),
          ),

          // Preferences Section
          // _buildSectionTitle(context, AppText.translate(context, 'preferences')),
          // SliverToBoxAdapter(
          //   child: _SettingsCard(
          //     children: [
          //       _SwitchRow(
          //         icon: Icons.notifications,
          //         label: AppText.translate(context, 'notifications'),
          //         value: _notificationsEnabled,
          //         onChanged: (v) => setState(() => _notificationsEnabled = v),
          //       ),
          //       const _Divider(),
          //       // _NavRow(
          //       //   icon: Icons.language,
          //       //   label: AppText.translate(context, 'language'),
          //       //   valueText: languageProvider.currentLocaleName, // e.g., "English"
          //       //   onTap: () {
          //       //     // Implement your language picker / cycle here:
          //       //     // languageProvider.cycleToNextLocale();
          //       //     // or navigate to a Language screen
          //       //   },
          //       // ),
          //     ],
          //   ),
          // ),

          // About Section
          // _buildSectionTitle(context, AppText.translate(context, 'about')),
          // SliverToBoxAdapter(
          //   child: _SettingsCard(
          //     children: const [
          //       _NavRow(
          //         icon: Icons.shield_outlined,
          //         label: 'Privacy Policy',
          //       ),
          //       _Divider(),
          //       _NavRow(
          //         icon: Icons.description_outlined,
          //         label: 'Terms & Conditions',
          //       ),
          //       _Divider(),
          //       _NavRow(
          //         icon: Icons.info_outline,
          //         label: 'App Version',
          //         valueText: 'v1.0.0',
          //       ),
          //     ],
          //   ),
          // ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// Card container for settings groups
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.25),
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// Row with a leading icon, label and a trailing FlutterSwitch
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          FlutterSwitch(
            value: value,
            onToggle: onChanged,
            height: 28,
            width: 56,
            toggleSize: 22,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.disabledColor.withOpacity(0.5),
            padding: 3,
          ),
        ],
      ),
    );
  }
}

/// Row with a leading icon, label and optional trailing text + chevron
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    this.valueText,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? valueText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (valueText != null) ...[
              Text(
                valueText!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      indent: 14,
      endIndent: 14,
      color: theme.dividerColor.withOpacity(0.25),
    );
  }
}
