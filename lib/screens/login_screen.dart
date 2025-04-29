import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../auth/auth_provider.dart' as my_auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/language_selection_dialog.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    final auth = context.read<my_auth.AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    try {
      if (_isRegisterMode) {
        await auth.registerWithEmail(email, password, name);
      } else {
        await auth.signInWithEmail(email, password);
      }
      context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = tr('invalid_email'));
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _error = null;
        _successMessage = tr('password_reset_sent'); // ודא שמפתח זה קיים בקובץ התרגום
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLanguageChosen();
  }

  Future<void> _checkLanguageChosen() async {
    final prefs = await SharedPreferences.getInstance();
    bool languageChosen = prefs.getBool('language_chosen') ?? false;
    if (!languageChosen) {
      // נעכב את ההצגה עד לסיום הבנייה הקצרה של המסך
      Future.delayed(Duration.zero, () async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const LanguageSelectionDialog(),
        );
        // סומנים שהמשתמש בחר שפה
        await prefs.setBool('language_chosen', true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<my_auth.AuthProvider>();

    if (auth.user != null) {
      Future.microtask(() => context.go('/home'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr('login_title'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                _isRegisterMode ? tr('register') : tr('sign_in'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (_isRegisterMode)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: tr('enter_name')),
                  validator: (value) =>
                  value == null || value.isEmpty ? tr('required_field') : null,
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: tr('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                value != null && value.contains('@') ? null : tr('invalid_email'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: tr('password')),
                obscureText: true,
                validator: (value) =>
                value != null && value.length >= 6 ? null : tr('password_too_short'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: Text(tr('forgot_password')),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: Text(_isRegisterMode ? tr('register') : tr('sign_in')),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                    _error = null;
                    _successMessage = null;
                  });
                },
                child: Text(_isRegisterMode
                    ? tr('have_account_sign_in')
                    : tr('no_account_register')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
