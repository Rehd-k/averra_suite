import 'package:auto_route/auto_route.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_router.gr.dart';
import '../../helpers/financial_string_formart.dart';
import '../../service/api.service.dart';
import '../../service/gateway.service.dart';
import '../../service/token.service.dart';

class ViewBanks extends StatefulWidget {
  final Function()? updateBank;
  const ViewBanks({super.key, this.updateBank});

  @override
  ViewBanksState createState() => ViewBanksState();
}

class ViewBanksState extends State<ViewBanks> {
  final GatewayService gatewayService = GatewayService();
  final ApiService apiService = ApiService();
  final JwtService jwtService = JwtService();
  List filteredBanks = [];
  late List banks = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  int rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  String searchQuery = "";
  String sortBy = "name";
  bool ascending = true;

  void filterProducts(String query) {
    setState(() {
      filteredBanks = banks.where((bank) {
        return bank.values.any(
          (value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()),
        );
      }).toList();
    });
  }

  Future updateBankList() async {
    List bankKeep = [];
    setState(() {
      isLoading = true;
    });
    var dbbanks = await apiService.get('bank');
    for (var element in dbbanks.data) {
      if (element['access'].contains(jwtService.decodedToken?['location'])) {
        bankKeep.add(element);
      }
    }
    setState(() {
      banks = bankKeep;
      filteredBanks = List.from(banks);
      isLoading = false;
    });
  }

  Future getBanksList() async {
    try {
      var dbbanks = await apiService.get('bank');

      setState(() {
        banks = dbbanks.data;
        filteredBanks = List.from(banks);
        isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      context.router.push(ErrorRoute());
    }
  }

  List getFilteredAndSortedRows() {
    List filteredCategories = banks.where((product) {
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
      default:
        return 0;
    }
  }

  Future deleteBank(String id) async {
    await gatewayService.deleteBank(id);

    setState(() {
      banks.removeWhere((bank) => bank['_id'] == id);
      filteredBanks = List.from(banks);
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBanksList();
    filteredBanks = List.from(banks);
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
            empty: Text('No Banks Recorded'),
            minWidth: 1000,
            actions: [
              FilledButton.icon(
                onPressed: () {},
                icon: Icon(Icons.exit_to_app, size: 10),
                label: Text(
                  'Extract',
                  style: TextStyle(fontWeight: FontWeight.w100, fontSize: 10),
                ),
              ),
            ],
            header: smallScreen
                ? SizedBox()
                // ? SizedBox(
                //     width: 10,
                //     child: FilledButton.icon(
                //       onPressed: () => showBarModalBottomSheet(
                //         expand: true,
                //         context: context,
                //         backgroundColor: Colors.transparent,
                //         builder: (context) =>
                //             AddBank(updateBank: widget.updateBank),
                //       ),
                //       label: Text('Add Bank'),
                //       icon: Icon(Icons.add_box_outlined),
                //     ),
                //   )
                : Row(children: [searchBox(smallScreen)]),
            columns: [
              DataColumn2(
                label: Text("Name"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'name';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(
                label: Text("Account Name"),
                size: ColumnSize.L,
                onSort: (index, ascending) {
                  setState(() {
                    sortBy = 'accountName';
                    this.ascending = ascending;
                  });
                },
              ),
              DataColumn2(label: Text("Account Number"), size: ColumnSize.L),

              DataColumn2(label: Text("Balance")),
              DataColumn2(label: Text("Is Active")),
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
            source: BanksDataSource(
              banks: getFilteredAndSortedRows(),
              deleteBank: deleteBank,
              context: context,
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

class BanksDataSource extends DataTableSource {
  final List banks;
  final Function deleteBank;
  final BuildContext context;

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  BanksDataSource({
    required this.banks,
    required this.deleteBank,
    required this.context,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= banks.length) return null;
    final bank = banks[index];
    return DataRow(
      cells: [
        DataCell(Text(bank['name'])),
        DataCell(Text(bank['accountName'])),
        DataCell(Text(bank['accountNumber'])),
        bank['isActive'] ? DataCell(Text('True')) : DataCell(Text('False')),
        DataCell(
          Text(
            bank['balance'].toString().formatToFinancial(isMoneySymbol: true),
          ),
        ),
        DataCell(Text(bank['initiator'])),
        DataCell(Text(formatDate(bank['createdAt']))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // IconButton.outlined(
              //     tooltip: 'Update', onPressed: () {}, icon: Icon(Icons.edit)),
              IconButton(
                onPressed: () {
                  deleteBank(bank['_id']);
                },
                icon: Icon(
                  Icons.delete_forever_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Delete',
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
  int get rowCount => banks.length;

  @override
  int get selectedRowCount => 0;
}
