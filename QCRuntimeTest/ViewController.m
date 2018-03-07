//
//  ViewController.m
//  QCRuntimeTest
//
//  Created by EricZhang on 2018/3/5.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+Category.h"//想象一下自己写的button拓展类
#import "RTDogTest.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
//    [self test2_2];

//    [self test6_1];
    
    [self test6_2];
    
}



#pragma mark -  方法一:objc_msgSend调用本类方法
//需要表头
-(void)Test1{
    
    //调用无参无返回值方法
    ((void (*)(id, SEL))objc_msgSend)(self, @selector(catIsBarking));
    
    
    //调用有参，无返回值方法
    ((void (*)(id,SEL,NSString *))objc_msgSend )(self,@selector(itIs:),@"饿了");
    
    
    //调用有参，有返回值的方法
    NSString *returnStr  =  ( (NSString *(*)(id,SEL,NSString *)) objc_msgSend)(self,@selector(soDo:),@"小鱼干");
    NSLog(@"%@",returnStr);
    

}
-(void)catIsBarking{
    
    NSLog(@"小猫喵喵的叫🐱");
    
}
-(void)itIs:(NSString *)str{
    
    NSLog(@"它是%@",str);
}

-(NSString *)soDo:(NSString *)str{
    
    return [NSString stringWithFormat:@"喂它:%@",str];
}






#pragma mark - 方法二:(黑魔法)objc_msgSend调用其他类方法
/*
 黑魔法
 为什么我们不直接调用方法了，要学习这样的运行时方法？
 因为当你们的APP是个很大的项目时，需要多人协作，各自模块（framework，lib.a格式）各自开发人员去开发。为了减少各自模块之前的耦合度，实现分离，此时上面的运行时方法，就是很好的解决方案。
 */

-(void)test2_1{

    //得到了RTDogTest类
    Class class =  NSClassFromString(@"RTDogTest");
    //得到类中方法名
    SEL action = NSSelectorFromString(@"dogIsBarking");
    //得到类的目的是为了初始化类，再堆中创建对象，以便能够使用
    id dogTest  = [class new];

    //先判断，防止找不到方法的时候崩掉，多个参数的话和上边本类的类似
    if ([dogTest respondsToSelector:action]) {
        /*
         //这种方法好像最多可以支持两个参数
         [dogTest performSelector:action withObject:nil];
         */
        ((void (*)(id, SEL))objc_msgSend)(dogTest, action);
    }
    

}

-(void)test2_2{
    
    Class class =  NSClassFromString(@"RTDogTest");
    //得到类中方法名
    SEL action = NSSelectorFromString(@"dogIsBarking");
    //得到类的目的是为了初始化类，再堆中创建对象，以便能够使用
    id dogTest  = [class new];
    [dogTest performSelector:action];

    
}




#pragma mark - 方法三：class_replaceMethod方法替换，本类本类替换，本类和其他类替换

/*
 //修改类的Method IMP
 class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
 */


//测试本类和本类的替换
-(void)test3_1{
    

    //如果调用本类方法A，转而调用本类方法B，通过中间方法进行参数传递
    class_replaceMethod([self class], @selector(sendAMessage:), (IMP)changeAtoB, NULL);

    ((void (*)(id,SEL,NSString *))objc_msgSend)(self,@selector(sendAMessage:),@"发送sendAMessage");


}

//测试本类和其他类的替换
-(void)test3_2{
    
    //调用本类方法B,转而调用其他类方法C，通过中间方法进行参数传递
    class_replaceMethod([self class], @selector(sendBMessage:), (IMP)changeBtoC, NULL);
    [self sendBMessage:@"我调用了方法B"];

}



-(void)sendAMessage:(NSString *)message{
    
    NSLog(@"A_Message:%@",message);
}

-(void)sendBMessage:(NSString *)message{
    
    NSLog(@"B_Message:%@",message);
    
}


//如果是方法A，转而调用本类方法B
ViewController *changeAtoB(ViewController *SELF ,SEL _cmd ,NSString *message){
    
    if ([NSStringFromSelector(_cmd) isEqualToString:@"sendAMessage:"]) {
        
        //将方法进行替换
        [SELF sendBMessage:message];
        
    }
    return SELF;
}



//如果是方法B，转而调用RTDogTest类中方法C
Class changeBtoC(Class  OTHER, SEL _cmd, NSString *message){
    
    if ([NSStringFromSelector(_cmd) isEqualToString:@"sendBMessage:"]) {
        
        
        Class class = NSClassFromString(@"RTDogTest");
        
        SEL action = NSSelectorFromString(@"sendCMessage:");
        
        id dogC = [class new];
        
        if ([dogC respondsToSelector:action]) {
            
            ((void (*)(id,SEL,NSString *))objc_msgSend)(dogC,action,message);
            
        }
    }
    return OTHER;
}



#pragma mark - 方法四：method_exchangeImplementations方法替换,一般在多态中使用，重置原生类方法,test4_2中可见
/*


 
 
 //交换2个方法中的IMP
 void method_exchangeImplementations(Method m1, Method m2)
 
 //获取类的某个实例方法
 Method class_getInstanceMethod(Class aClass, SEL aSelector);

 //向类中添加Method(了解)
 BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)

 
 */
+(void) load{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        /*
         class_getInstanceMethod 得到类的实例方法
         class_getClassMethod 得到类的类方法
         */
        
        //        Method m1 = class_getClassMethod([ViewController class], @selector(test4text1));
        //        Method m2 = class_getClassMethod([ViewController class], @selector(test4test2));
        
        Method m1 = class_getInstanceMethod([self class], @selector(test4text));
        Method m2 = class_getInstanceMethod([self class], @selector(prefix_test4test));
        
        method_exchangeImplementations(m1, m2);
        
    });
    
}

/*
 其他提示
 
 +load
 
 Swizzling 的处理，在类的 +load 方法中完成。
 
 因为 +load 方法会在类被添加到 OC 运行时执行，保证了 Swizzling 方法的及时处理。
 
 dispatch_once
 
 Swizzling 的处理，dispatch_once 中完成。保证只执行一次。
 
 prefix
 
 Swizzling 方法添加前缀，避免方法名称冲突。
 */
-(void)test4_1{
    
    
    [self test4text];

}

-(void)test4_2{
    /*
      主要可以用作拦截系统方法，我们在UIImage+Category.h 中可以看到
     */
}


-(void)test4text{
    
    NSLog(@"%@",@"我就测试一下不说话");

}
-(void)prefix_test4test{
    
    NSLog(@"%@",@"我就测试一下不说话222");
    
}



#pragma mark - 方法五：NSObject+Category.h 分类中加入属性


/*
 
 我们知道category中是不能加入属性的，只能加入方法，我们在NSObject+Category.h中实现属性的加入
 
 */

-(void)test5{
    
    //pre:记得倒入头文件
    
    NSObject *object = [NSObject new];
    object.name = @"测试";
    NSLog(@"%@",object.name);
    
    /*
     注意：
     还有一个断开所有关联的方法
     objc_removeAssociatedObjects(self);
     
     */
    
    
    

}


#pragma mark - 方法六：class_copyMethodList 获取类的属性和方法列表,这个是写model解析的主要方法，之后我会写一个QCModel上传，用作model解析，欢迎关注

//获取属性列表
-(void)test6_1{
    
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([RTDogTest class], &count);
    
    for (unsigned int i = 0; i <count ; i ++) {
        //在这里我们获取属性
        const char *propertyName = property_getName(propertyList[i]);
        NSLog(@"property:%@",[NSString stringWithUTF8String:propertyName]);
//        2018-03-07 17:39:23.497405+0800 QCRuntimeTest[4776:282651] property:age
//        2018-03-07 17:39:23.497544+0800 QCRuntimeTest[4776:282651] property:name
    }
}

//获取方法列表
-(void)test6_2{
    
    unsigned int count ;
    Method * methodList = class_copyMethodList([RTDogTest class], &count);
    
    for (unsigned int i = 0; i <count ; i ++) {
        
        Method method = methodList[i];
        NSLog(@"method:%@",NSStringFromSelector(method_getName(method)));
        //注意一下method_getName
    }
    
}
















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
