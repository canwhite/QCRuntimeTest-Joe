//
//  NSObject+Category.m
//  QCRuntimeTest
//
//  Created by EricZhang on 2018/3/7.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>
@implementation NSObject (Category)

char namekey;

-(void)setName:(NSString *)name{
    
    objc_setAssociatedObject(self, &namekey, name,OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

-(NSString *)name{
    
    return  objc_getAssociatedObject(self, &namekey);
    
}


@end
