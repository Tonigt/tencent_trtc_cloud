/*
 *  Copyright (C), 2015-2021
 *  FileName: source_widget
 *  Author: Tonight丶相拥
 *  Date: 2021/8/26
 *  Description: 
 **/

part of furender;

class _SourceWidegt extends StatelessWidget {
  _SourceWidegt(this.entity, this.blueColor);
  final FuRenderModelAbstract? entity;
  final Color blueColor;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.separated(itemBuilder: (_, index)  {
      var model = entity!.datas[index];
      var selectIndex = entity!.index;
      bool atIndex = selectIndex == index;
      var image = GestureDetector(
        child: _FuRenderImageView(model.image + ".png"),
        onTap: (){
          entity?.onSelectIndex(index);
        },
      );
      if (!model.hasStatus) {
        if (atIndex) {
          return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: blueColor)
              ),
              child: image
          );
        }
        return image;
      }

      int status = 0;
      if (atIndex) {
        if (model.valueIsNotDefault) {
          status = 3;
        }else {
          status = 2;
        }
      }else if (model.valueIsNotDefault) {
        status = 1;
      }

      return GestureDetector(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FuRenderImageView(model.image + "_$status.png"),
                SizedBox(
                    height: 8
                ),
                Text(model.title, style: TextStyle(
                    fontSize: 13,
                    color: atIndex ? blueColor : Colors.white
                ))
              ]
          ),
          onTap: (){
            entity?.onSelectIndex(index);
          }
      );
    },
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemCount: entity?.datas.length ?? 0,
        scrollDirection: Axis.horizontal);
  }
}