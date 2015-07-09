//
//  ViewController.h
//  testudp
//
//  Created by weigou on 15/7/8.
//  Copyright (c) 2015年 weigou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mmViewController : UIViewController
-(IBAction)clicktosend:(id)sender;
- (void) createSocket : (NSString *)in_ser_addr ;
@end

#define PACKCNT 100
#define SENDDALAY_US (50 *1000)
#define PACKLEN 2400
#define PROXY_PORT 12321
#define A_PORT 33213
#define B_PORT 45482
#define PROXY_ADDR  "120.27.32.60"

#define check_c(x, y) if (0 > x) {printf("%s . %s . %d : ", __FILE__, __FUNCTION__, __LINE__); perror(y);}
