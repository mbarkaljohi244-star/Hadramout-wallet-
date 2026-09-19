import 'package:flutter/material.dart';

import 'theme.dart';

class WalletLogo extends StatelessWidget {
  const WalletLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 76.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: WalletColors.blue,
        borderRadius: BorderRadius.circular(compact ? 14 : 24),
        boxShadow: [
          BoxShadow(
            color: WalletColors.blue.withAlpha(45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: compact ? 23 : 40,
      ),
    );
  }
}

class WalletScaffold extends StatelessWidget {
  const WalletScaffold({
    required this.title,
    required this.child,
    super.key,
    this.showBack = true,
    this.action,
  });

  final String title;
  final Widget child;
  final bool showBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        automaticallyImplyLeading: showBack,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: action == null ? null : [action!],
      ),
      body: child,
    );
  }
}

class ScreenPadding extends StatelessWidget {
  const ScreenPadding({required this.child, super.key, this.bottom = 28});

  final Widget child;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(20, 10, 20, bottom),
        child: child,
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: WalletColors.ink,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              color: WalletColors.muted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    super.key,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WalletColors.paleBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: WalletColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: WalletColors.navy,
                height: 1.55,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrimaryAction extends StatelessWidget {
  const PrimaryAction({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.arrow_back_rounded),
      label: Text(loading ? 'جارٍ المعالجة...' : label),
    );
  }
}

class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الخطوة $current من $total',
              style: const TextStyle(
                color: WalletColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${((current / total) * 100).round()}%',
              style: const TextStyle(
                color: WalletColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: current / total,
            minHeight: 7,
            backgroundColor: WalletColors.border,
            color: WalletColors.blue,
          ),
        ),
      ],
    );
  }
}
