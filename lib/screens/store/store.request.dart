import 'package:flutter/material.dart';

import '../../service/api.service.dart';
import '../../service/token.service.dart';

class StoreRequest extends StatefulWidget {
  const StoreRequest({super.key});

  @override
  StoreRequestState createState() => StoreRequestState();
}

class StoreRequestState extends State<StoreRequest> {
  ApiService apiService = ApiService();
  JwtService jwtService = JwtService();
  late List stores = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void getStores() async {
    var result = await apiService.get('stores');
    setState(() {
      stores = result.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
