//
//  Dog.m
//  PracAll
//
//  Created by WenDu3783 on 2018/2/23.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import "Dog.h"
#import "Cat.h"
#import <objc/message.h>

@implementation Dog //实例方法run和类方法bark没有实现。

-(void)dogEat{
    NSLog(@"小狗在吃东西");
}

+(void)dogWang{
    NSLog(@"小狗汪汪汪");
}



///运行时找不到方法时会调用以下的方法。崩亏之前有三个拯救崩溃的方法。
//也叫拦截调用方法，在找不到调用的方法而导致崩溃之前，重写下面的方法来处理这种找不到方法的错误，可以动态添加方法防止程序崩溃。
///拯救方法1.
//+(BOOL)resolveClassMethod:(SEL)sel{
//    //类方法找不到时的报错处理
//    NSLog(@"找不到的类方法名是%@",NSStringFromSelector(sel));
//    return [super resolveClassMethod:sel];//默认返回NO，再加上自己的处理后返回YES
//}
//+(BOOL)resolveInstanceMethod:(SEL)sel{
//    //实例方法找不到时的报错处理
//    NSLog(@"找不到的实例方法名是%@",NSStringFromSelector(sel));
//    if ([NSStringFromSelector(sel) isEqualToString:@"run"]) {
//        /**
//         class_addMethod这个方法有四个参数.
//         1、第一个是要添加方法的类，
//         2、第二个是要添加的方法名，
//         3、第三个是这个方法的实现函数的指针（值的注意的是，这个函数必须显式地把self和_cmd这两个参数写出来）
//         4、第四个是方法的参数数组，在这里它是用的类型编码的方式进行表示的，因为方法一定含有self和_cmd这两个参数，所以字符数组的第二个和第三个字符一定是"@:",第一个字符代表返回值，这里为空用“v”来表示。
//         */
//        class_addMethod(self, sel, (IMP)comeHereWhenNotFoundSelector, "v@:");//C方法
////        class_addMethod(self, sel,class_getMethodImplementation(self, @selector(replaceNotFoundSelector)), "v@:");//OC方法
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];//默认返回NO，再加上自己的处理后返回YES
//}
//这个c方法就是在找不到调用的方法时把那个找不到的方法的imp指针引导此处执行，避免崩溃。
//如果是OC方法，可调用class_getMethodImplementation:获取到方法的imp指针
void comeHereWhenNotFoundSelector(id self, SEL _cmd){//这个函数必须显式地把self和_cmd这两个参数写出来
    NSLog(@"因为找不到方法:%@",NSStringFromSelector(_cmd));
    NSLog(@"所以进入此方法：comeHereWhenNotFoundSelector 避免崩溃");
}
+(void)replaceNotFoundSelector{
    
    NSLog(@"所以进入此方法：replaceNotFoundSelector 避免崩溃");
}



//当resolveInstanceMethod和resolveClassMethod没有重写时，如果找不到方法runtime就会执行此方法，寻找消息备用接收者，返回的对象不能是nil也不能self,如果返回的对象实现了(SEL)aSelector这个方法，那么返回的这个对象就成了消息的接收者，代替原来的对象执行那个方法。
///拯救方法2。备用消息接收者
-(id)forwardingTargetForSelector:(SEL)aSelector{
    if ((aSelector == @selector(run)) || (aSelector == @selector(bark))) {
        return [[Cat alloc]init];//返回备用消息接收者
    }
    return [super forwardingTargetForSelector:aSelector];//返回 nil 或者 self，则会计入消息转发机制(forwardInvocation:)，否则将向返回的对象重新发送消息。
}





///拯救方法3。消息转发
//实现 forwardInvocation: 方法来对不能处理的消息做一些处理，也可以将消息转发给其他对象处理，而不抛出错误
-(void)forwardInvocation:(NSInvocation *)anInvocation{
    //在这里对不能处理的消息做处理
    if (anInvocation.selector == @selector(run)) {
        Cat *cat=[[Cat alloc]init];
        if ([cat respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:cat];//把消息转发给其他的对象。forwardInvocation可以将消息同时转发给任意多个对象
        }else{
            [super forwardInvocation:anInvocation];
        }
    }
}

//methodSignatureForSelector用于描述被转发的消息，系统会调用methodSignatureForSelector:方法，尝试获得一个方法签名。如果获取不到，则直接调用doesNotRecognizeSelector抛出异常。如果能获取，则返回非nil：创建一个 NSlnvocation 并传给forwardInvocation:。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if(aSelector == @selector(run)){
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return nil;
}




@end
