//
//  NSMutableArray+Security.h
//  PracAll
//
//  Created by 王启正 on 2018/2/22.
//  Copyright © 2018年 王启正. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Security)

@end
/**
 
 当系统提供的控件不能满足我们的需求的时候，我们可以
 
 1：通过继承系统控件，重写系统的方法，来扩充子类的行为（super的调用三种情况）
 2：当需要为系统类扩充别的属性或是方法的时候，与哪个类有关系，就为哪个类创建分类。
 3：利用runtime修改系统的类，增加属性，交换方法，消息机制，动态增加方法
 
 解决方法：
 1：重写系统的方法：新建类继承系统的类，重写系统的方法（要是覆盖父类的行为就不需要调用super，或是在super方法之下调用:在保留父类super原有的行为后，扩充子类自己的行为，代码写在super之上，可以修改super要传递的参数，例如重写setframe，要是想保留父类的行为就不要忘记调用super）。弊端：需要在每个类中都需要引入头文件
 2：写分类：为哪个系统的类扩充属性和方法，就为哪个类写分类
 3：利用runtime底层的实现来修改或是访问系统的类：增加属性，交换方法，消息机制，动态增加方法
 
 */
