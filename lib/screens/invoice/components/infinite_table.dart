// import 'package:auto_route/auto_route.dart';
import 'dart:io';

import 'package:averra_suite/helpers/financial_string_formart.dart';
import 'package:averra_suite/service/toast.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../service/invoice.pdf.dart';
import 'handle.payments.dart';
import 'preview.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final Map customer;
  final String issueDate;
  final String dueDate;
  final String recurringCycle;
  final num total;
  final String amountPaid;
  final String status;
  final List items;
  final num discount;
  final num tax;
  final Map bank;
  final String note;
  final String? transactionId;

  Invoice({
    required this.note,
    required this.id,
    required this.invoiceNumber,
    required this.customer,
    required this.issueDate,
    required this.dueDate,
    required this.recurringCycle,
    required this.total,
    required this.amountPaid,
    required this.status,
    required this.items,
    required this.discount,
    required this.tax,
    required this.bank,
    this.transactionId,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    Map? customer,
    String? issueDate,
    String? dueDate,
    String? recurringCycle,
    double? total,
    String? amountPaid,
    String? status,
    List? items,
    double? discount,
    double? tax,
    Map? bank,
    String? transactionId,
    String? note,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customer: customer ?? this.customer,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      recurringCycle: recurringCycle ?? this.recurringCycle,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      bank: bank ?? this.bank,
      transactionId: transactionId ?? this.transactionId,
      note: note ?? this.note,
    );
  }
}

class InvoiceTablePage extends StatelessWidget {
  final List<Invoice> invoices;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMore;
  final Function(String id) handleSendMessage;
  final Function updateInvoice;
  final Function(String id) deleteInvoice;

  const InvoiceTablePage({
    super.key,
    required this.invoices,
    required this.scrollController,
    required this.isLoading,
    required this.hasMore,
    required this.handleSendMessage,
    required this.updateInvoice,
    required this.deleteInvoice,
  });

  Color _rowColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade100;
      case 'due':
        return Colors.yellow.shade100;
      case 'overdue':
        return Colors.red.shade100;
      default:
        return Theme.of(context).cardColor;
    }
  }

  String formatDate(String isoDate) {
    final DateTime parsedDate = DateTime.parse(isoDate);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  Future<String> getDownloadsPath() async {
    if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'] ?? '';
      return '$home\\Downloads';
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Downloads';
    } else if (Platform.isAndroid) {
      // For Android, save to public Downloads folder
      return '/storage/emulated/0/Download';
    } else {
      // Fallback: use documents directory
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  Future<void> savePdf(Invoice invoice, BuildContext context) async {
    final file = await generateInvoicePdf(invoice);
    final downloadsPath = await getDownloadsPath();

    final filePath = File(
      '$downloadsPath/${invoice.customer['name']}\'s invoce.pdf',
    );
    try {
      await filePath.writeAsBytes(file.readAsBytesSync());
    } catch (e) {
      showToast("Canceled, Not Saved", ToastificationType.warning);
    }

    if (downloadsPath.isEmpty) {
      showToast("Canceled, Not Saved", ToastificationType.warning);
      return;
    }

    showToast("Saved to Downloads", ToastificationType.success);
  }

  Future<void> sharePdf(Invoice invoice) async {
    final file = await generateInvoicePdf(invoice);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: "Here's your invoice",
        subject: "Invoice",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    bool smallScreen = width <= 1200;
    return Column(
      children: [
        const SizedBox(height: 16),
        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: !smallScreen ? 140 : 90,
            dataRowMinHeight: 48,
            columns: const [
              DataColumn(label: Text('Invoice number')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Issue date')),
              DataColumn(label: Text('Due date')),
              DataColumn(label: Text('From')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Transaction Id')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: invoices.asMap().entries.map((entry) {
              final invoice = entry.value;
              return DataRow(
                color: WidgetStateProperty.all(
                  _rowColor(invoice.status, context),
                ),
                cells: [
                  DataCell(Text(invoice.invoiceNumber.toUpperCase())),
                  DataCell(Text(invoice.customer['name'])),
                  DataCell(Text(formatDate(invoice.issueDate))),
                  DataCell(Text(formatDate(invoice.dueDate))),
                  DataCell(Text(invoice.recurringCycle)),
                  DataCell(
                    Text(
                      invoice.discount.toString().formatToFinancial(
                        isMoneySymbol: true,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      invoice.total.toString().formatToFinancial(
                        isMoneySymbol: true,
                      ),
                    ),
                  ),
                  DataCell(SelectableText(invoice.amountPaid.toUpperCase())),
                  DataCell(Text(invoice.status)),
                  DataCell(
                    PopupMenuButton<int>(
                      padding: const EdgeInsets.all(1),
                      icon: Icon(
                        Icons.more_vert_outlined,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      itemBuilder: (context) => [
                        invoice.status == 'paid'
                            ? PopupMenuItem(
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
                                      "See Transaction",
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
                              )
                            : PopupMenuItem(
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
                                      "Create Payment",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface.withAlpha(180),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return HandlePayments(
                                        total:
                                            (invoice.total + invoice.discount)
                                                .toDouble(),
                                        cart: invoice.items,
                                        selectedBank: invoice.bank,
                                        selectedUser: invoice.customer,
                                        discount: invoice.discount,
                                        invoiceId: invoice.id,
                                        handleComplete: updateInvoice,
                                      );
                                    },
                                    isScrollControlled: true,
                                  ),
                                },
                              ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_note_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Edit",
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
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.details,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Invoice Details",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return InvoicePage(
                                  invoice: invoice,
                                  // location : location
                                );
                              },
                              isScrollControlled: true,
                            ),
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Send Invoice",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            sharePdf(invoice);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.download_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(180),
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Download Invoce",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            savePdf(invoice, context);
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
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
                          onTap: () => {deleteInvoice(invoice.id)},
                        ),
                      ],
                      // offset: const Offset(0, 100),
                      // color: Colors.green,
                      elevation: 2,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
