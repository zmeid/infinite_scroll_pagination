import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/src/infrastructure/default_indicators/first_page_exception_indicator.dart';

class EmptyListIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const FirstPageExceptionIndicator(
        title: 'No items found',
        message: 'The list is currently empty.',
      );
}
