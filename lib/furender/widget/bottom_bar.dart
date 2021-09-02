/*
 *  Copyright (C), 2015-2021
 *  FileName: bottom_bar
 *  Author: Tonight丶相拥
 *  Date: 2021/8/26
 *  Description: 
 **/

part of furender;

class _BottomBar extends StatelessWidget {
  _BottomBar({
    required this.datasource,
    required this.blueColor,
    required this.onTap
  });
  final _FuRenderDatasource datasource;
  final Color blueColor;
  final void Function(FuRenderModelAbstract) onTap;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // TODO: implement build
    return Container(
        color: Colors.black.withOpacity(0.6),
        height: 49,
        child: Column(
            children: [
              Container(
                  height: 1,
                  width: size.width,
                  color: Color.fromARGB(255, 229, 229, 229).withOpacity(0.2)
              ),
              Expanded(child: Row(
                  children: datasource.datas.map((e) {
                    return Expanded(
                        child: InkWell(
                            onTap: ()=> onTap(e),
                            child: Container(
                                alignment: Alignment.center,
                                child: Text(e.type.rawValue, style: TextStyle(
                                    fontSize: 15,
                                    color: e.type == datasource.type ? blueColor : Colors.white
                                ))
                            )
                        )
                    );
                  }).toList()
              ))
            ]
        )
    );
  }
}