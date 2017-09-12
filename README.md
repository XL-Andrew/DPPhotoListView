#DPPhotoListView

#截图展示


![竖列表展示方式](http://upload-images.jianshu.io/upload_images/4842734-7e0af7bda7086fd2.gif?imageMogr2/auto-orient/strip)  
![横列表展示方式](http://upload-images.jianshu.io/upload_images/4842734-26209ebb35eb71f7.gif?imageMogr2/auto-orient/strip)  
![图片选择器](http://upload-images.jianshu.io/upload_images/4842734-1f66536c2fcadcb7.gif?imageMogr2/auto-orient/strip)  
网络&本地图片列表展示器，图片浏览器功能整合。网络图片解析支持SDWebImage和UIImageView+YYWebImage，集成其中一个就可以，会自动选择，如果两个三方库都没有就会用自带方法Data转Image方式，最简单的备用方法，暂时不带cache功能。（现在很少有人会不用SD或者YYKit吧。。。😂😂😂）

#安装方法

直接拖入```DPPhotoListView```文件夹到工程中即可。

文件结构
DPPhotoListView
|____PhotoList (图片列表)
|____PhotoBrowser (图片浏览器)
|____Utils (工具类)
|____Resource (图片资源)

[Demo地址](https://github.com/XL-Andrew/DPPhotoListView)

#支持图片类型

* URL网络图片（支持）
* Base64编码格式图片（支持）
* 工程本地图片（支持）
* 本地图片路径（支持）
* NSData类型（支持）
* UIImage类型（支持）

#使用方法

####1. 导入头文件

```#import "DPPhotoLibrary.h"```  

####2.初始化图片展示列表

```
/**
 初始化方法

 @param frame frame
 @param lineNumber 一行展示几个cell
 @param lineSpacing cell上下左右间距
 @param dataSource 图片数据源（可以是本地图片，可以是网络图片，也可是图片data）
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame numberOfCellInRow:(NSUInteger)lineNumber lineSpacing:(CGFloat)lineSpacing dataSource:(NSMutableArray *)dataSource;
```

```
photoListView = [[DPPhotoListView alloc]initWithFrame:CGRectMake(0, 64 + 20, self.view.bounds.size.width, 100) numberOfCellInRow:3 lineSpacing:15 dataSource:数据源];
```

####3.设置代理

```
<DPPhotoListViewDelegate>

photoListView.delegate = self;
```

####4.代理方法

```
/**
 当前上传的图片

 @param base64String 返回Base64编码，可直接上传服务器
 */
- (void)choosePhotoWithPhotoBase64String:(NSString *)base64String;


/**
 删除某个图片

 @param index 删除的位置
 */
- (void)deletedPhotoAtIndex:(NSUInteger)index;
```

####5.设置列表滚动方向

```
/**
 设置滚动方向
 */

typedef enum : NSUInteger {
    DPPhotoScrollDirectionVertical,        //竖向
    DPPhotoScrollDirectionHorizontal       //横向
} DPPhotoScrollDirection;
```

####6.是否显示添加按钮

```
/**
 显示添加图片按钮
 
 default is NO
 */
@property (nonatomic, assign) BOOL showAddImagesButton;
```

####7.支持长按进入编辑模式

```
/**
 是否允许长按编辑图片
 
 default is NO
 */
@property (nonatomic, assign) BOOL allowLongPressEditPhoto;
```
####8.开启编辑

```
/**
 自动判断当前编辑状态,如果是未编辑就开启编辑,如果已开启编辑就结束编辑
 */
- (void)autoEditPhoto;

/**
 开始编辑
 */
- (void)startEditPhoto;

/**
 结束编辑
 */
- (void)endEditPhoto;
```
