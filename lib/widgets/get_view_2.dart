import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GetView2<T, T2> extends StatelessWidget {
  const GetView2({Key? key}) : super(key: key);

  // ignore: avoid_field_initializers_in_const_classes
  final String? tag = null;

  T get controller => GetInstance().find<T>(tag: tag)!;
  T2 get controller2 => GetInstance().find<T2>(tag: tag)!;

  @override
  Widget build(BuildContext context);
}

abstract class GetView3<T, T2, T3> extends StatelessWidget {
  const GetView3({Key? key}) : super(key: key);

  // ignore: avoid_field_initializers_in_const_classes
  final String? tag = null;

  T get controller => GetInstance().find<T>(tag: tag)!;
  T2 get controller2 => GetInstance().find<T2>(tag: tag)!;
  T3 get controller3 => GetInstance().find<T3>(tag: tag)!;

  @override
  Widget build(BuildContext context);
}

abstract class GetView4<T, T2, T3> extends StatefulWidget {
  const GetView4({Key? key}) : super(key: key);

  // ignore: avoid_field_initializers_in_const_classes
  final String? tag = null;

  T get controller => GetInstance().find<T>(tag: tag)!;
  T2 get controller2 => GetInstance().find<T2>(tag: tag)!;
  T3 get controller3 => GetInstance().find<T3>(tag: tag)!;

  @override
  State<StatefulWidget> createState();
}
