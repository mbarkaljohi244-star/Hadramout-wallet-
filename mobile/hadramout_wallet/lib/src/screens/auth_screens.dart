import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models.dart' show ApiException;
import '../theme.dart';
import '../widgets.dart';
import 'home_screen.dart';
import 'kyc_flow_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _walletIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _walletIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.apiService.login(
        walletId: _walletIdController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomeScreen(apiService: widget.apiService),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WalletScaffold(
      title: 'تسجيل الدخول',
      showBack: false,
      child: ScreenPadding(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Center(child: WalletLogo()),
              const SizedBox(height: 26),
              const SectionHeading(
                title: 'مرحباً بعودتك',
                subtitle: 'سجّل دخولك للوصول إلى محفظتك بأمان.',
              ),
              const SizedBox(height: 26),
              TextFormField(
                controller: _walletIdController,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'رقم المحفظة',
                  hintText: 'HW-000000',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^HW-\d{6}$').hasMatch(value.toUpperCase())) {
                    return 'أدخل رقم محفظة صحيحاً مثل HW-123456';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 15),
                _ErrorText(message: _error!),
              ],
              const SizedBox(height: 26),
              PrimaryAction(
                label: 'دخول آمن',
                onPressed: _login,
                loading: _loading,
                icon: Icons.login_rounded,
              ),
              const SizedBox(height: 22),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    const Text(
                      'ليس لديك حساب؟ ',
                      style: TextStyle(color: WalletColors.muted),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegistrationScreen(
                              apiService: widget.apiService,
                            ),
                          ),
                        );
                      },
                      child: const Text('إنشاء محفظة جديدة'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.apiService, super.key});

  final ApiService apiService;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = await widget.apiService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        pin: _pinController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => KycFlowScreen(
            apiService: widget.apiService,
            session: session,
          ),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تعذر إنشاء المحفظة حالياً');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WalletScaffold(
      title: 'إنشاء محفظة',
      child: ScreenPadding(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                title: 'ابدأ رحلتك المالية',
                subtitle:
                    'أنشئ حساباً آمناً خلال دقائق، ثم أكمل التحقق من هويتك.',
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل (اختياري)',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني (اختياري)',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return 'أدخل بريداً إلكترونياً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  helperText: '8 أحرف على الأقل',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8 || value.length > 128) {
                    return 'يجب أن تكون بين 8 و128 حرفاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'كلمتا المرور غير متطابقتين';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const InfoBanner(
                message:
                    'رقم PIN المكوّن من 6 أرقام يُستخدم لتأكيد التحويلات. لا تشاركه مع أي شخص.',
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'رمز PIN للتحويل',
                  counterText: '',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePin = !_obscurePin),
                    icon: Icon(
                      _obscurePin
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'أدخل 6 أرقام بالضبط';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPinController,
                obscureText: _obscurePin,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'تأكيد رمز PIN',
                  counterText: '',
                  prefixIcon: Icon(Icons.password_rounded),
                ),
                validator: (value) {
                  if (value != _pinController.text) {
                    return 'رمزا PIN غير متطابقين';
                  }
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 15),
                _ErrorText(message: _error!),
              ],
              const SizedBox(height: 22),
              PrimaryAction(
                label: 'إنشاء المحفظة',
                onPressed: _register,
                loading: _loading,
                icon: Icons.arrow_back_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WalletColors.danger.withAlpha(16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: WalletColors.danger,
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
