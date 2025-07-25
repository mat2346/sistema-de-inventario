import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) getDisplayText;
  final String labelText;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.getDisplayText,
    required this.labelText,
    required this.onChanged,
    this.validator,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getDisplayText(item)),
            );
          }).toList(),
      onChanged: onChanged,
      validator:
          validator ??
          (isRequired
              ? (value) {
                if (value == null) {
                  return 'Selecciona $labelText';
                }
                return null;
              }
              : null),
    );
  }
}

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;
  final int? maxLines;
  final String? hintText;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const AppTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.validator,
    this.isRequired = false,
    this.maxLines = 1,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        hintText: hintText,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
      validator:
          validator ??
          (isRequired
              ? (value) {
                if (value == null || value.isEmpty) {
                  return '$labelText es requerido';
                }
                return null;
              }
              : null),
    );
  }
}
