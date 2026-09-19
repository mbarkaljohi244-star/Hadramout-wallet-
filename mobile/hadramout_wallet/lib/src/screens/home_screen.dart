import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'kyc_flow_screen.dart';
import 'auth_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _currency = 'YER';
  bool _sending = false;
  String? _transferError;
  TransferResult? _lastTransfer;

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _sendTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _transferError = null;
      _lastTransfer = null;
    });

    try {
      final transfer = await widget.apiService.transfer(
        receiverWalletId: _receiverController.text,
        amount: double.parse(_amountController.text),
        currency: _currency,
        pin: _pinController.text,
      );
      if (mounted) {
        setState(() => _lastTransfer = transfer);
        _receiverController.clear();
        _amountController.clear();
        _pinController.clear();
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _transferError = error.message);
    } catch (_) {
      if (mounted) setState(() => _transferError = 'تعذر تنفيذ التحويل حالياً');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _logout() async {
    await widget.apiService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(apiService: widget.apiService),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.apiService.session;
    final walletId = session?.walletId ?? 'HW-000000';
    return WalletScaffold(
      title: 'محفظتي',
      showBack: false,
      action: IconButton(
        onPressed: _logout,
        tooltip: 'تسجيل الخروج',
        icon: const Icon(Icons.logout_rounded),
      ),
      child: ScreenPadding(
        bottom: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeCard(walletId: walletId),
            const SizedBox(height: 18),
            const Text(
              'الخدمات السريعة',
              style: TextStyle(
                color: WalletColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _KycCard(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => KycFlowScreen(
                      apiService: widget.apiService,
                      session: session!,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            _TransferCard(
              formKey: _formKey,
              receiverController: _receiverController,
              amountController: _amountController,
              pinController: _pinController,
              currency: _currency,
              sending: _sending,
              error: _transferError,
              result: _lastTransfer,
              onCurrencyChanged: (value) {
                if (value != null) setState(() => _currency = value);
              },
              onSubmit: _sendTransfer,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [WalletColors.navy, WalletColors.blue],
        ),
        boxShadow: [
          BoxShadow(
            color: WalletColors.blue.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الرصيد الإجمالي',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withAlpha(210),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '0.00 ر.ي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              walletId,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycCard extends StatelessWidget {
  const _KycCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WalletColors.paleBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: WalletColors.blue,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وثّق هويتك',
                      style: TextStyle(
                        color: WalletColors.ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'أكمل 11 خطوة لفتح جميع الميزات',
                      style: TextStyle(
                        color: WalletColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferCard extends StatelessWidget {
  const _TransferCard({
    required this.formKey,
    required this.receiverController,
    required this.amountController,
    required this.pinController,
    required this.currency,
    required this.sending,
    required this.error,
    required this.result,
    required this.onCurrencyChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController receiverController;
  final TextEditingController amountController;
  final TextEditingController pinController;
  final String currency;
  final bool sending;
  final String? error;
  final TransferResult? result;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalletColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تحويل أموال',
              style: TextStyle(
                color: WalletColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'أرسل بأمان إلى أي محفظة حضرموت.',
              style: TextStyle(color: WalletColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: receiverController,
              textDirection: TextDirection.ltr,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'محفظة المستلم',
                hintText: 'HW-000000',
                prefixIcon: Icon(Icons.person_pin_circle_outlined),
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^HW-\d{6}$').hasMatch(value.toUpperCase())) {
                  return 'أدخل رقم محفظة صحيحاً';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(value ?? '');
                      if (amount == null || amount <= 0) return 'مبلغ غير صحيح';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: currency,
                    decoration: const InputDecoration(labelText: 'العملة'),
                    items: const [
                      DropdownMenuItem(value: 'YER', child: Text('ر.ي')),
                      DropdownMenuItem(value: 'SAR', child: Text('ر.س')),
                      DropdownMenuItem(value: 'USD', child: Text('دولار')),
                      DropdownMenuItem(value: 'USDT', child: Text('USDT')),
                    ],
                    onChanged: onCurrencyChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(
                labelText: 'PIN التحويل (اختياري مع تسجيل الدخول)',
                prefixIcon: Icon(Icons.pin_outlined),
                counterText: '',
              ),
              validator: (value) {
                if (value != null &&
                    value.isNotEmpty &&
                    !RegExp(r'^\d{6}$').hasMatch(value)) {
                  return 'أدخل 6 أرقام';
                }
                return null;
              },
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                error!,
                style:
                    const TextStyle(color: WalletColors.danger, fontSize: 13),
              ),
            ],
            if (result != null) ...[
              const SizedBox(height: 12),
              Text(
                'تم التحويل بنجاح. الرصيد المتبقي: ${result!.senderBalance} ${result!.currency}',
                style:
                    const TextStyle(color: WalletColors.success, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryAction(
              label: 'تنفيذ التحويل',
              onPressed: onSubmit,
              loading: sending,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
