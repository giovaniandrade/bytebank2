import 'package:flutter/material.dart';

abstract class BlocContainer extends StatelessWidget {}

void push(BuildContext context, BlocContainer container) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => container,
    ),
  );
}