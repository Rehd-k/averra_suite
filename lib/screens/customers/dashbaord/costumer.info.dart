import 'package:flutter/material.dart';

class CostumerInfo extends StatelessWidget {
  final Map details;
  const CostumerInfo({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person_2_outlined),
                  ),
                  Text(
                    details['name']
                        .split(' ')
                        .map((word) => word.isNotEmpty
                            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                            : '')
                        .join(' '),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(details['email'])
                ],
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone number',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(details['phone_number'])
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(details['name']
                      .split(' ')
                      .map((word) => word.isNotEmpty
                          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                          : '')
                      .join(' '))
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    details['address'],
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    details['city'],
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'State : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    details['state'],
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zip code : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    details['zipCode'],
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Country : ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Nigeria',
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }
}
