import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DefaultDatePicker extends StatefulWidget {
  final String? hintText;
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;

  const DefaultDatePicker({
    super.key,
    this.hintText,
    this.initialDate,
    this.onDateSelected,
  });

  @override
  State<DefaultDatePicker> createState() => _DefaultDatePickerState();
}

class _DefaultDatePickerState extends State<DefaultDatePicker> {
  TextEditingController? _controller;
  late DateTime _selectedDate;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('ko', null);
    _controller = TextEditingController(
      text: DateFormat('yyyy-MM-dd(E)', 'ko').format(_selectedDate),
    );
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    } else {
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CST.primary100,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          _controller?.text = DateFormat(
            'yyyy-MM-dd(E)',
            'ko',
          ).format(_selectedDate);
        });
        
        if (widget.onDateSelected != null) {
          widget.onDateSelected!(_selectedDate);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // _controller가 초기화되기 전에 빈 TextField 표시
    if (!_isInitialized) {
      return TextField(
        decoration: InputDecoration(
          hintText: widget.hintText ?? '',
          hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
          border: OutlineInputBorder(borderSide: BorderSide(color: CST.gray3)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CST.gray3),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CST.primary100),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: CST.gray3),
        ),
      );
    }

    return TextField(
      controller: _controller,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        hintText: widget.hintText ?? '',
        hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
        border: OutlineInputBorder(borderSide: BorderSide(color: CST.gray3)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.gray3),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.primary100),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: CST.gray3),
      ),
    );
  }
}
