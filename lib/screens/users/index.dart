import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'add_user.dart';
import 'view_users.dart';

@RoutePage()
class UserManagementScreen extends StatefulWidget {
  final bool? isGod;
  const UserManagementScreen({super.key, this.isGod});

  @override
  UserManagementScreenState createState() => UserManagementScreenState();
}

class UserManagementScreenState extends State<UserManagementScreen> {
  final GlobalKey<ViewUsersState> _viewUserKey = GlobalKey<ViewUsersState>();

  void updateUsers() {
    _viewUserKey.currentState?.updateUserList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      floatingActionButton: smallScreen
          ? FloatingActionButton.small(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    // height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(8.0),
                    child: AddUser(updateUserList: updateUsers),
                  ),
                );
              },
              child: Icon(Icons.add_outlined),
            )
          : null,

      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            smallScreen
                ? SizedBox.shrink()
                : Expanded(
                    flex: 1,
                    child: AddUser(
                      updateUserList: updateUsers,
                      isGod: widget.isGod,
                    ),
                  ),
            SizedBox(width: smallScreen ? 0 : 20),
          ],
        ),
      ),
    );
  }
}
