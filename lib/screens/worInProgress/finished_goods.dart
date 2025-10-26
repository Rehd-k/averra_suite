import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../components/emptylist.dart';
import '../../service/api.service.dart';
import '../../service/toast.service.dart';
import 'send.finished.dart';
import 'show.products.dart';

@RoutePage()
class FinishedGoods extends StatefulWidget {
  const FinishedGoods({super.key});

  @override
  FinishedGoodsState createState() => FinishedGoodsState();
}

class FinishedGoodsState extends State<FinishedGoods> {
  final ApiService apiService = ApiService();
  TextEditingController titleController = TextEditingController();
  TextEditingController costController = TextEditingController();
  late List departmentFronts = [];
  late List<Map<String, dynamic>> products = [];
  late List workInProgress = [];
  Map? selectedProduct;
  late Map departmentFront = {};
  bool loading = true;
  String fromPoint = '';
  String fromPointName = '';

  void getProductsFromDepartment(String query) async {
    if (fromPoint.isNotEmpty) {
      try {
        var result = await apiService.get(
          'work-in-progress?filter={"at":"$query"}',
        );
        setState(() {
          departmentFront = result.data;
          workInProgress = result.data['workInProgress'];
          loading = false;
        });
      } catch (e) {
        showToast('Error $e', ToastificationType.error);
      }
    }
  }

  void selectFrom(String? value) async {
    if (value == null) return;
    String res = departmentFronts.firstWhere(
      (department) => department['_id'] == value,
      orElse: () => {'title': 'Unknown'},
    )['title'];

    setState(() {
      fromPointName = res;
      fromPoint = value;
      workInProgress = [];
    });

    getProductsFromDepartment(value);
  }

  void getDepartments() async {
    var res = await apiService.get('department?active=true');
    setState(() {
      departmentFronts = res.data;
      loading = false;
    });
  }

  Future handleAddCost(id, String? removeId) async {
    showToast('loading...', ToastificationType.info);
    num res = workInProgress.firstWhere(
      (department) => department['_id'] == id,
      orElse: () => {'totalCost': 0},
    )['totalCost'];
    await apiService.get(
      'work-in-progress/handle-other-cost?id=$id&title=${titleController.text}&cost=${int.tryParse(costController.text) ?? 0}&removeId=$removeId&totalCost=$res',
    );
    showToast('Done', ToastificationType.success);
  }

  @override
  void initState() {
    super.initState();
    getDepartments();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final textFieldWidth = isSmallScreen
        ? MediaQuery.of(context).size.width * 0.8
        : 400.0;

    final crossAxisCount = isSmallScreen ? 1 : 3;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  width: textFieldWidth,
                  child: DropdownButtonFormField<String>(
                    initialValue: fromPoint,
                    decoration: const InputDecoration(
                      labelText: 'Select Department',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: selectFrom,
                    items:
                        [
                          {'title': 'Select Department', '_id': ''},
                          ...departmentFronts,
                        ].map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value['_id'],
                            child: Text(
                              capitalizeFirstLetter(value['title'] ?? ''),
                            ),
                          );
                        }).toList(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select an option'
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : workInProgress.isEmpty
              ? Center(
                  child: EmptyComponent(
                    icon: Icons.remove_shopping_cart_outlined,
                    message: "No On Going Progress",
                    subMessage: "",
                    reload: getDepartments,
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: workInProgress.length,
                  itemBuilder: (context, index) {
                    final item = workInProgress[index];
                    return GestureDetector(
                      onDoubleTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled:
                              true, // allows full screen height if needed
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => DraggableScrollableSheet(
                            expand: false,
                            builder: (context, scrollController) {
                              return ShowProducts(
                                products: item['rawGoods'],
                                otherCosts: item['otherCosts'],
                                scrollController: scrollController,
                                handleAddCost: handleAddCost,
                                id: item['_id'],
                              );
                            },
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(
                                          item['title'] ?? 'No Title',
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            item['totalCost']
                                                .toString()
                                                .formatToFinancial(
                                                  isMoneySymbol: true,
                                                ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          IconButton(
                                            onPressed: () {
                                              getProductsFromDepartment('');
                                            },
                                            icon: Icon(Icons.refresh_outlined),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Materials :'),
                                      Text('${item['rawGoods'].length}'),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Other Costs :'),
                                      Text('${item['otherCosts'].length}'),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showTextInputDialog(
                                        context,
                                        titleController,
                                        costController,
                                        isSmallScreen,
                                        item['_id'],
                                      );
                                    },
                                    child: const Text("Add Cost"),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push<void>(
                                        MaterialPageRoute<void>(
                                          builder: (BuildContext context) =>
                                              SendFinished(
                                                totalCost: item['totalCost'],
                                                department: item['at'],
                                                itemId: item['_id'],
                                                updateList:
                                                    getProductsFromDepartment,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text("Finished"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<String?> showTextInputDialog(
    BuildContext context,
    TextEditingController titleController,
    TextEditingController costController,
    bool isSmallScreen,
    String id,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          title: const Text(
            "Enter Cost Details",
            style: TextStyle(fontSize: 10),
          ),
          content: SizedBox(
            width: isSmallScreen ? double.maxFinite : double.maxFinite * 0.5,
            height: 100,
            child: GridView.count(
              crossAxisCount: isSmallScreen ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isSmallScreen ? 4 : 6,
              shrinkWrap: true, //
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    label: Text('Title'),
                    hintText: "Type something...",
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  controller: costController,
                  decoration: const InputDecoration(
                    label: Text('Cost'),
                    hintText: "Type something...",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                num cost = int.tryParse(costController.text) ?? 0;
                if (cost > 0 && titleController.text.isNotEmpty) {
                  await handleAddCost(id, '');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
                // return text
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
