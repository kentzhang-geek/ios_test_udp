//
//  setIPView.m
//  testudp
//
//  Created by  on 15/7/9.
//  Copyright (c) 2015年 weigou. All rights reserved.
//

#import "setIPView.h"

#import "ViewController.h"
extern mmViewController *thisview;

@interface setIPView ()
-(IBAction)set_and_return:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *server_ip;
@end

@implementation setIPView
-(IBAction)set_and_return:(id)sender{
    if (nil != thisview) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[NSUserDefaults standardUserDefaults] setValue: self.server_ip.text forKey:@"sip"];
            [thisview performSelectorInBackground:@selector(createSocket:) withObject:[self.server_ip text]];
            //[self createSocket:addr];
        });
    }
    [self dismissViewControllerAnimated:YES completion:^(void){
        return;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * serverip = [[NSUserDefaults standardUserDefaults] stringForKey:@"sip"];
    if (nil != serverip) {
        [self.server_ip setText:serverip];
    }
    else {
        [self.server_ip setText:@""];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
