import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../app_router.gr.dart';
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

  showToast(String toastMessage, ToastificationType type) {
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

  handleAddLocation(String location) {
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

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        token = response.data['access_token'];
        String role = response.data['role'];
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
        } else if (role == 'accounting') {
          context.router.replaceAll([
            AccountingNavigationRoute(children: [AccountingDashboardRoute()]),
          ]);
        }

        setState(() {
          loggedIn = true;
        });
      } else {
        if (response.data['statusCode'] == 401) {
          var result = response.data['message'];
          if (result == 'Invalid password') {
            setState(() {
              passwordErrorMessage = result;
              isLoading = false;
            });

            passwordFocus.requestFocus();
          }
          if (result == 'User not found in this location') {
            setState(() {
              usernameErrorMessage = result;
              isLoading = false;
            });

            usernameFocus.requestFocus();
          }
        } else {}
      }
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

  emptyErrorMessage() {
    setState(() {
      passwordErrorMessage = '';
      usernameErrorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isGod == true
          ? AppBar(title: const Text('God Login'))
          : null,
      body: Container(
        color: Theme.of(context).cardColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  flex: constraints.maxWidth > 600 ? 4 : 1,
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
                constraints.maxWidth > 600
                    ? Expanded(
                        flex: 7,
                        child: Image(
                          image: AssetImage('assets/images/banner.png'),
                          fit: BoxFit.fill,
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}
