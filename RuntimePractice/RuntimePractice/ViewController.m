//
//  ViewController.m
//  RuntimePractice
//
//  Created by 隔壁老王 on 2018/3/31.
//  Copyright © 2018年 隔壁老王. All rights reserved.
//

#import "ViewController.h"
#import "Dog.h"
#import "Person.h"
#import <objc/runtime.h>


@interface ViewController ()

@property(nonatomic, strong)NSMutableArray      *dataSource;
@property(nonatomic, strong)NSMutableDictionary *sortedDict;
@property(nonatomic, strong)NSMutableArray      *sortedArray;
@property(nonatomic, strong)NSMutableArray      *lettersArray;
@property(nonatomic, strong)UITableView         *tbleView;
@property(nonatomic, strong)UIWebView           *webVie;
@property(nonatomic, copy  )NSString            *demoStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor brownColor];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    [self function1];
//    [self function2];
    [self function3];
//    [self function4];
}

///runtime 的用途1---获取一个类的成员变量列表、属性列表、方法列表、协议列表
-(void)function1{
    unsigned int count;
    //获取类的属性列表
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property---->%@", [NSString stringWithUTF8String:propertyName]);
    }
    //获取类的方法列表
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
    }
    
    //获取类的成员变量列表
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Ivar myIvar = ivarList[i];
        const char *ivarName = ivar_getName(myIvar);
        NSLog(@"Ivar---->%@", [NSString stringWithUTF8String:ivarName]);
    }
    
    //获取类的协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Protocol *myProtocal = protocolList[i];
        const char *protocolName = protocol_getName(myProtocal);
        NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
    }
}

///runtime的用途2---快速解档归档
-(void)function2{

    Person *person=[[Person alloc] init];
    person.name=@"111";
    person.sex=@"222";
    person.old=@"333";
    person.young=@"444";
    
    // 归档，调用归档方法
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"person.plist"];
    BOOL success = [NSKeyedArchiver archiveRootObject:person toFile:filePath];
    if (success) {
        NSLog(@"归档成功");
    }else{
        NSLog(@"归档失败");
    }
    // 解档，调用反归档方法
    Person *per = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSLog(@"per==%@",per);
    
}

///runtime的用途3---方法交换
-(void)function3{
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    [arr addObject:@"111"];
    [arr addObject:@"222"];
    [arr addObject:nil];//数组添加nil会产生崩溃。在NSMutableArray的分类中利用的runtime的method swizzling 交换方法，就防止了崩溃。
    
    NSLog(@"%@",arr);
    
    
}


-(void)function4{
    Dog *dog=[[Dog alloc]init];
    [dog run];//调用未实现的实例方法方法。如果不重写拯救方法，则崩溃-[Dog dogRun]: unrecognized selector sent to instance 0x604000014c90
    
//    [Dog bark];
    
}

















@end
