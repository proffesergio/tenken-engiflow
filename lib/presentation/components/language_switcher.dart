import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/locale_provider.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class LanguageSwitcher extends StatefulWidget {
  final bool showLabel;
  final bool showIcon;
  
  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.showIcon = true,
  });
  
  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  bool _isSwitching = false;
  
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isEnglish = localeProvider.isEnglish;
    
    return GestureDetector(
      onTap: () async {
        if (_isSwitching) return;
        
        setState(() => _isSwitching = true);
        
        // Show language selection dialog
        await _showLanguageDialog(context, localeProvider);
        
        setState(() => _isSwitching = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              Icon(
                Icons.language,
                size: 20,
                color: isEnglish ? Colors.blue : Colors.red,
              ),
              const SizedBox(width: 8),
            ],
            if (widget.showLabel) ...[
              Text(
                isEnglish ? 'EN' : 'JP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isEnglish ? Colors.blue : Colors.red,
                ),
              ),
            ],
            if (_isSwitching) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                label: AppLocalizations.of(context)!.english,
                locale: const Locale('en'),
                isSelected: localeProvider.isEnglish,
                flag: '🇺🇸',
              ),
              const SizedBox(height: 12),
              _buildLanguageOption(
                context,
                label: AppLocalizations.of(context)!.japanese,
                locale: const Locale('ja'),
                isSelected: localeProvider.isJapanese,
                flag: '🇯🇵',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context, {
    required String label,
    required Locale locale,
    required bool isSelected,
    required String flag,
  }) {
    return GestureDetector(
      onTap: () {
        Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF37474F).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF37474F) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF37474F),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF37474F),
              ),
          ],
        ),
      ),
    );
  }
}