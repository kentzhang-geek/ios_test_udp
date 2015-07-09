//
//  ViewController.m
//  testudp
//
//  Created by weigou on 15/7/8.
//  Copyright (c) 2015年 weigou. All rights reserved.
//
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>

#import "ViewController.h"

@interface mmViewController ()
@property (weak, nonatomic) IBOutlet UILabel *PeerReturn;
@property (weak, nonatomic) IBOutlet UIButton *go_button;
@property (weak, nonatomic) IBOutlet UITextField *LocalSend;

@end

NSString * showdata = nil;
mmViewController *thisview = nil;
int udpfd = -1;
static unsigned char poweron = 0;

static void * recv_thread(void *p) {
    int ret;
    UILabel *display = nil;
    NSString *data = nil;
    char buf[PACKLEN];
    while (poweron) {
        bzero(buf, PACKLEN);
        ret = recvfrom(udpfd, buf, PACKLEN, 0, NULL, 0);
        showdata = [NSString stringWithUTF8String:buf];
        //[thisview.PeerReturn setText:showdata];
        if (nil != thisview) {
            [thisview.PeerReturn performSelectorOnMainThread:@selector(setText:) withObject:showdata waitUntilDone:YES];
        }
    }
    pthread_exit(NULL);
    return NULL;
}

@implementation mmViewController
{
    struct sockaddr_in hostaddr, peeraddr;
    socklen_t peerlen;
    pthread_t recver;
    NSTimer * timer;
}
@synthesize PeerReturn, LocalSend;

- (void) createSocket : (NSString *)in_ser_addr {
    int sockfd = -1;
    int on = 1;
    int ret;
    int siret = 0;
    char buf[PACKLEN];
    char *server_addr = [in_ser_addr UTF8String];
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (0 > sockfd) {
        perror("SOCKET");
        return;
    }
    ret = setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    if (0 > ret) {
        perror("SET SOCK");
        return;
    }
    
    bzero(&hostaddr, sizeof(hostaddr));
    bzero(&peeraddr, sizeof(peeraddr));
    bzero(&peerlen, sizeof(peerlen));
    
    /* 设置服务器地址 */
    peeraddr.sin_port = htons(PROXY_PORT);
    peeraddr.sin_family = AF_INET;
    inet_pton(AF_INET, server_addr, &(peeraddr.sin_addr));
    
    /* Reg ip to server */
    siret = (int)sendto(sockfd, buf, 5, 0, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
    if (0 > siret)	{
        perror("SEND");
    }
    siret = (int)recvfrom(sockfd, buf, PACKLEN, 0, (struct sockaddr *)&peeraddr, &peerlen);
    if (sizeof(peeraddr) != siret) {
        perror("Get Peer");
    }
    memcpy(&peeraddr, buf, sizeof(peeraddr));
    printf("Get Peer %s : %d\n", inet_ntoa(peeraddr.sin_addr), ntohs(peeraddr.sin_port));
    //ret = connect(sockfd, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
    udpfd = sockfd;
    
    ret = pthread_create(&recver, NULL, recv_thread, NULL);
    
    [thisview performSelectorOnMainThread:@selector(alertConnect) withObject:nil waitUntilDone:NO];
    /* main send loop */
#if 0
    while (1) {
        bzero(buf, PACKLEN);
        ret = read(1, buf, PACKLEN);
        siret = sendto(udpfd, buf, strlen(buf), 0, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
    }
#endif
    
    return ;

}

- (void) alertConnect {
    [[[UIAlertView alloc] initWithTitle:@"已连接服务器" message:@"已连接上服务器" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil] show];

}

- (void) updateString {
    //[self.PeerReturn setText:showdata];
    [self.PeerReturn setNeedsDisplay];
    [self.view setNeedsDisplay];
    return;
}

- (void) clearText {
    [self clicktosend:self];
    [LocalSend setText:@""];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    thisview = self;
    udpfd = -1;
    poweron = 1;
    //[self.view insertSubview:self.go_button atIndex:self.go_button.tag];
    [self.LocalSend addTarget:self action:@selector(clearText) forControlEvents:UIControlEventEditingDidEndOnExit];

    //timer = [NSTimer scheduledTimerWithTimeInterval :0.01 target:self selector:@selector(updateString) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clicktosend:(id)sender  {
    int ret;
    NSString * data = nil;
    if (0 < [[self.LocalSend text] length]) {  // 有数据输入
        data = [self.LocalSend text];
        data = [data stringByAppendingString:@"\n"];
        if (0 < udpfd) {
            ret = (int)sendto(udpfd, [data UTF8String], [[data dataUsingEncoding:NSUTF8StringEncoding] length], 0, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
        }
        else {
                UIAlertView * note_invailable = [[UIAlertView alloc] initWithTitle:@"未连接服务器" message:@"没有连接上服务器" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [note_invailable show];
        }
        [self.LocalSend setText:@""];
    }
    return;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // release udp
#if 0
    if (0 < udpfd) {
        close(udpfd);
        udpfd = -1;
    }
    thisview = nil;
    poweron = 0;
    pthread_kill(recver, 9);
    pthread_join(recver, NULL);
#endif
}

@end
