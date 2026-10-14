import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/fake_api.dart';
import '../models/auth_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Ефемерний стан форми - у State / setState.
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  static final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Введіть email';
    if (!_emailRegExp.hasMatch(v)) return 'Невірний формат email';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Введіть пароль';
    if (v.length < 8) return 'Пароль має бути від 8 символів';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // read - у колбеку: лише викликаємо метод, підписка не потрібна.
    context.read<AuthModel>().login(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build: LoginScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Показати пароль' : 'Сховати пароль',
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 12),
                  const _ErrorText(),
                  const SizedBox(height: 12),
                  _SubmitButton(onPressed: _submit),
                  const SizedBox(height: 24),
                  Text(
                    'Тестовий акаунт:\n'
                    '${FakeApi.testEmail} / ${FakeApi.testPassword}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selector: підписка лише на текст помилки.
class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    return Selector<AuthModel, String?>(
      selector: (_, auth) => auth.error,
      builder: (context, error, _) {
        debugPrint('build: ErrorText');
        if (error == null) return const SizedBox.shrink();
        return Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        );
      },
    );
  }
}

/// select: підписка лише на isLoading.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    debugPrint('build: SubmitButton');
    final isLoading = context.select<AuthModel, bool>((m) => m.isLoading);
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Увійти'),
    );
  }
}
