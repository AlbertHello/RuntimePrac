
//
//  Person.m
//  PracAll
//
//  Created by WenDu3783 on 2018/2/9.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>


@implementation Person
//方法实现
-(void)peopleRun{
    NSLog(@"本类方法----人在跑");
}
//-(void)jump{
//    NSLog(@"本类方法----跳跃");
//}


///runtime 快速归解档
//归档
-(void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    //获得该类所有属性
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);//获得其属性的名称--->C语言的字符串
        NSString *key = [NSString stringWithUTF8String:name];
        // 编码每个属性,利用kVC取出每个属性对应的数值
        [aCoder encodeObject:[self valueForKeyPath:key] forKey:key];
    }
}

//解档
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super init]) {
        unsigned int count = 0;
        //获得指向该类所有属性的指针
        objc_property_t *properties = class_copyPropertyList([self class], &count);//获取类属性列表
        for (int i =0; i < count; i ++) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);//获取类属性的名称--->C语言的字符串
            NSString *key = [NSString stringWithUTF8String:name];
            [self setValue:[aDecoder decodeObjectForKey:key] forKeyPath:key];//解码每个属性,利用kVC取出每个属性对应的数值
        }
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@,%@,%@,%@",self.name,self.sex,self.old,self.young];
}
    
    
@end
    
