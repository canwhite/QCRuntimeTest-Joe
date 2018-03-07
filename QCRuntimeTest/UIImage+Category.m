//
//  UIImage+Category.m
//  QCRuntimeTest
//
//  Created by EricZhang on 2018/3/7.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import "UIImage+Category.h"
#import <objc/runtime.h>
@implementation UIImage (Category)


//只要让其执行一次方法交换语句，load再合适不过了
//调换以后我们调用系统方法，就会转换成我们的自写方法
+ (void)load {
    
    // 获取两个类的类方法
    Method m1 = class_getClassMethod([UIImage class], @selector(imageNamed:));
    Method m2 = class_getClassMethod([UIImage class], @selector(xh_imageNamed:));
    // 开始交换方法实现
    method_exchangeImplementations(m1, m2);
}

+ (UIImage *)xh_imageNamed:(NSString *)name {
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0) {
        // 如果系统版本是7.0以上，使用另外一套文件名结尾是‘_os7’的扁平化图片
        name = [name stringByAppendingString:@"_os7"];
    }
    return [UIImage xh_imageNamed:name];
}

@end
