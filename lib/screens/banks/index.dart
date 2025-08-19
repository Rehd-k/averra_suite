import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'add_bank.dart';
import 'view_banks.dart';

@RoutePage()
class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  BankScreenState createState() => BankScreenState();
}

class BankScreenState extends State<BankScreen> {
  final GlobalKey<ViewBanksState> _viewBankKey = GlobalKey<ViewBanksState>();

  void updateBanks() {
    _viewBankKey.currentState?.updateBankList();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Scaffold(
      floatingActionButton: smallScreen
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    // height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(8.0),
                    child: AddBank(updateBank: updateBanks),
                  ),
                );
              },
              child: Icon(Icons.add_outlined),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            smallScreen
                ? SizedBox.shrink()
                : Expanded(flex: 1, child: AddBank(updateBank: updateBanks)),
            SizedBox(width: smallScreen ? 0 : 20),
            Expanded(
              flex: 2,
              child: ViewBanks(key: _viewBankKey, updateBank: updateBanks),
            ),
          ],
        ),
      ),
    );
  }
}
