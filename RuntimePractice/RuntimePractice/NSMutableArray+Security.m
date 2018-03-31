//
//  NSMutableArray+Security.m
//  PracAll
//
//  Created by 王启正 on 2018/2/22.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import "NSMutableArray+Security.h"
#import <objc/runtime.h>
@implementation NSMutableArray (Security)


//此分类的作用就是防止可变数组在添加object的时候因为object为nil而产生崩溃。

/**
 *  总结：
 1、+ (void)load与+ (void)initialize的区别：
     + (void)load：当类加载进内存的时候调用，而且不管有没有子类，都只会调用一次，在main函数之前调用，
     用途：
     (1)、：可以新建类在该类中实现一些配置信息
     (2)、：runtime交换方法的时候，因为只需要交换一次方法，所有可以在该方法中实现交换方法的代码，用于只实现一次的代码
 
 2、+ (void)initialize：当类被初始化的时候调用，可能会被调用多次，若是没有子类，则只会调用一次，若是有子类的话，该方法会被调用多次，若是子类的继承关系，先会调用父类的+ (void)initialize方法，然后再去调用子类的+ (void)initialize方法
     用途：
     (1)、：在设置导航栏的全局背景的时候，只需要设置一次，可以重写该方法设置，最好是在该方法判断子类，若是自己，则实现设置全局导航栏的方法，若不是自己则跳过实现。
     (2)、：在创建数据库代码的时候，可以在该方法中去创建，保证只初始化一次数据库实例，也可以用dispatch或是懒加载的方法中初始化数据库实例，也能保证只初始化一次数据库实例。其中也可以在+ (void)initialize方法中用dispatch也能保证即使有子类也只会初始化一次
 
 3、：交换方法：
     获取某个类的方法：class_getClassMethod：第一个参数：获取哪个类的方法 第二个参数：SEL:获取哪个方法
 
                 Method imageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
 
     //交换方法的实现
     method_exchangeImplementations(imageNamedMethod, xmg_imageNamedMethod);
 
 也就是外部调用xmg_imageNamed就相当于调用了imageNamed，调用imageNamed就相当于调用了xmg_imageNamed
 
 4、：在分类中,最好不要重写系统方法,一旦重写,把系统方法实现给干掉，因为分类不是继承父类，而是继承NSObject，super没有该类的方法，所以就直接覆盖掉了父类的行为
 
 */

+(void)load{
    //该方法在类或者分类第一次加载到内存是自动调用。
    //获取两个方法的Method
    //获取原有的方法
    //__NSArrayM 是NSMutableArray真正的类型。
    Method oldMethod=class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:));
    //获取自己定义的方法
    Method newMethod=class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(newMethod_addObject:));
    //交换
    method_exchangeImplementations(oldMethod, newMethod);
}
//自己定义的方法
-(void)newMethod_addObject:(id)object{
    if (object != nil) {
        [self newMethod_addObject:object];//注意这里不能再调用系统的addObject：的方法。
    }
}



@end
