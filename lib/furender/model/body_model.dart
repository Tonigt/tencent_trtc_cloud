/*
 *  Copyright (C), 2015-2021
 *  FileName: body_model
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class _BodyModel extends FuRenderModelAbstract with _SettingMixin {
  _BodyModel(VoidCallback updateState): super(_FuType.body, updateState, true);

  @override
  // TODO: implement recover
  bool get recover => true;

  @override
  // TODO: implement datas
  final List<ItemModel> datas = [
    ItemModel(title: "BodySlimStrength", image: "BodySlimStrength", value: 0, maxValue: 1.0, key: "bodySlimStrength"),
    ItemModel(title: "LegSlimStrength", image: "LegSlimStrength", value: 0, maxValue: 1.0, key: "legSlimStrength"),
    ItemModel(title: "WaistSlimStrength", image: "WaistSlimStrength", value: 0, maxValue: 1.0, key: "waistSlimStrength"),
    ItemModel(title: "ShoulderSlimStrength", image: "ShoulderSlimStrength", value: 0.5, maxValue: 1.0, style01: true, minValue: -1, key: "shoulderSlimStrength"),
    ItemModel(title: "HipSlimStrength", image: "HipSlimStrength", value: 0, maxValue: 1.0, key: "bodySlimStrength"),
    ItemModel(title: "HeadSlim", image: "HeadSlim", value: 0, maxValue: 1.0, key: "headSlim"),
    ItemModel(title: "LegSlim", image: "LegSlim", value: 0, maxValue: 1.0, key: "legSlim")
  ];

  @override
  void onSelectIndex(int index) {
    // TODO: implement onSelectIndex
    super.onSelectIndex(index);
  }

  @override
  void onChangeValue(double value) {
    // TODO: implement onChangeValue
    super.onChangeValue(value);
    if(currentItem != null)
      TRTCCloud.sharedInstance().then((value) {
        value!._furenderValueChange(values: [
          MapEntry(currentItem!.key, currentItem!.value)
        ], method: type.rawValue);
      });
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    Map<String, dynamic> dic = {};
    Iterable<MapEntry<String, dynamic>> entrys = datas.map((e) => MapEntry(e.key, e.value));
    return dic..addEntries(entrys);
  }
}