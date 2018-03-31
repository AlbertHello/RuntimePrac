# RuntimePrac
对runtime的分析，要是觉得像那么回事儿，不妨给个星星，谢谢啦。

简书地址：https://www.jianshu.com/u/41bc05412192

###基本概念
Runtime 是一个底层的C语言的API，称为“运行时”。而OC在编译的时候并不知道要调用哪个方法函数，只有在运行的时候才知道调用的方法函数名称，来找到对应的方法函数进行调用。
###类与对象的实质
####对象的实质
1、对象是表示一个类的实例的结构体，是指向objc_object的结构体的指针。
2、objc_object这个结构体只有一个成员变量，即指向其类的isa指针。这
样，当我们向一个Objective-C对象发送消息时，runtime会根据
实例对象的isa指针找到这个实例对象所属的类。Runtime库会在类
的方法列表及父类的方法列表中去寻找与消息对应的selector指向
的方法，找到后即运行这个方法。
```
这是objc_object结构体源码
struct objc_object {
Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};
typedef struct objc_object *id;
```
####类的实质
1、类实际上是一个指向objc_class的结构体指针
```
struct objc_class {
Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
Class _Nullable super_class                              OBJC2_UNAVAILABLE; 父类
const char * _Nonnull name                               OBJC2_UNAVAILABLE; 类名
long version                                             OBJC2_UNAVAILABLE;  类的版本信息，默认为0
long info                                                OBJC2_UNAVAILABLE; 类信息，供运行期使用的一些位标识
long instance_size                                       OBJC2_UNAVAILABLE; 该类的实例变量大小
struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE; 该类的成员变量链表
struct objc_method_list * _Nullable * _Nullable methodLists   OBJC2_UNAVAILABLE;  方法定义的链表
struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;  方法缓存
struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;  协议链表
#endif

} OBJC2_UNAVAILABLE;
```
####元类
为了调用类方法，这个类的isa指针必须指向一个包含这些类方法的一个objc_class结构体。这就引出了meta-class的概念，meta-class中存储着一个类的所有类方法.所以，调用类方法的这个类对象的isa指针指向的就是meta-class,当我们向一个对象发送消息时，runtime会在这个对象所属的这个类的方法列表中查找方法；而向一个类发送消息时，会在这个类的meta-class的方法列表中查找。为了不让这种结构无限延伸下去，Objective-C的设计者让所有的meta-class的isa指向基类的meta-class，以此作为它们的所属类

## 用途
####1、获取类的成员变量列表、属性列列表、方法列表、协议列表
```
1、获取成员变量
Ivar *ivarList = class_copyIvarList([self class], &count);
for (unsigned int i=0; i<count; i++) {
Ivar myIvar = ivarList[i];
const char *ivarName = ivar_getName(myIvar);
NSLog(@"Ivar---->%@", [NSString stringWithUTF8String:ivarName]);
}
class_copyIvarList
ivar_getName
2、获取属性
unsigned int count;
//获取类的属性列表
objc_property_t *propertyList = class_copyPropertyList([self class], &count);
for (unsigned int i=0; i<count; i++) {
const char *propertyName = property_getName(propertyList[i]);
NSLog(@"property---->%@", [NSString stringWithUTF8String:propertyName]);
}
class_copyPropertyList
property_getName
3、方法
Method *methodList = class_copyMethodList([self class], &count);
for (unsigned int i=0; i<count; i++) {
Method method = methodList[i];
NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
}
class_copyMethodList
method_getName
4、协议
__unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
for (unsigned int i=0; i<count; i++) {
Protocol *myProtocal = protocolList[i];
const char *protocolName = protocol_getName(myProtocal);
NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
}
class_copyProtocolList
protocol_getName
```
####2、快速归档解档
```
1、原理就是通过runtime获取该类的所有成员变量或者属性，再进行一次性的归档或者解档。
2、该类需遵守NSCoding协议
1、归档
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
获得该类所有属性，利用kVC取出每个属性对应的值，最后归档每隔属性。
2、解档
unsigned int count = 0;
//获得指向该类所有属性的指针
objc_property_t *properties = class_copyPropertyList([self class], &count);//获取类属性列表
for (int i =0; i < count; i ++) {
objc_property_t property = properties[i];
const char *name = property_getName(property);//获取类属性的名称--->C语言的字符串
NSString *key = [NSString stringWithUTF8String:name];
[self setValue:[aDecoder decodeObjectForKey:key] forKeyPath:key];//解码每个属性,利用kVC取出每个属性对应的数值
}
获得该类所有属性，先解档每个属性，最后利用KVC取出每个属性的值。
```
####3、关联对象
```
分类原则上不允许添加属性，几遍添加了属性，编译器也不会自动生成getter和setter方法。这时候可利用runtime的关联作用手动实现属性的getter和setter方法。
绑定
//第一个参数：被关联对象
//第二个参数：一个静态常亮，这个key与第三个参数（关联对象）一一对应。这是只想关联对象的一个指针。
//第三个参数：关联对象
//第四个参数：关联策略
//这个动态绑定有点像可变字典
objc_setAssociatedObject(self, &kName, age, OBJC_ASSOCIATION_COPY_NONATOMIC);
取值
objc_getAssociatedObject(self, &kName);
```
####4、访问私有变量
```
Ivar ivar = class_getInstanceVariable([Model class], "_str1");
NSString * str1 = object_getIvar(model, ivar);
```
OC中没有真正意义上的私有变量和方法，要让成员变量私有，要放在.m文件中声明，不对外暴露。如果我们知道这个成员变量的名称，可以通过runtime获取成员变量，再通过getIvar来获取它的值
####5、交换方法method Swizzling
```
1、每个类都维护一个方法（Method）列表，Method则包含SEL和其对应IMP的信息，方法交换做的事情就是把SEL和IMP的对应关系断开，并和新的IMP生成对应关系
使用场景1、字典和数组在保存的对象为nil时会产生崩溃。可以写个分类对addObject：这个方法进行交换。交换成自定义的方法。
使用场景2、判断每次调用imageWithNamed：图片是否加载成功。
使用场景不限这两个，啥都行，根据业务来定。
2、代码写在类或者分类的+(void)load方法里。这个方法只是在类加载到内存的时候调用，只调用一次。
1、获取新旧两个方法
class_getInstanceMethod
2、交换连个方法的实现
method_exchangeImplementations
```
#### 6、消息的分发（函数调用的实质）
```
1、objc_msgSend 向一个类的实例发送消息，返回id类型数据。（这也是最常用的一个发送消息的方法）
2、objc_msgSend_stret 向一个类的实例发送消息，返回结构体类型数据。
3、objc_msgSendSuper 向一个类的实例的父类发送消息，返回id类型数据
4、objc_msgSendSuper_stret 向一个类的实例的父类发送消息，返回结构体类型的数据。
5、方法的调用过程：如果用实例对象调用实例方法，会到实例的isa指针指向的对象（也就是类对象）操作。如果调用的是类方法，就会到类对象的isa指针指向的对象（也就是元类对象）中操作。
1、首先，在相应操作的对象中的缓存方法列表中找调用的方法，如果找到，转向相应实现并执行
2、如果没找到，在相应操作的对象中的方法列表中找调用的方法，如果找到，转向相应实现执行
3、如果没找到，去父类指针所指向的对象中执行1，2.
4、以此类推，如果一直到根类还没找到，到崩溃之前还有三次拯救的机会，首先会调用动态分析方法resolveClassMethod或者resolveInstanceMethod
5、如果没有重写动态分析方法，会触发备用消息接收者方法，若没有处理就会调用消息转发的方法。要是都没有重写则崩溃
1、动态分析方法
1、调用未知类方法会触发+(BOOL)resolveClassMethod:(SEL)sel
2、调用未知实例方法会触发+(BOOL)resolveInstanceMethod:(SEL)sel
2、没有重写动态分析方法，会触发备用消息接收者方法，返回的对象不能是nil也不能self,如果返回的对象实现了(SEL)aSelector这个方法，那么返回的这个对象就成了消息的接收者，代替原来的对象执行那个方法。
触发-(id)forwardingTargetForSelector:(SEL)aSelector
3、触发消息转发方法-(void)forwardInvocation:(NSInvocation *)anInvocation 。forwardInvocation: 方法来对不能处理的消息做一些处理，也可以将消息转发给其他对象处理，而不抛出错误
6、动态添加方法
可在重写resolveClassMethod:和resolveInstanceMethod:的方法里使用。为找不到方法做防崩溃处理
class_addMethod：由四个参数
1、第一个是要添加方法的类
2、第二个是要添加的方法名
3、第三个是这个方法的实现函数的指针（值的注意的是，这个函数必须显式地把self和_cmd这两个参数写出来）
class_getMethodImplementation 可获取OC方法的指针。
4、第四个是方法的参数数组，在这里它是用的类型编码的方式进行表示的，因为方法一定含有self和_cmd这两个参数，所以字符数组的第二个和第三个字符一定是"@:",第一个字符代表返回值，这里为空用“v”来表示。
```

要是觉得还凑合，不妨给个星星。Thanks ! ! !









