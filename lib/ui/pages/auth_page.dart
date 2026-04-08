import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  static const Color bg = Color(0xFFEEF1F7);
  static const Color panel = Color(0xFFFFFFFF);

  bool isRegister = false;
  final ValueNotifier<Offset?> hoverPointNotifier = ValueNotifier<Offset?>(
    null,
  );

  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerKey = GlobalKey<FormState>();

  final TextEditingController _loginEmail = TextEditingController();
  final TextEditingController _loginPassword = TextEditingController();
  final TextEditingController _regName = TextEditingController();
  final TextEditingController _regEmail = TextEditingController();
  final TextEditingController _regPassword = TextEditingController();

  final FocusNode _loginEmailFocus = FocusNode();
  final FocusNode _registerNameFocus = FocusNode();

  bool _showLoginPassword = false;
  bool _showRegisterPassword = false;

  final List<_ToastData> _toasts = <_ToastData>[];

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusInitial();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _loginEmailFocus.dispose();
    _registerNameFocus.dispose();
    hoverPointNotifier.dispose();
    super.dispose();
  }

  void _focusInitial() {
    if (isRegister) {
      _registerNameFocus.requestFocus();
    } else {
      _loginEmailFocus.requestFocus();
    }
  }

  void _switchTab(bool register) {
    setState(() {
      isRegister = register;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusInitial();
    });
  }

  void _showToast(String message, {bool success = true}) {
    final toast = _ToastData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: message,
      success: success,
    );

    setState(() {
      _toasts.add(toast);
    });

    Timer(const Duration(milliseconds: 4200), () {
      if (!mounted) return;
      setState(() {
        _toasts.removeWhere((e) => e.id == toast.id);
      });
    });
  }

  Future<void> _submitLogin() async {
    final form = _loginKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      _showToast('Periksa kembali data login.', success: false);
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.login(
      _loginEmail.text.trim(),
      _loginPassword.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      _showToast(provider.errorMessage ?? 'Login Gagal', success: false);
    }
  }

  Future<void> _submitRegister() async {
    final form = _registerKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      _showToast('Periksa kembali data pendaftaran.', success: false);
      return;
    }

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.register(
      _regEmail.text.trim(),
      _regPassword.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      _showToast(provider.errorMessage ?? 'Register Gagal', success: false);
    }
  }

  Matrix4 _frameTransform(Offset? point) {
    if (point == null) return Matrix4.identity();

    final dx = (point.dx - 0.5);
    final dy = (point.dy - 0.5);
    final rx = dy * -0.07;
    final ry = dx * 0.10;

    return Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(rx)
      ..rotateY(ry);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
            const _ToggleTabIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true):
            const _ToggleTabIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
            const _ToggleTabIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowRight, meta: true):
            const _ToggleTabIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ToggleTabIntent: CallbackAction<_ToggleTabIntent>(
            onInvoke: (_) {
              _switchTab(!isRegister);
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: bg,
          body: AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final drift = math.sin(_bgController.value * math.pi * 2);
              final centerX = 0.5 + drift * 0.02;
              final centerY =
                  -0.35 + math.cos(_bgController.value * math.pi * 2) * 0.02;

              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(centerX * 2 - 1, centerY * 2 - 1),
                    radius: 1.15,
                    colors: const <Color>[
                      Color(0xFFE9EEF7),
                      Color(0xFFFDFDFD),
                      bg,
                    ],
                    stops: const <double>[0.0, 0.55, 1.0],
                  ),
                ),
                child: child,
              );
            },
            child: SafeArea(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final isCompact = width <= 900;
                    final frameWidth = isCompact
                        ? math.min(width, 720.0)
                        : math.min(width * 0.94, 1000.0);

                    if (isCompact) {
                      return _buildCompactFrame(frameWidth);
                    }

                    return MouseRegion(
                      onHover: (event) {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box == null) return;
                        final local = box.globalToLocal(event.position);
                        final x = (local.dx / box.size.width).clamp(0.0, 1.0);
                        final y = (local.dy / box.size.height).clamp(0.0, 1.0);
                        hoverPointNotifier.value = Offset(x, y);
                      },
                      onExit: (_) {
                        hoverPointNotifier.value = null;
                      },
                      child: ValueListenableBuilder<Offset?>(
                        valueListenable: hoverPointNotifier,
                        builder: (context, hoverPointValue, child) {
                          final bool hoverFrame = hoverPointValue != null;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeOut,
                            width: frameWidth,
                            height: 560,
                            transform: _frameTransform(hoverPointValue),
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: hoverFrame
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 60,
                                        offset: const Offset(0, 20),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : <BoxShadow>[
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 50,
                                        offset: const Offset(0, 16),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.10,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: child,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(child: Container(color: panel)),
                              Positioned.fill(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: isRegister ? 1.0 : 0.0,
                                    end: isRegister ? 1.0 : 0.0,
                                  ),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, t, child) {
                                    return ClipPath(
                                      clipper: _WedgeClipper(t: t),
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    color: const Color(0xFF0A0A0A),
                                    child: ValueListenableBuilder<Offset?>(
                                      valueListenable: hoverPointNotifier,
                                      builder: (context, val, _) {
                                        final hp =
                                            val ?? const Offset(0.5, 0.5);
                                        return CustomPaint(
                                          painter: _WedgeSheenPainter(
                                            activeX:
                                                0.60 + (hp.dx - 0.5) * 0.18,
                                            activeY:
                                                0.10 + (hp.dy - 0.5) * 0.24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              if (_toasts.isNotEmpty)
                                Positioned(
                                  top: 40,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    ignoring: false,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: _toasts
                                          .map(
                                            (t) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: _ToastWidget(
                                                data: t,
                                                onClose: () {
                                                  setState(() {
                                                    _toasts.removeWhere(
                                                      (e) => e.id == t.id,
                                                    );
                                                  });
                                                },
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),

                              Positioned.fill(child: _buildDesktopCopy()),

                              Positioned.fill(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _buildPane(
                                        isLeft: true,
                                        isVisible: !isRegister,
                                        title: 'Login',
                                        underlineWidth: 70,
                                        cardWidth: 520,
                                        topLift: -20,
                                        formKey: _loginKey,
                                        children: <Widget>[
                                          _AuthField(
                                            label: 'Email',
                                            controller: _loginEmail,
                                            focusNode: _loginEmailFocus,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            prefixIcon: Icons.mail_outline,
                                            validator: (value) {
                                              final v = (value ?? '').trim();
                                              if (v.isEmpty) {
                                                return 'Email wajib diisi';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Email tidak valid';
                                              }
                                              return null;
                                            },
                                          ),
                                          _AuthField(
                                            label: 'Password',
                                            controller: _loginPassword,
                                            obscureText: !_showLoginPassword,
                                            textInputAction:
                                                TextInputAction.done,
                                            prefixIcon:
                                                Icons.remove_red_eye_outlined,
                                            validator: (value) {
                                              final v = (value ?? '');
                                              if (v.isEmpty) {
                                                return 'Password wajib diisi';
                                              }
                                              return null;
                                            },
                                            suffixWidget: _PasswordToggleIcon(
                                              shown: _showLoginPassword,
                                              onTap: () {
                                                setState(() {
                                                  _showLoginPassword =
                                                      !_showLoginPassword;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: _BlackButton(
                                              label: 'Login',
                                              onPressed: _submitLogin,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _AuthTabs(
                                            text: "Don't have an account?",
                                            linkLabel: 'Sign Up',
                                            onTap: () => _switchTab(true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildPane(
                                        isLeft: false,
                                        isVisible: isRegister,
                                        title: 'Sign Up',
                                        underlineWidth: 70,
                                        cardWidth: 520,
                                        topLift: 0,
                                        formKey: _registerKey,
                                        children: <Widget>[
                                          _AuthField(
                                            label: 'Username',
                                            controller: _regName,
                                            focusNode: _registerNameFocus,
                                            keyboardType: TextInputType.text,
                                            textInputAction:
                                                TextInputAction.next,
                                            prefixIcon: Icons.person_outline,
                                            validator: (value) {
                                              if ((value ?? '')
                                                  .trim()
                                                  .isEmpty) {
                                                return 'Username wajib diisi';
                                              }
                                              return null;
                                            },
                                          ),
                                          _AuthField(
                                            label: 'Email',
                                            controller: _regEmail,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            prefixIcon: Icons.mail_outline,
                                            validator: (value) {
                                              final v = (value ?? '').trim();
                                              if (v.isEmpty) {
                                                return 'Email wajib diisi';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Email tidak valid';
                                              }
                                              return null;
                                            },
                                          ),
                                          _AuthField(
                                            label: 'Password',
                                            controller: _regPassword,
                                            obscureText: !_showRegisterPassword,
                                            textInputAction:
                                                TextInputAction.done,
                                            prefixIcon:
                                                Icons.remove_red_eye_outlined,
                                            validator: (value) {
                                              final v = (value ?? '');
                                              if (v.isEmpty) {
                                                return 'Password wajib diisi';
                                              }
                                              if (v.isEmpty) {
                                                return 'Password tidak valid';
                                              }
                                              return null;
                                            },
                                            suffixWidget: _PasswordToggleIcon(
                                              shown: _showRegisterPassword,
                                              onTap: () {
                                                setState(() {
                                                  _showRegisterPassword =
                                                      !_showRegisterPassword;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          SizedBox(
                                            width: double.infinity,
                                            child: _BlackButton(
                                              label: 'Sign Up',
                                              onPressed: _submitRegister,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _AuthTabs(
                                            text: 'Already have an account?',
                                            linkLabel: 'Login',
                                            onTap: () => _switchTab(false),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFrame(double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      width: width,
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: Container(color: panel)),
            if (_toasts.isNotEmpty)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _toasts
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ToastWidget(
                            data: t,
                            onClose: () {
                              setState(() {
                                _toasts.removeWhere((e) => e.id == t.id);
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _CompactPane(
                    title: 'Login',
                    formKey: _loginKey,
                    children: <Widget>[
                      _AuthField(
                        label: 'Email',
                        controller: _loginEmail,
                        focusNode: _loginEmailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_outline,
                        validator: (value) {
                          final v = (value ?? '').trim();
                          if (v.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      _AuthField(
                        label: 'Password',
                        controller: _loginPassword,
                        obscureText: !_showLoginPassword,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.remove_red_eye_outlined,
                        validator: (value) {
                          final v = (value ?? '');
                          if (v.isEmpty) return 'Password wajib diisi';
                          return null;
                        },
                        suffixWidget: _PasswordToggleIcon(
                          shown: _showLoginPassword,
                          onTap: () {
                            setState(() {
                              _showLoginPassword = !_showLoginPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: _BlackButton(
                          label: 'Login',
                          onPressed: _submitLogin,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AuthTabs(
                        text: "Don't have an account?",
                        linkLabel: 'Sign Up',
                        onTap: () => _switchTab(true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _CompactPane(
                    title: 'Sign Up',
                    formKey: _registerKey,
                    children: <Widget>[
                      _AuthField(
                        label: 'Username',
                        controller: _regName,
                        focusNode: _registerNameFocus,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Username wajib diisi';
                          }
                          return null;
                        },
                      ),
                      _AuthField(
                        label: 'Email',
                        controller: _regEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.mail_outline,
                        validator: (value) {
                          final v = (value ?? '').trim();
                          if (v.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@')) return 'Email tidak valid';
                          return null;
                        },
                      ),
                      _AuthField(
                        label: 'Password',
                        controller: _regPassword,
                        obscureText: !_showRegisterPassword,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.remove_red_eye_outlined,
                        validator: (value) {
                          final v = (value ?? '');
                          if (v.isEmpty) return 'Password wajib diisi';
                          return null;
                        },
                        suffixWidget: _PasswordToggleIcon(
                          shown: _showRegisterPassword,
                          onTap: () {
                            setState(() {
                              _showRegisterPassword = !_showRegisterPassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: _BlackButton(
                          label: 'Sign Up',
                          onPressed: _submitRegister,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AuthTabs(
                        text: 'Already have an account?',
                        linkLabel: 'Login',
                        onTap: () => _switchTab(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCopy() {
    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isRegister ? 1 : 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    offset: isRegister
                        ? const Offset(-0.02, 0)
                        : const Offset(-0.06, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: SizedBox(
                          width: 340,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'WELCOME\nBACK!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 46,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Buat akun untuk mulai menggunakan dashboard.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _OverlayButton(
                                label: 'Login',
                                onTap: () => _switchTab(false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: isRegister ? 0 : 1,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    offset: !isRegister
                        ? const Offset(0.02, 0)
                        : const Offset(0.06, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: SizedBox(
                          width: 340,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'WELCOME\nBACK!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 46,
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Masuk untuk mengelola sistem parkir.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _OverlayButton(
                                label: 'Sign Up',
                                onTap: () => _switchTab(true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPane({
    required bool isLeft,
    required bool isVisible,
    required String title,
    required double underlineWidth,
    required double cardWidth,
    required double topLift,
    required GlobalKey<FormState> formKey,
    required List<Widget> children,
  }) {
    final offsetX = isLeft ? -0.28 : 0.28;
    final hiddenOpacity = 0.0;
    final visibleOpacity = 1.0;

    final card = Container(
      width: cardWidth,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: underlineWidth,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      ),
    );

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 450),
        opacity: isVisible ? visibleOpacity : hiddenOpacity,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          offset: isVisible ? Offset.zero : Offset(offsetX, 0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 600),
            scale: isVisible ? 1.0 : 0.98,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(36),
              child: Transform.translate(
                offset: Offset(0, topLift),
                child: card,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactPane extends StatelessWidget {
  const _CompactPane({
    required this.title,
    required this.formKey,
    required this.children,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.validator,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixWidget,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixWidget;
  final String? Function(String?) validator;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _focused ? const Color(0xFFF7F8FB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Focus(
          onFocusChange: (value) {
            if (mounted) {
              setState(() {
                _focused = value;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                validator: widget.validator,
                style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(
                    left: 4,
                    right: 42,
                    top: 12,
                    bottom: 12,
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD1D5DB), width: 2),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD1D5DB), width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF111111), width: 2),
                  ),
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  suffixIcon:
                      widget.suffixWidget ??
                      Icon(
                        widget.prefixIcon ?? Icons.circle_outlined,
                        size: 18,
                        color: const Color(0xFF0F172A).withValues(alpha: 0.55),
                      ),
                  suffixIconConstraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordToggleIcon extends StatelessWidget {
  const _PasswordToggleIcon({required this.shown, required this.onTap});

  final bool shown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          shown ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs({
    required this.text,
    required this.linkLabel,
    required this.onTap,
  });

  final String text;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            linkLabel,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BlackButton extends StatelessWidget {
  const _BlackButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final isLoading = auth.isLoading;
        return Material(
          color: const Color(0xFF0B0B0B),
          borderRadius: BorderRadius.circular(999),
          elevation: 0,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.transparent,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastData {
  _ToastData({required this.id, required this.message, required this.success});

  final String id;
  final String message;
  final bool success;
}

class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.data, required this.onClose});

  final _ToastData data;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final bgColor = data.success
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFEF2F2);
    final borderColor = data.success
        ? const Color(0xFF86EFAC)
        : const Color(0xFFFCA5A5);
    final textColor = data.success
        ? const Color(0xFF065F46)
        : const Color(0xFF7F1D1D);
    final icon = data.success ? '✅' : '⚠️';

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520, minWidth: 260),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(icon),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  data.message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    '×',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WedgeClipper extends CustomClipper<Path> {
  const _WedgeClipper({required this.t});
  final double t;

  @override
  Path getClip(Size size) {
    final tlx = (1 - t) * 0.65 + t * 0.0;
    final blx = (1 - t) * 0.40 + t * 0.0;

    final trx = (1 - t) * 1.0 + t * 0.34;
    final brx = (1 - t) * 1.0 + t * 0.55;

    final path = Path()
      ..moveTo(size.width * tlx, 0)
      ..lineTo(size.width * trx, 0)
      ..lineTo(size.width * brx, size.height)
      ..lineTo(size.width * blx, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _WedgeClipper oldClipper) {
    return oldClipper.t != t;
  }
}

class _WedgeSheenPainter extends CustomPainter {
  const _WedgeSheenPainter({required this.activeX, required this.activeY});

  final double activeX;
  final double activeY;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * activeX, size.height * activeY),
        math.max(size.width, size.height) * 0.34,
        <Color>[Colors.white.withValues(alpha: 0.12), Colors.transparent],
        const <double>[0.0, 1.0],
      );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _WedgeSheenPainter oldDelegate) {
    return oldDelegate.activeX != activeX || oldDelegate.activeY != activeY;
  }
}

class _ToggleTabIntent extends Intent {
  const _ToggleTabIntent();
}
