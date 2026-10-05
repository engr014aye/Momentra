import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/theme_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionHeader(label: 'Appearance'),
                SizedBox(height: 12),
                const _ThemeSelector(),
                SizedBox(height: 32),
                
                const _SectionHeader(label: 'Support'),
                SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Contact Us',
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: AppConstants.supportEmail,
                      query: 'subject=Momentra Support',
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerTheme.color!),
      ),
      child: Column(
        children: [
          _ThemeRadioTile(
            title: 'System Default',
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (val) => themeProvider.setThemeMode(val!),
          ),
          Divider(color: Theme.of(context).dividerTheme.color, height: 1),
          _ThemeRadioTile(
            title: 'Light',
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (val) => themeProvider.setThemeMode(val!),
          ),
          Divider(color: Theme.of(context).dividerTheme.color, height: 1),
          _ThemeRadioTile(
            title: 'Dark',
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (val) => themeProvider.setThemeMode(val!),
          ),
        ],
      ),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.displayLarge?.color,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (val) {
        HapticFeedback.lightImpact();
        onChanged(val);
      },
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerTheme.color!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodySmall?.color),
          ],
        ),
      ),
    );
  }
}

