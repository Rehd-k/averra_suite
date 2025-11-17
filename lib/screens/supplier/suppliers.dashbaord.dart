import 'package:auto_route/auto_route.dart';
import 'package:averra_suite/service/api.service.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../app_router.gr.dart';
import '../../components/tables/suppliers.table.dart';

@RoutePage()
class SuppliersDashbaordScreen extends StatefulWidget {
  const SuppliersDashbaordScreen({super.key});

  @override
  SuppliersDashbaordState createState() => SuppliersDashbaordState();
}

class SuppliersDashbaordState extends State<SuppliersDashbaordScreen> {
  final ApiService apiService = ApiService();
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  late Map res = {};
  bool isLoading = true;

  @override
  void initState() {
    getDetails();
    super.initState();

    ShowcaseView.register(
      autoPlayDelay: const Duration(seconds: 3),
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => ShowcaseView.get().dismiss(),

            child: const Text('Skip'),
          ),
        ),
      ),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 20,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need previous action for the first showcase widget
          // so we hide this action for the first showcase widget
          hideActionWidgetForShowcase: [_one],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need next action for the last showcase widget so we
          // hide this action for the last showcase widget
          hideActionWidgetForShowcase: [_four],
        ),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowcaseView.get().startShowCase([_one, _two, _three, _four]),
    );
  }

  Future<void> getDetails() async {
    var response = await apiService.get('supplier/dashbaord');
    setState(() {
      res = response.data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Supplier Managment',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        actions: [
          Showcase(
            tooltipBackgroundColor: Theme.of(context).cardColor,
            showArrow: false,
            key: _one,
            title: 'Add New Supplier',
            titleTextStyle: TextStyle(
              fontSize: !smallScreen ? 12 : 10,
              fontWeight: FontWeight.bold,
            ),
            descTextStyle: TextStyle(fontSize: !smallScreen ? 12 : 10),
            description:
                'Click This Button to Quickly Add New Supplier to the System',
            child: ElevatedButton.icon(
              style: ButtonStyle(),
              onPressed: () {
                context.router.push(AddSupplier());
              },
              label: Text('Add New', style: TextStyle(fontSize: 10)),
              icon: Icon(Icons.add, size: 10),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: res.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Overview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    smallScreen
                        ? Showcase(
                            tooltipBackgroundColor: Theme.of(context).cardColor,
                            showArrow: false,
                            key: _two,
                            title: 'Active/ Inactive Suppliers',
                            titleTextStyle: TextStyle(
                              fontSize: !smallScreen ? 12 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                            descTextStyle: TextStyle(
                              fontSize: !smallScreen ? 12 : 10,
                            ),
                            description:
                                'This section shows the number of active and inactive suppliers',
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Active Suppliers',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            res['statusSummary']['active']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Inactive Suppliers',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            res['statusSummary']['inactive']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Showcase(
                            tooltipBackgroundColor: Theme.of(context).cardColor,
                            showArrow: false,
                            key: _two,
                            title: 'Active/ Inactive Suppliers',
                            titleTextStyle: TextStyle(
                              fontSize: !smallScreen ? 12 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                            descTextStyle: TextStyle(
                              fontSize: !smallScreen ? 12 : 10,
                            ),
                            description:
                                'This section shows the number of active and inactive suppliers',
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Active Suppliers',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            res['statusSummary']['active']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Inactive Suppliers',
                                            style: TextStyle(fontSize: 10),
                                          ),
                                          Text(
                                            res['statusSummary']['inactive']
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Text(
                        'Top Suppliers By Purchase Volume',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Showcase(
                      tooltipBackgroundColor: Theme.of(context).cardColor,
                      showArrow: false,
                      key: _three,
                      title: 'Top 5 Suppliers By Purchase Volume Table',
                      titleTextStyle: TextStyle(
                        fontSize: !smallScreen ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      descTextStyle: TextStyle(
                        fontSize: !smallScreen ? 12 : 10,
                      ),
                      description:
                          'This Table Shows The Top 5 Suppliers Based On Purchase Volume',
                      child: Row(
                        children: [
                          if (!isLoading)
                            Expanded(
                              flex: smallScreen ? 1 : 4,
                              child: SupplierTable(
                                suppliers: res['topSuppliers'],
                              ),
                            ),
                          if (!isLoading)
                            if (!smallScreen)
                              Expanded(
                                flex: 2,
                                child: SizedBox(),

                                // SupplierTable(
                                //   suppliers: res['latestAdditions'],
                                // ),
                              ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20),
                      child: Text(
                        'Latest Suppliers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Showcase(
                      tooltipBackgroundColor: Theme.of(context).cardColor,
                      showArrow: false,
                      key: _four,
                      title: 'Latest Suppliers Table',
                      titleTextStyle: TextStyle(
                        fontSize: !smallScreen ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                      descTextStyle: TextStyle(
                        fontSize: !smallScreen ? 12 : 10,
                      ),
                      description:
                          'This Table Shows The Latest Suppliers Added To The System',
                      child: Row(
                        children: [
                          Expanded(
                            flex: smallScreen ? 1 : 4,
                            child: SupplierTable(
                              suppliers: res['latestAdditions'],
                            ),
                          ),
                          if (!smallScreen)
                            Expanded(flex: 2, child: SizedBox()),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
