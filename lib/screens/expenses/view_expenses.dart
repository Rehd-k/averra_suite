import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../helpers/financial_string_formart.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../service/api.service.dart';
import 'add_expneses.dart';

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
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

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

  Future updateExpenseList() async {
    setState(() {
      isLoading = true;
    });
    var dbexpenses = await apiService.get('expense?skip=${expenses.length}');
    setState(() {
      expenses.addAll(dbexpenses.data);
      filteredExpenses = List.from(expenses);
      isLoading = false;
    });
  }

  void updateExpenseWhole() async {
    var dbexpenses = await apiService.get('expense');
    setState(() {
      expenses = dbexpenses.data;
      filteredExpenses = List.from(expenses);
    });
  }

  void deleteExpense(String id) async {
    await apiService.delete('expense/delete/$id');
    updateExpenseWhole();
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

  @override
  void initState() {
    super.initState();
    getExpensesList();
    filteredExpenses = List.from(expenses);
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
            empty: Text('No Expenses Recorded'),
            minWidth: 1500,
            actions: [],
            header: smallScreen
                ? SizedBox(
                    width: 10,
                    child: FilledButton.icon(
                      onPressed: () => showBarModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            AddExpenses(updateExpenses: widget.updateExpense),
                      ),
                      label: Text('Add Expense'),
                      icon: Icon(Icons.add_box_outlined),
                    ),
                  )
                : Row(children: [searchBox(smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("Category"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'category';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(label: Text("description"), size: ColumnSize.L),
              DataColumn2(label: Text("amount")),
              DataColumn2(label: Text("amountPaid")),
              DataColumn2(label: Text("initiator")),
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
              DataColumn2(label: Text('Actions')),
            ],
            source: ExpensesDataSource(
              deleteExpense: deleteExpense,
              expenses: getFilteredAndSortedRows(),
              context: context,
              updateExpenseData: () {
                updateExpenseWhole();
              },
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
      width: smallScreen ? double.infinity : 250,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search...",
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            onPressed: () => filterProducts(_searchController.text),
          ),
        ),
        onChanged: (query) => {filterProducts(query), searchQuery = query},
      ),
    );
  }
}

class EditExpense extends StatefulWidget {
  final Map<String, dynamic> expense;
  final Function() updateExpenseData;

  const EditExpense({
    required this.expense,
    required this.updateExpenseData,
    super.key,
  });

  @override
  EditExpenseState createState() => EditExpenseState();
}

class EditExpenseState extends State<EditExpense> {
  final apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _amountPaidController;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(
      text: widget.expense['category'],
    );
    _descriptionController = TextEditingController(
      text: widget.expense['description'],
    );
    _amountController = TextEditingController(
      text: widget.expense['amount'].toString(),
    );
    _amountPaidController = TextEditingController(
      text: widget.expense['amountPaid'].toString(),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _amountPaidController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      await apiService.put('expense/update/${widget.expense['_id']}', {
        'category': _categoryController.text,
        'description': _descriptionController.text,
        'amount': _amountController.text,
        'amountPaid': _amountPaidController.text,
      });

      await widget.updateExpenseData();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveExpense)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _amountPaidController,
                decoration: InputDecoration(labelText: 'Amount Paid'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount paid';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpensesDataSource extends DataTableSource {
  final List expenses;
  final Function() updateExpenseData;
  BuildContext context;
  final Function(String) deleteExpense;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  void _showEditExpenseBottomSheet(Map<String, dynamic> expense) {
    showBarModalBottomSheet(
      context: context,
      builder: (context) =>
          EditExpense(expense: expense, updateExpenseData: updateExpenseData),
    );
  }

  Color? getRowColor(int amountPaid, int amount) {
    return amountPaid < amount
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;
  }

  ExpensesDataSource({
    required this.deleteExpense,
    required this.updateExpenseData,
    required this.expenses,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= expenses.length) return null;
    final expense = expenses[index];
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        return getRowColor(expense['amountPaid'], expense['amount']);
      }),
      cells: [
        DataCell(Text(expense['category'])),
        DataCell(Text(expense['description'])),
        DataCell(
          Text(
            expense['amount'].toString().formatToFinancial(isMoneySymbol: true),
          ),
        ),
        DataCell(
          Text(
            expense['amountPaid'].toString().formatToFinancial(
              isMoneySymbol: true,
            ),
          ),
        ),
        DataCell(Text(expense['createdBy'])),
        DataCell(Text(formatDate(expense['createdAt']))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  _showEditExpenseBottomSheet(expense);
                },
                icon: Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () {
                  deleteExpense(expense['_id']);
                },
                icon: Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => expenses.length;

  @override
  int get selectedRowCount => 0;
}
