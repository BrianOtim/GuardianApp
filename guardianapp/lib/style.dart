import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String fieldName) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintText: fieldName,
    hintStyle: const TextStyle(fontSize: 13.0),
    contentPadding: const EdgeInsets.only(left: 15.0, bottom: 10.0, top: 10.0),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(25.7),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(25.7),
    ),
  );
}
