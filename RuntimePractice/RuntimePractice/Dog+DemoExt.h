//
//  Dog+DemoExt.h
//  RuntimePractice
//
//  Created by 王启正 on 2019/6/5.
//  Copyright © 2019 隔壁老王. All rights reserved.
//

#import "Dog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Category的定义
 typedef struct objc_category *Category;
 
 struct objc_category {
 char * _Nonnull category_name                            OBJC2_UNAVAILABLE;
 char * _Nonnull class_name                               OBJC2_UNAVAILABLE;
 struct objc_method_list * _Nullable instance_methods     OBJC2_UNAVAILABLE;
 struct objc_method_list * _Nullable class_methods        OBJC2_UNAVAILABLE;
 struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
 }
 
 Category是一个结构体指针类型objc_category
 与类的定义相比结构体中缺少了struct objc_ivar_list * _Nullable ivars成员，也就是说没有ivar数组
 
 */

//分类原则上不允许添加属性，即便添加了属性，编译器也不会自动生成ivar实例变量、getter、setter方法。这时可利用runtime的关联作用手动实现属性的getter和setter方法。
@interface Dog (DemoExt)

@property(nonatomic,copy)NSString *nickName;

@end

NS_ASSUME_NONNULL_END
