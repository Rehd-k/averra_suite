import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../users/index.dart';
import 'login.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userController;
  final TextEditingController passwordController;
  final Function submit;
  final String? passwordErrorMessage;
  final String? usernameErrorMessage;
  final FocusNode usernameFocus;
  final FocusNode passwordFocus;
  final Function emptyErrorMessage;
  final bool hidePassword;
  final VoidCallback toggleHideShowPassword;
  final bool isLoading;
  final List branches;
  final Function(String) handleAddLocation;
  final bool isGod;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.userController,
    required this.passwordController,
    required this.submit,
    required this.passwordErrorMessage,
    required this.usernameErrorMessage,
    required this.usernameFocus,
    required this.passwordFocus,
    required this.emptyErrorMessage,
    required this.hidePassword,
    required this.toggleHideShowPassword,
    required this.isLoading,
    required this.branches,
    required this.handleAddLocation,
    required this.isGod,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
      child: ListView(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(isGod: true),
                      ),
                    );
                  },
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserManagementScreen(isGod: true),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    height: 100,
                    width: 100,
                    'assets/vectors/logo.svg',
                  ),
                ),
              ),
              SizedBox(height: 100),
              TextFormField(
                onChanged: (value) {
                  emptyErrorMessage();
                },
                focusNode: usernameFocus,
                controller: userController,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline,
                    size: 18,
                    color: Theme.of(context).disabledColor,
                  ),
                  errorText: usernameErrorMessage,
                  labelText: 'Username *',
                  hintText: 'Enter username',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Theme.of(context).hintColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  switch (value) {
                    case null:
                      return 'Please enter your username';
                    case '':
                      return 'Username cannot be empty';
                    default:
                      return null;
                  }
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                onChanged: (value) {
                  emptyErrorMessage();
                },
                focusNode: passwordFocus,
                controller: passwordController,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Theme.of(context).disabledColor,
                    iconSize: 18,
                    onPressed: toggleHideShowPassword,
                    icon: hidePassword
                        ? Icon(Icons.lock_outline)
                        : Icon(Icons.lock_open),
                  ),
                  errorText: passwordErrorMessage,
                  labelText: 'Password *',
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  labelStyle: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 15,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Theme.of(context).hintColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                obscureText: hidePassword,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter your password';
                  } else if (value.isEmpty) {
                    return 'Password cannot be empty';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: branches.map<DropdownMenuItem<String>>((branch) {
                  return DropdownMenuItem<String>(
                    value: branch['name'].toString(),
                    child: Text(branch['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  handleAddLocation(value!);
                },
                validator: (value) {
                  if (isGod == true) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              isLoading
                  ? CircularProgressIndicator.adaptive()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        submit();
                      },
                      child: Text(
                        'Login',
                        style: Theme.of(context).primaryTextTheme.bodySmall,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
