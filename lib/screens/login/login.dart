import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import '../../app_router.gr.dart';
// import '../../helpers/notification.token.dart';
import '../../components/theme_switch_button.dart';
import '../../helpers/title_bar.dart';
import '../../service/api.service.dart';
import '../../service/token.service.dart';
import 'form.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  final Function()? onResult;
  final bool? isGod;
  const LoginScreen({super.key, this.onResult, this.isGod});

  @override
  State<LoginScreen> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final service = NotificationService();

  late String token;
  late FocusNode usernameFocus;
  late FocusNode passwordFocus;
  late String passwordErrorMessage = '';
  late String usernameErrorMessage = '';
  late String locations = '';
  bool hidePassword = true;
  bool isLoading = false;
  late List branches = [];
  final ApiService apiServices = ApiService();
  bool loggedIn = false;
  bool showForm = false;

  @override
  void initState() {
    super.initState();
    getSettingnsAndBranch();
    usernameFocus = FocusNode();
    passwordFocus = FocusNode();

    if (Platform.isWindows) {
      // setupWindowsNotifications();
    }
  }

  @override
  void dispose() {
    usernameFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void getSettingnsAndBranch() async {
    var responce = await apiServices.get('location');
    setState(() {
      branches = responce.data;
      showForm = true;
    });
  }

  void showToast(String toastMessage, ToastificationType type) {
    toastification.show(
      title: Text(toastMessage),
      type: type,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  void toggleHideShowPassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await handleSubmit();
    }
  }

  void handleAddLocation(String location) {
    setState(() {
      locations = location;
    });
  }

  Future<void> handleSubmit() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiServices.post('auth/login', {
        'username': _userController.text,
        'password': _passwordController.text,
        'location': widget.isGod == true ? 'all' : locations,
      });

      token = response.data['access_token'];
      String role = response.data['role'];
      String id = response.data['sub'];
      debugPrint(response.data.toString());
      // String? fcmToken = await service.getToken();
      // debugPrint('FCM Token: $fcmToken');
      // if (fcmToken != null) {
      //   await service.registerToken(fcmToken, id); // From auth
      // }
      // service.handleMessages();
      if (!mounted) return;

      JwtService().setToken = token;
      if (role == 'god' || role == 'admin') {
        context.router.replaceAll([
          const AdminNavigation(children: [AdminDashbaord()]),
        ]);
      } else if (role == 'waiter') {
        context.router.replaceAll([
          WaiterNavigationRoute(children: [MakeSaleRoute()]),
        ]);
      } else if (role == 'bar') {
        context.router.replaceAll([
          BarNavigationRoute(children: [DepartmentRequest()]),
        ]);
      } else if (role == 'supervisor') {
        context.router.replaceAll([
          SuperviorNavigationRoute(children: [DashbaordSuperviorRoute()]),
        ]);
      } else if (role == 'manager') {
        context.router.replaceAll([
          ManagerNavigationRoute(children: [DashbaordManagerRoute()]),
        ]);
      } else if (role == 'accountant') {
        context.router.replaceAll([
          AccountingNavigationRoute(children: [AccountingDashboardRoute()]),
        ]);
      } else if (role == 'chef') {
        context.router.replaceAll([
          KitchenNavigationRoute(children: [CartRoute()]),
        ]);
      }

      setState(() {
        loggedIn = true;
      });
      // } else {
      //   if (response.data['statusCode'] == 401) {
      //     var result = response.data['message'];
      //     if (result == 'Invalid password') {
      //       setState(() {
      //         passwordErrorMessage = result;
      //         isLoading = false;
      //       });

      //       passwordFocus.requestFocus();
      //     }
      //     if (result == 'User not found in this location') {
      //       setState(() {
      //         usernameErrorMessage = result;
      //         isLoading = false;
      //       });

      //       usernameFocus.requestFocus();
      //     }
      //   } else {}
      // }
    } on DioException catch (e, _) {
      if (e.type == DioExceptionType.connectionError) {
        setState(() {
          isLoading = false;
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void emptyErrorMessage() {
    setState(() {
      passwordErrorMessage = '';
      usernameErrorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: widget.isGod == true
          ? AppBar(title: const Text('God Login'))
          : null,
      body: Column(
        children: [
          if (Platform.isWindows)
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(child: MoveWindow(child: Text('Log In'))),
                  const CircleAvatar(child: Icon(Icons.person_outlined)),
                  const ThemeSwitchButton(),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined, size: 12),
                    onPressed: () {
                      JwtService().logout();
                      context.router.replaceAll([LoginRoute()]);
                    },
                  ),
                  const WindowButtons(),
                ],
              ),
            ),

          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 🖼️ Background image
                Image.asset(
                  'assets/images/banner.png', // <-- put your image in assets folder
                  fit: BoxFit.cover,
                ),

                // 🌫️ Blur filter
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.3,
                    ), // optional dark overlay
                  ),
                ),

                // 🪟 Foreground login card
                Center(
                  child: SizedBox(
                    width: isSmallScreen ? double.infinity : 400,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: !showForm
                            ? const Center(child: CircularProgressIndicator())
                            : LoginForm(
                                formKey: _formKey,
                                userController: _userController,
                                passwordController: _passwordController,
                                submit: _submit,
                                passwordErrorMessage: passwordErrorMessage,
                                usernameErrorMessage: usernameErrorMessage,
                                usernameFocus: usernameFocus,
                                passwordFocus: passwordFocus,
                                emptyErrorMessage: emptyErrorMessage,
                                hidePassword: hidePassword,
                                toggleHideShowPassword: toggleHideShowPassword,
                                isLoading: isLoading,
                                branches: branches,
                                handleAddLocation: handleAddLocation,
                                isGod: widget.isGod ?? false,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:

//     );
//   }
// }
