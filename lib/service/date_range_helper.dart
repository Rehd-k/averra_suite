import 'package:flutter/material.dart';

class DateRangeHolder extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(String handle, DateTime picked) handleRangeChange;
  final Function handleDateReset;

  const DateRangeHolder({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.handleRangeChange,
    required this.handleDateReset,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool isBigScreen = width >= 1200;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: isBigScreen
          ? Row(
              children: [
                Row(
                  children: [
                    isBigScreen
                        ? Text('From :', style: TextStyle(fontSize: 10))
                        : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today, size: 10),
                      tooltip: 'From date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: fromDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: toDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('from', picked);
                        }
                      },
                    ),
                    Text(
                      fromDate != null
                          ? "${fromDate!.toLocal()}".split(' ')[0]
                          : "From",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                Row(
                  children: [
                    isBigScreen
                        ? Text('To :', style: TextStyle(fontSize: 10))
                        : SizedBox.shrink(),
                    IconButton(
                      icon: Icon(Icons.calendar_today, size: 10),
                      tooltip: 'To date',
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: toDate ?? DateTime.now(),
                          firstDate: fromDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          handleRangeChange('to', picked);
                        }
                      },
                    ),
                    Text(
                      toDate != null
                          ? "${toDate!.toLocal()}".split(' ')[0]
                          : "To",
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Spacer(),
                isBigScreen
                    ? OutlinedButton(
                        onPressed: () {
                          handleDateReset();
                        },
                        child: Text('Reset'),
                      )
                    : IconButton(
                        onPressed: () {
                          handleDateReset();
                        },
                        icon: Icon(Icons.cancel_outlined),
                      ),
              ],
            )
          : Row(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_today, size: 10),
                          tooltip: 'From date',
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: fromDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: toDate ?? DateTime.now(),
                            );
                            if (picked != null) {
                              handleRangeChange('from', picked);
                            }
                          },
                        ),
                        Text(
                          fromDate != null
                              ? "${fromDate!.toLocal()}".split(' ')[0]
                              : "From",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    // Spacer(),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.calendar_today, size: 10),
                          tooltip: 'To date',
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: toDate ?? DateTime.now(),
                              firstDate: fromDate ?? DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              handleRangeChange('to', picked);
                            }
                          },
                        ),
                        Text(
                          toDate != null
                              ? "${toDate!.toLocal()}".split(' ')[0]
                              : "To",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => {handleDateReset},
                  icon: Icon(Icons.cancel_outlined, size: 10),
                ),
              ],
            ),
    );
  }
}
