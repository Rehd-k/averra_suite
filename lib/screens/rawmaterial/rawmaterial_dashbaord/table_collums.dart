final columnDefs = [
  {'name': 'Quantity', 'sortable': true, 'type': 'number', 'field': 'quantity'},
  {'name': 'Sold', 'sortable': true, 'type': 'sold', 'field': 'sold'},
  {'name': 'Price', 'sortable': true, 'type': 'money', 'field': 'price'},
  {
    'name': 'Serving Size',
    'sortable': true,
    'type': 'money',
    'field': 'servingPrice',
  },

  {'name': 'Total', 'sortable': true, 'type': 'money', 'field': 'total'},
  {'name': 'Discount', 'sortable': true, 'type': 'money', 'field': 'discount'},
  {
    'name': 'Total Payable',
    'sortable': true,
    'type': 'money',
    'field': 'totalPayable',
  },
  {
    'name': 'Purchase Date',
    'sortable': false,
    'type': 'date',
    'field': 'purchaseDate',
  },
  {'name': 'Status', 'sortable': false, 'type': 'text', 'field': 'status'},
  {
    'name': 'Delivery Date',
    'sortable': true,
    'type': 'date',
    'field': 'deliveryDate',
  },
  {
    'name': 'Expiry Date',
    'sortable': true,
    'type': 'date',
    'field': 'expiryDate',
  },
  {'name': 'Cash', 'sortable': false, 'type': 'money', 'field': 'cash'},
  {'name': 'Bank', 'sortable': false, 'type': 'money', 'field': 'bank'},
  {
    'name': 'Initiator',
    'sortable': false,
    'type': 'text',
    'field': 'initiator',
  },
  {'name': 'Date', 'sortable': true, 'type': 'date', 'field': 'createdAt'},
  {
    'name': 'Actions',
    'sortable': false,
    'type': 'actions',
    'field': 'purchases_actions',
  },
];
