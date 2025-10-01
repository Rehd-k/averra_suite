import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/app_router.gr.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/date_range_helper.dart';
import 'package:averra_suite/service/token.service.dart';
import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';
import '../../components/datepill.dart';
import '../../components/emptylist.dart';
import '../../components/filter.pill.dart';
import '../../components/smallinfo.card.dart';

import '../../service/api.service.dart';
import 'add_expneses.dart';

@RoutePage()
class ViewExpenses extends StatefulWidget {
  final Function()? updateExpense;
  const ViewExpenses({super.key, this.updateExpense});

  @override
  ViewExpensesState createState() => ViewExpensesState();
}

class ViewExpensesState extends State<ViewExpenses> {
  final apiService = ApiService();
  List filteredExpenses = [];
  late List expenses = [];
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int selectedPageNumber = 1;
  String searchQuery = "";
  String sortBy = "name";
  int totalPages = 0;
  bool ascending = true;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  DateTime selectedDate = DateTime.now();
  late List categories = [
    {'title': 'All'},
  ];
  late List statuses = [
    {'title': 'status'},
    {'title': 'approved'},
    {'title': 'pending'},
  ];
  String category = 'category';
  String status = 'status';
  handleRangeChange(String select, DateTime picked) async {
    if (select == 'from') {
      setState(() {
        startDate = picked;
        expenses = [];
      });
    } else if (select == 'to') {
      setState(() {
        endDate = picked;
        expenses = [];
      });
    }
    getExpenses();
  }

  handleDateReset() {
    setState(() {
      startDate = DateTime.now();
      endDate = DateTime.now();
    });
    getExpenses();
  }

  getCategories() async {
    var result = await apiService.get('expense/category');
    setState(() {
      categories.addAll(result.data);
    });
  }

  getExpenses() async {
    var statusBool = status == 'approved'
        ? true
        : status == 'pending'
        ? false
        : '';

    var dbexpenses = await apiService.get(
      'expense?filter={"approved" : "$statusBool", "category" : "$category"}&startDate=$startDate&endDate=$endDate&skip=${selectedPageNumber == 1 ? 0 * 10 : (selectedPageNumber - 1) * 10}&sort={"date" : "asc"}',
    );
    setState(() {
      totalPages = getPageGroup(dbexpenses.data['expensesCount']);
      expenses = dbexpenses.data['expense'];
    });
  }

  int getPageGroup(int totalPages) {
    if (totalPages <= 0) return 1; // safeguard
    return ((totalPages - 1) ~/ 10) + 1;
  }

  void filterProducts(String query) {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        return expense.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future getExpensesList() async {
    var dbexpenses = await apiService.get('expense');
    setState(() {
      expenses = dbexpenses.data;
      filteredExpenses = List.from(expenses);
      isLoading = false;
    });
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = expenses.where((product) {
      return product.values.any(
        (value) =>
            value.toString().toLowerCase().contains(searchQuery.toLowerCase()),
      );
    }).toList();

    filteredCategories.sort((a, b) {
      if (ascending) {
        return a[sortBy].toString().compareTo(b[sortBy].toString());
      } else {
        return b[sortBy].toString().compareTo(a[sortBy].toString());
      }
    });

    return filteredCategories;
  }

  int getColumnIndex(String columnName) {
    switch (columnName) {
      case 'name':
        return 0;
      case 'createdAt':
        return 1;
      case 'price':
        return 2;
      case 'quantity':
        return 3;
      default:
        return 0;
    }
  }

  void handleSelectCategory(value) {
    setState(() {
      category = value;
    });
    getExpenses();
  }

  void handleSelectStatus(value) {
    setState(() {
      status = value;
    });
    getExpenses();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // The date displayed when the picker opens
      firstDate: DateTime(2000), // The earliest date a user can select
      lastDate: DateTime.now(), // The latest date a user can select
    );
    if (picked != null) {
      // Handle the selected date, e.g., update a state variable
      setState(() {
        selectedDate = picked;
      });
      getExpenses();
    }
  }

  handleDelete(id) async {
    await apiService.delete('expense/$id');
    getExpenses();
  }

  handleUpdate(id, update) async {
    await apiService.patch('expense/$id', update);
    getExpenses();
  }

  handlePageChange(pageNumber) {
    setState(() {
      selectedPageNumber = pageNumber;
    });
    getExpenses();
  }

  @override
  void initState() {
    getCategories();
    getExpenses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top fixed content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 14,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Expense Transaction', style: TextStyle(fontSize: 10)),
                  ElevatedButton.icon(
                    style: ButtonStyle(),
                    onPressed: () {
                      context.router.push(AddExpenseRoute());
                    },
                    label: Text('New Expense', style: TextStyle(fontSize: 10)),
                    icon: Icon(Icons.add, size: 10),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DateRangeHolder(
                      fromDate: startDate,
                      toDate: endDate,
                      handleRangeChange: (String handle, DateTime picked) {
                        handleRangeChange(handle, picked);
                      },
                      handleDateReset: () {},
                    ),
                  ),
                  SizedBox(width: 10),
                  FiltersDropdown(
                    pillIcon: Icons.category_outlined,
                    selected: category,
                    menuList: categories,
                    doSelect: handleSelectCategory,
                  ),
                  SizedBox(width: 10),
                  FiltersDropdown(
                    pillIcon: Icons.pending_actions,
                    selected: status,
                    menuList: statuses,
                    doSelect: handleSelectStatus,
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: EmptyComponent(
                        icon: Icons.receipt_long,
                        message: "No Expenses Yet",
                        subMessage:
                            "Start tracking your spending by adding an expense.",
                        reload: getExpenses,
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
                              cardsPerRow = 3; // large screen
                            } else if (maxWidth >= 600) {
                              cardsPerRow = 2; // medium screen
                            } else {
                              cardsPerRow = 1; // small screen
                            }

                            // Card width calculation with spacing
                            double spacing = 16.0;
                            double cardWidth =
                                (maxWidth - (spacing * (cardsPerRow - 1))) /
                                cardsPerRow;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: expenses
                                  .map(
                                    (res) => SizedBox(
                                      width: cardWidth,
                                      child: Stack(
                                        children: [
                                          SmallinfoCard(
                                            icon: Icon(Icons.abc_outlined),
                                            title:
                                                "${capitalizeFirstLetter(res['category'])} ---- from ${capitalizeFirstLetter(res['initiator'])} ",

                                            subString: formatBackendTime(
                                              res['date'],
                                            ),
                                            description: res['description'],
                                            status: res['approved'],
                                            amount: res['amount'],
                                            isMoney: true,
                                          ),

                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Row(
                                              children: [
                                                if (!res['approved'] &&
                                                    [
                                                      'god',
                                                      'account',
                                                      'manager',
                                                      'admin',
                                                      'supervisor',
                                                    ].contains(
                                                      JwtService()
                                                          .decodedToken?['role'],
                                                    ) &&
                                                    JwtService()
                                                            .decodedToken?['username'] ==
                                                        res['initiator'])
                                                  _ActionButton(
                                                    icon: Icons.edit,
                                                    color: Colors.grey[600]!,
                                                    onTap: () {
                                                      _showEditExpenceSheet(
                                                        context,
                                                        res,
                                                        handleUpdate,
                                                      );
                                                    },
                                                  ),
                                                const SizedBox(width: 4),
                                                if (!res['approved'] &&
                                                    [
                                                      'god',
                                                      'account',
                                                      'manager',
                                                      'admin',
                                                      'supervisor',
                                                    ].contains(
                                                      JwtService()
                                                          .decodedToken?['role'],
                                                    ) &&
                                                    JwtService()
                                                            .decodedToken?['username'] ==
                                                        res['initiator'])
                                                  _ActionButton(
                                                    icon: Icons.delete,
                                                    color: Colors.red,
                                                    onTap: () {
                                                      _showDeleteConfirmation(
                                                        context,
                                                        res['category'],
                                                        res['_id'],
                                                        handleDelete,
                                                      );
                                                    },
                                                  ),
                                                if ([
                                                  'god',
                                                  'account',
                                                  'manager',
                                                  'admin',
                                                ].contains(
                                                  JwtService()
                                                      .decodedToken?['role'],
                                                ))
                                                  _ActionButton(
                                                    icon: res['approved']
                                                        ? Icons.close
                                                        : Icons
                                                              .check_circle_outline_outlined,
                                                    color: res['approved']
                                                        ? Colors.redAccent
                                                        : Colors.green,
                                                    onTap: () {
                                                      handleUpdate(res['_id'], {
                                                        'approved':
                                                            !res['approved'],
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
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
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 34, // similar to w-48 in Tailwind
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: const TextStyle(fontSize: 10),

          prefixIcon: const Icon(Icons.search, size: 10),
          filled: true, // bg-gray-100
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30), // pill shape
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, // accent color
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

void _showEditExpenceSheet(BuildContext context, data, handleUpdate) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    // shape: const RoundedRectangleBorder(
    //   borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    // ),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: AddExpenseScreen(updateInfo: data),
      );
    },
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  String categoryName,
  String id,
  Function handleDelete,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Expense"),
        content: Text(
          "Are you sure you want to delete Exepsnes from \"$categoryName\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              handleDelete(id);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}
