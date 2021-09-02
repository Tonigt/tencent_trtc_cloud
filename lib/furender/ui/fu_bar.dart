/*
 *  Copyright (C), 2015-2021
 *  FileName: fu_bar
 *  Author: Tonight丶相拥
 *  Date: 2021/8/24
 *  Description: 
 **/

part of furender;

class FuRenderBar extends StatefulWidget {
  @override
  createState()=> _FuRenderBarState();
}

class _FuRenderBarState extends State<FuRenderBar> with TickerProviderStateMixin {

  late final _FuRenderDatasource _datasource;
  late final AnimationController _positionController;
  late final Animation<double> _tween;
  late final AnimationController _opacityController;
  late final Animation<double> _opacity;
  bool _isOffstage = true;
  final Color blueColor = Color.fromARGB(255, 94, 199, 254);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _datasource = FuRenderManager.manager._datasource..updateState = setState;
    _positionController = AnimationController(vsync: this, duration: Duration(
      milliseconds: 300
    ))..addListener(() {
      print("the state is: ${_positionController.status}  -- ");
      if (_positionController.isDismissed) {
        _isOffstage = true;
      }
      setState(() {});
    });
    _tween = Tween(begin: 0.0, end: 49.0).animate(_positionController);
    _opacityController = AnimationController(vsync: this, duration: Duration(
      milliseconds: 300
    ));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(_opacityController);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var currentItem = _datasource.currentSettingItem?.currentItem;
    return Container(
      height: 195,
      child: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          Positioned(child: Offstage(
            offstage: _isOffstage,
            child: Opacity(
              opacity: _opacity.value,
              child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Offstage(
                            offstage: !_datasource.hasSlider,
                            child: _Slider(currentItem, onChanged: (value){
                              _datasource.onChangeValue(value);
                            }, onChangeEnd: (value) => _datasource.onChangeEnd(value))
                          )
                        ),
                        SizedBox(
                          height: 98,
                          child: Row(
                            children: [
                              Offstage(
                                offstage: !(_datasource.currentSettingItem?.recover ?? false),
                                child: _ResetButton((){
                                  _datasource.itemValueReset();
                                }),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _SourceWidegt(_datasource.currentSettingItem,
                                    blueColor)
                              ),
                              SizedBox(width: 8)
                            ]
                          )
                        )
                      ]
                  )
              )
            )
          ), bottom: _tween.value, left: 0, right: 0, height: 146),
          Positioned(child: _BottomBar(
            datasource: this._datasource,
            blueColor: blueColor,
            onTap: (e){
              if (_positionController.isAnimating)
                return;
              if (_datasource.type != e.type && !_isOffstage){
                _datasource.onSelect(e.type);
                return;
              }
              if (_positionController.status == AnimationStatus.completed) {
                _positionController.reverse();
                _opacityController.reverse();
                _datasource.onBarHide();
              }else {
                _isOffstage = false;
                _positionController.forward();
                _opacityController.forward();
                _datasource.onSelect(e.type);
              }
            },
          ), left: 0, right: 0, bottom: 0)
        ]
      )
    );
  }

  /// 更新状态
  void updateState(){
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _datasource.onPageDispose();
  }
}
