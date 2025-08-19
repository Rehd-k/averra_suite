final List<Map<String, dynamic>> salesColumnDefinitionMaps = [
  {
    'name': 'Trans Id',
    'sortable': false,
    'type': 'uppercase',
    'field': 'transactionId'
  },
  {'name': 'Cash', 'sortable': true, 'type': 'money', 'field': 'cash'},
  {'name': 'Card', 'sortable': true, 'type': 'money', 'field': 'card'},
  {'name': 'Transfer', 'sortable': true, 'type': 'money', 'field': 'transfer'},
  {'name': 'Discount', 'sortable': false, 'type': 'money', 'field': 'discount'},
  {'name': 'Total', 'sortable': true, 'type': 'money', 'field': 'totalAmount'},
  {
    'name': 'Date',
    'sortable': true,
    'type': 'date',
    'field': 'transactionDate'
  },
  {'name': 'Initiator', 'sortable': false, 'type': 'text', 'field': 'handler'},
  {
    'name': 'Action',
    'sortable': false,
    'type': 'text',
    'field': 'show_sales_details'
  },
];
