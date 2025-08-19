final List<Map<String, dynamic>> customerColumnDefinitionMaps = [
  {
    'name': 'Invoice number',
    'sortable': false,
    'type': 'text',
    'field': 'invoiceNumber'
  },
  {
    'name': 'Issue date',
    'sortable': true,
    'type': 'date',
    'field': 'issuedDate'
  },
  {'name': 'Due date', 'sortable': true, 'type': 'date', 'field': 'dueDate'},
  {'name': 'Total', 'sortable': true, 'type': 'number', 'field': 'totalAmount'},
  {'name': 'Status', 'sortable': true, 'type': 'number', 'field': 'status'},
  {
    'name': 'Action',
    'sortable': true,
    'type': 'number',
    'field': 'invoiceActions'
  },
];
