//
//  RTDogTest.h
//  QCRuntimeTest
//
//  Created by EricZhang on 2018/3/5.
//  Copyright © 2018年 BYX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTDogTest : NSObject

//property
@property(nonatomic,strong) NSString * age;

@property(nonatomic,strong) NSString *name;


//method
-(void)dogIsBarking;//方法2测试
-(void)sendCMessage:(NSString *)message;//方法3，4测试


@end
