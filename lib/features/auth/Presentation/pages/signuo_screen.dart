import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_bloc.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_event.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // أزرق غامق (ليل)
              Color(0xFF3F51B5), // أزرق فاتح
            ],
            stops: [0.2, 0.8],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة سيارة مع تأثيرات
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    transform: Matrix4.translationValues(0, -20, 0),
                    child: const Icon(
                      Icons.directions_car,
                      size: 90,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // العنوان مع تأثير ظل
                  const Text(
                    'مواقف السيارات',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  // نص فرعي
                  const Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // بطاقة التسجيل بتأثيرات متقدمة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(0, 0, 0),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // حقل البريد الإلكتروني
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(
                                      errorText: 'البريد الإلكتروني مطلوب'),
                                  FormBuilderValidators.email(
                                      errorText: 'البريد الإلكتروني غير صالح'),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // حقل كلمة المرور
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'كلمة المرور مطلوبة';
                                  }
                                  if (value.length < 8) {
                                    return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 25),

                            // حقل تأكيد كلمة المرور
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
                                  labelStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.lock_reset,
                                      color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'تأكيد كلمة المرور مطلوب';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمتا المرور غير متطابقتين';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),

                            // زر إنشاء الحساب بتأثيرات متقدمة
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1A237E),
                                      Color(0xFF3F51B5),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.indigo.shade600,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      context.read<AuthBloc>().add(
                                            SignupEvent(
                                              email: _emailController.text,
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      if (state is AuthLoading || _isLoading) {
                                        return const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        );
                                      }
                                      return const Text(
                                        'إنشاء حساب',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // رابط تسجيل الدخول
                            TextButton(
                              onPressed: () {
                                // التحويل إلى صفحة الدخول
                                Navigator.pushReplacementNamed(
                                    context, AppRouter.login);
                              },
                              child: const Text(
                                'لديك حساب؟ تسجيل الدخول',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // معالج الحالة
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        setState(() {
                          _isLoading = false;
                        });

                        // التعديل هنا: الانتقال مباشرة إلى الصفحة الرئيسية
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.home,
                          (route) => false, // إزالة جميع الشاشات من المكدس
                        );
                      }
                      if (state is AuthFailure) {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(20),
                          ),
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
