
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
enum Categories<Category> {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}
class Category{
  const Category(
    this.name,
    this.color,
  );
  final String name;
  final Color color;
}