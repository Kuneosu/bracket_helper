import 'package:flutter/material.dart';

class ColorPickerGrid extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;
  final List<Color>? colors;
  final double colorSize;
  final double spacing;

  /// 색상 선택 그리드 컴포넌트
  ///
  /// [selectedColor] 현재 선택된 색상
  /// [onColorSelected] 색상 선택 시 호출되는 콜백 함수
  /// [colors] 선택 가능한 색상 목록 (null일 경우 기본 색상 목록 사용)
  /// [colorSize] 각 색상 원의 크기 (기본값: 42)
  /// [spacing] 색상 원 사이의 간격 (기본값: 12)
  const ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
    this.colors,
    this.colorSize = 42,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    // 선택 가능한 색상 목록 (colors가 null일 경우 기본 색상 목록 사용)
    final colorList = colors ?? [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children:
          colorList.map((color) {
            final isSelected = selectedColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: colorSize,
                height: colorSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border:
                      isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ]
                          : null,
                ),
                child:
                    isSelected ? Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
    );
  }
} 