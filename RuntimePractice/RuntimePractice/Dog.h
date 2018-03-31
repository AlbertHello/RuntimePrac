//
//  Dog.h
//  PracAll
//
//  Created by WenDu3783 on 2018/2/23.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dog : NSObject


@property(nonatomic,copy)NSString *name;

-(void)run;//此方法只声明不实现，编译阶段不会报错，运行时调用此方法就会报错。
-(void)dogEat;//此方法正常实现
+(void)bark;//次类方法不实现
+(void)dogWang;//类方法


@end
