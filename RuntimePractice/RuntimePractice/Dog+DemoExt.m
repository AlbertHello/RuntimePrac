//
//  Dog+DemoExt.m
//  RuntimePractice
//
//  Created by 王启正 on 2019/6/5.
//  Copyright © 2019 隔壁老王. All rights reserved.
//

#import "Dog+DemoExt.h"
#import <objc/runtime.h>

@implementation Dog (DemoExt)

/*收到警告：意思是没有实现color的getter和setter方法。其实也没有生成ivar实例变量。
 所以无法通过getter和setter方法操作nickName，也不能直接访问_nickName
 
 Property 'nickName' requires method 'nickName' to be defined - use @dynamic or provide a method implementation in this category
 
 Property 'nickName' requires method 'setNickName:' to be defined - use @dynamic or provide a method implementation in this category
 */

- (NSString *)nickName{
    //取值
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNickName:(NSString *)nickName{
    //第一个参数：被关联对象
    //第二个参数：一个静态常亮，这个key与第三个参数（关联对象）一一对应。这是指向关联对象的一个指针，这里用@selector(nickName)来用作 const void *key 的指针
    //第三个参数：关联对象
    //第四个参数：关联策略
    //这个动态绑定有点像可变字典
    objc_setAssociatedObject(self, @selector(nickName), nickName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
/**
 可以看到实现了getter和setter之后已经能够看到了nickName和setNickName了，但是仍然没有ivar的_nickName，这个是当然的，系统没有实现我们也没添加，所谓的关联是我们通过const char的key(指针)来访问关联的对象的，所以关联之后我们只能通过getter和setter方法去操作，不能直接用ivar _nickName访问！！！
 上面是把我们看到的现象进行分析，思考其为什么会有这样的现象呢？分类并不会改变原有类的内存分布的情况，它是在运行期间决定的，此时内存的分布已经确定，若此时再添加实例会改变内存的分布情况，这对编译性语言是灾难，是不允许的。反观扩展(extension)，作用是为一个已知的类添加一些私有的信息，必须有这个类的源码，才能扩展，它是在编译期生效的，所以能直接为类添加属性或者实例变量。
 
 
 
 原文参考：https://blog.csdn.net/lixuezhi86/article/details/81713166
 */

@end
