import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import 'dashboard.dart';


class OdooLoginPage extends StatefulWidget {
  const OdooLoginPage({super.key});
  @override
  State<OdooLoginPage> createState() => _OdooLoginPageState();
}

class _OdooLoginPageState extends State<OdooLoginPage> {
  final _dbCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();


  void initState() {
    super.initState();
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<AuthProvider>().tryAutoLogin(context);
    // });
    Future.microtask(() async {
      await context.read<AuthProvider>().tryAutoLogin(context);
    });
  }


  @override
  Widget build(BuildContext context) {
    //final auth = Provider.of<AuthProvider>(context, listen: false);
    final auth = context.watch<AuthProvider>();
    if (auth.user != null) {
      return const DashboardScreen(); // ✅ no Navigator push, no flash
    }

    // ✅ While checking session / logging in
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Kendroo ERP',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),

                TextField(
                  controller: _dbCtrl,
                  decoration: InputDecoration(
                    labelText: 'Database',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email / Username',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                      try {
                        await auth.login(
                          _dbCtrl.text.trim(),
                          _emailCtrl.text.trim(),
                          _passCtrl.text,
                        );

                        if (!mounted) return;

                        if (auth.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Welcome ${auth.user!.name} (${auth.user!
                                    .companyName})',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          await Future.delayed(
                              const Duration(milliseconds: 800));
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: $e')),
                        );
                      }
                    },
                    child: auth.isLoading
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Log in',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}