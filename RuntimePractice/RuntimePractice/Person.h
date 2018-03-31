//
//  Person.h
//  PracAll
//
//  Created by WenDu3783 on 2018/2/9.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Person : NSObject<NSCoding>

@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *sex;
@property(nonatomic,copy) NSString *old;
@property(nonatomic,copy) NSString *young;
-(void)peopleRun;
//-(void)jump;

@end
