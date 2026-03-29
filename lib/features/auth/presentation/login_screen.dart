import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sectionGap,
                vertical: AppTheme.sectionGap,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),

                      // ── Logo + Title Center ──────────────────────────
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            boxShadow: AppTheme.elevatedShadow(context),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            child: Image.asset(
                              'assets/images/logo_presentra_p_only.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.screenPadding),
                      Center(
                        child: Text('Presentra', style: AppTheme.displayLarge(context)),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Sistem Presensi Digital',
                          style: AppTheme.bodyMedium(context).copyWith(color: colors.textTertiary),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Form Username ───────────────────────────────
                      Text(
                        'Email',
                        style: AppTheme.labelBold(context).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: AppTheme.chipGap),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan Email',
                        ),
                      ),
                      const SizedBox(height: AppTheme.screenPadding),

                      // ── Form Password ───────────────────────────────
                      Text(
                        'Kata Sandi',
                        style: AppTheme.labelBold(context).copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: AppTheme.chipGap),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: AppTheme.bodyMedium(context).copyWith(color: colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Masukkan Kata Sandi',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                              color: colors.textSecondary,
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                        ),
                      ),

                      // ── Error Message ───────────────────────────────
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppTheme.cardPadding),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(Icons.error, color: AppTheme.danger, size: 16),
                            ),
                            const SizedBox(width: AppTheme.chipGap),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTheme.labelBold(context).copyWith(color: AppTheme.danger),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppTheme.sectionGap),

                      // ── Login Button ────────────────────────────────
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Masuk'),
                        ),
                      ),

                      // Spacer agar teks bantuan selalu di bawah
                      const Spacer(),
                      const SizedBox(height: 48),

                      // ── Footer ──────────────────────────────────────
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Butuh bantuan? ',
                            style: AppTheme.bodyMedium(context).copyWith(fontSize: 13, color: colors.textTertiary),
                            children: [
                              TextSpan(
                                text: 'Hubungi Admin',
                                style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.chipGap),
                      Center(
                        child: Text(
                          'V2.4.0 • IOS',
                          style: AppTheme.bodySmall(context).copyWith(fontSize: 11, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Username dan kata sandi harus diisi');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final user = authProvider.user!;
      Navigator.pushReplacementNamed(context, user.homeRoute);
    } else {
      setState(() => _errorMessage = authProvider.error ?? 'Username atau kata sandi salah');
    }
  }
}