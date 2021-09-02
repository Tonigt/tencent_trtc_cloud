/*
 *  Copyright (C), 2015-2021
 *  FileName: slider
 *  Author: Tonight丶相拥
 *  Date: 2021/8/26
 *  Description: 
 **/

part of furender;

class _Slider extends StatelessWidget {
  _Slider(this.currentItem, {required this.onChanged, this.onChangeEnd});
  final ItemModel? currentItem;
  final void Function(double) onChanged;
  final void Function(double)? onChangeEnd;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
        alignment: Alignment.center,
        child: !(currentItem?.style01 ?? false) ? Container(
          child: Slider(value: ((currentItem?.value ?? 0) / (currentItem?.maxValue ?? 1)) * 100,
              min: 0,
              max: 100,
              divisions: 100,
              label: "${(((currentItem?.value ?? 0) / (currentItem?.maxValue ?? 1)) * 100).floor()}",
              onChanged: (value) {
                onChanged(value / 100);
              }, onChangeEnd: (value) {
                // onChanged(value / 100);
                onChangeEnd?.call(value / 100);
              }),
        ) : Container(
            child: FlutterSlider(
                centeredOrigin: true,
                min: -50,
                max: 50,
                onDragCompleted: (_, value, __) {
                  onChangeEnd?.call(value.toDouble() / 50);
                },
                values: [(currentItem?.value ?? 0) / (currentItem?.maxValue ?? 0) * 50],
                onDragging: (_, value, __) {
                  onChanged(value.toDouble() / 50);
                  // print("$value --------- ");
                }
            )
        )
    );
  }
}