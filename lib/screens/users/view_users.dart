import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../service/api.service.dart';

class ViewUsers extends StatefulWidget {
  final Function()? updateUserList;
  const ViewUsers({super.key, this.updateUserList});

  @override
  ViewUsersState createState() => ViewUsersState();
}

class ViewUsersState extends State<ViewUsers> {
  final apiService = ApiService();
  List filteredUsers = [];
  late List users = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "firstname";
  bool ascending = true;
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    getUsersList();
  }

  // Search logic
  void filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        return user.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateUserList() async {
    setState(() {
      isLoading = true;
    });
    var dbusers = await apiService.get('user?skip=${users.length}');
    setState(() {
      users.addAll(dbusers.data);
      filteredUsers = List.from(users);
      isLoading = false;
    });
  }

  Future getUsersList() async {
    var dbusers = await apiService.get('user');
    setState(() {
      users = dbusers.data;
      getFilteredAndSortedRows();
      isLoading = false;
    });
  }

  getFilteredAndSortedRows() {
    List filtered = users.where((user) {
      return user.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();

    filtered.sort((a, b) {
      if (ascending) {
        return a[sortBy].toString().compareTo(b[sortBy].toString());
      } else {
        return b[sortBy].toString().compareTo(a[sortBy].toString());
      }
    });

    setState(() {
      filteredUsers = filtered;
    });
  }

  sortUsers(String v) {
    List filtered = users
        .where((map) => map["role"].toString().toLowerCase() == v)
        .toList();
    setState(() {
      selectedValue = v;
      filteredUsers = filtered;
    });
  }

  int getColumnIndex(String columnName) {
    switch (columnName) {
      case 'firstName':
        return 0;
      case 'lastname':
        return 1;
      case 'username':
        return 2;
      case 'role':
        return 3;
      case 'initaitor':
        return 4;
      case 'createdAt':
        return 4;
      default:
        return 0;
    }
  }

  Future deleteUser(String id) async {
    await apiService.delete('user/$id');
    setState(() {
      users.removeWhere((bank) => bank['_id'] == id);
      getFilteredAndSortedRows();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        smallScreen ? searchBox(smallScreen) : Container(),
        Expanded(
          child: PaginatedDataTable2(
            fixedCornerColor: Theme.of(context).colorScheme.onSecondary,
            columnSpacing: 12,
            horizontalMargin: 12,
            sortColumnIndex: getColumnIndex(sortBy),
            sortAscending: ascending,
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: (value) {
              setState(() {
                rowsPerPage = value ?? rowsPerPage;
              });
            },
            empty: Text('No Users Yet'),
            minWidth: 1000,
            actions: [
              SizedBox(
                width: 150,
                child: DropdownButton(
                  value: selectedValue,
                  focusColor: Colors.transparent,
                  elevation: 4,
                  hint: Text(
                    'Filter',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  icon: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 5,
                    runSpacing: 5,
                    children: [Icon(Icons.filter_alt_outlined, size: 10)],
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged: (String? v) {
                    sortUsers(v!);
                  },
                ),
              ),
            ],
            header: smallScreen
                // ? SizedBox(
                //     width: 10,
                //     child: FilledButton.icon(
                //       onPressed: () => showBarModalBottomSheet(
                //         expand: true,
                //         context: context,
                //         backgroundColor: Colors.transparent,
                //         builder: (context) =>
                //             AddUser(updateUserList: widget.updateUserList),
                //       ),
                //       label: Text('Add User'),
                //       icon: Icon(Icons.add_box_outlined),
                //     ),
                //   )
                ? SizedBox()
                : Row(children: [searchBox(smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("firstName"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'firstName';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text("lastName"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'lastName';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text("username"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'username';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text("Role"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'role';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text("Initiator"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'initiator';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text('Added On'),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'createdAt';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(label: Text('Branch'), size: ColumnSize.L),
              DataColumn2(label: Text('Actions')),
            ],
            source: UserDataSource(
              users: filteredUsers,
              context: context,
              deleteUser: deleteUser,
            ),
            border: TableBorder(
              horizontalInside: BorderSide.none,
              verticalInside: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  SizedBox searchBox(bool smallScreen) {
    return SizedBox(
      height: 30,
      width: smallScreen ? double.infinity : 250,
      child: TextField(
        style: TextStyle(fontSize: 13),
        cursorHeight: 13,
        controller: _searchController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          hintText: "Search...",
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: InkWell(
            child: Icon(Icons.search),
            onTap: () => filterUsers(_searchController.text),
          ),
        ),
        onChanged: (query) => {filterUsers(query), searchQuery = query},
      ),
    );
  }
}

class UserDataSource extends DataTableSource {
  final List users;
  final BuildContext context;
  final Function deleteUser;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  UserDataSource({
    required this.context,
    required this.users,
    required this.deleteUser,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    return DataRow(
      cells: [
        DataCell(Text(user['firstName'])),
        DataCell(Text(user['lastName'])),
        DataCell(Text(user['username'])),
        DataCell(Text(user['role'])),
        DataCell(Text(formatDate(user['createdAt']))),
        DataCell(Text(user['initiator'])),
        user['location'] == null
            ? DataCell(
                Text('Location Deleted', style: TextStyle(color: Colors.red)),
              )
            : DataCell(Text(user['location']['name'])),
        DataCell(
          PopupMenuButton<int>(
            padding: const EdgeInsets.all(1),
            icon: Icon(
              Icons.more_vert_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(
                      Icons.create_new_folder_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(180),
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "View",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(180),
                      ),
                    ),
                  ],
                ),
                onTap: () => {},
              ),
              user['role'] != "admin"
                  ? PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(180),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => {deleteUser(user['_id'])},
                    )
                  : PopupMenuItem(child: SizedBox()),
            ],
          ),
          //   Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     OutlinedButton(onPressed: () {}, child: Text('Update'))
          //     OutlinedButton(onPressed: () {}, child: Text('Delete'))
          //   ],
          // )
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
