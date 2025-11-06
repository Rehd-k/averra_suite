import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';

import '../../components/emptylist.dart';
import '../../components/filter.pill.dart';
import '../../service/api.service.dart';
import 'staff.card.dart';

@RoutePage()
class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

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
  int totalPages = 0;
  int selectedPageNumber = 0;
  String status = '';
  String department = '';
  late List statuses = [
    {'title': 'status'},
    {'title': 'approved'},
    {'title': 'pending'},
  ];

  late List departments = [
    {'title': 'department'},
    {'title': 'HR'},
    {'title': 'Accountant'},
    {'title': 'Admin'},
    {'title': 'Manager'},
    {'title': 'Supervisor'},
  ];

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
    var dbusers = await apiService.get(
      'user?select=" firstName lastName role "',
    );
    setState(() {
      users = dbusers.data;
      getFilteredAndSortedRows();
      isLoading = false;
    });
  }

  void getFilteredAndSortedRows() {
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

  void sortUsers(String v) {
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

  void handlePageChange(int pageNumber) {
    setState(() {
      selectedPageNumber = pageNumber;
    });
  }

  void handleSelectStatus(String value) {
    setState(() {
      status = value;
    });
  }

  void handleSelectDepartment(String value) {
    setState(() {
      department = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Staff Directory'),
        actions: [
          ElevatedButton.icon(
            style: ButtonStyle(),
            onPressed: () {
              // AddUser()
              // context.router.push();
            },
            label: Text('Add New Staff', style: TextStyle(fontSize: 10)),
            icon: Icon(Icons.add, size: 10),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  searchBox(smallScreen),
                  Row(
                    children: [
                      FiltersDropdown(
                        pillIcon: Icons.pending_actions,
                        selected: status,
                        menuList: statuses,
                        doSelect: handleSelectStatus,
                      ),
                      SizedBox(width: 10),
                      FiltersDropdown(
                        pillIcon: Icons.departure_board,
                        selected: department,
                        menuList: departments,
                        doSelect: handleSelectDepartment,
                      ),
                    ],
                  ),
                ],
              ),

              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: EmptyComponent(
                          icon: Icons.receipt_long,
                          message: "No Staff Yet",
                          subMessage:
                              "Start tracking your spending by adding an expense.",
                          reload: () {},
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 60,
                          ), // Add padding for pagination
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Determine how many cards per row based on screen width
                              double maxWidth = constraints.maxWidth;
                              int cardsPerRow;

                              if (maxWidth >= 900) {
                                cardsPerRow = 4; // large screen
                              } else if (maxWidth >= 600) {
                                cardsPerRow = 2; // medium screen
                              } else {
                                cardsPerRow = 1; // small screen
                              }

                              // Card width calculation with spacing
                              double spacing = 5;
                              double cardWidth =
                                  (maxWidth - (spacing * (cardsPerRow - 1))) /
                                  cardsPerRow;

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [...users]
                                    .map(
                                      (res) => SizedBox(
                                        width: cardWidth,
                                        child: Stack(
                                          children: [StaffCard(user: res)],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ),
              ),
            ],
          ),
          // Fixed pagination at bottom
          if (totalPages > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: NumberPagination(
                  onPageChanged: (int pageNumber) {
                    handlePageChange(pageNumber);
                  },
                  fontSize: 10,
                  buttonRadius: 20,
                  buttonElevation: 3,
                  controlButtonColor: Theme.of(context).colorScheme.primary,
                  unSelectedButtonColor: Theme.of(context).colorScheme.primary,
                  selectedButtonColor: Theme.of(context).cardColor,
                  controlButtonSize: Size(20, 20),
                  numberButtonSize: const Size(20, 20),
                  visiblePagesCount: smallScreen ? 5 : 15,
                  totalPages: totalPages,
                  currentPage: selectedPageNumber,
                  enableInteraction: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SizedBox searchBox(bool smallScreen) {
    return SizedBox(
      height: 30,
      width: smallScreen ? 100 : 250,
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
        DataCell(Text(capitalizeFirstLetter(user['firstName']))),
        DataCell(Text(capitalizeFirstLetter(user['lastName']))),
        DataCell(Text(capitalizeFirstLetter(user['username']))),
        DataCell(Text(capitalizeFirstLetter(user['role']))),
        DataCell(Text(formatDate(user['createdAt']))),
        DataCell(Text(capitalizeFirstLetter(user['initiator']))),
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
