//
//  mybutton.m
//  testudp
//
//  Created by  on 15/7/9.
//  Copyright (c) 2015年 weigou. All rights reserved.
//

#import "mybutton.h"
#import "ACPButton.h"
@import UIKit;

@implementation mybutton
-(void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    [self setStyleType:ACPButtonGrey];
    [self setFlatStyleType:ACPButtonBlue];
#if 0
    CALayer * downButtonLayer = [self layer];
    [downButtonLayer setMasksToBounds:YES];
    [downButtonLayer setCornerRadius:10.0];
    [downButtonLayer setBorderWidth:1.0];
    [downButtonLayer setBorderColor:[[UIColor grayColor] CGColor]];
#endif
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
