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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *PeerReturn;
@property (weak, nonatomic) IBOutlet UITextField *LocalSend;

@end

ViewController *thisview = nil;
int udpfd = -1;
static unsigned char poweron = 0;

static void * recv_thread(void *p) {
    int ret;
    UILabel *display = nil;
    NSString *data = nil;
    char buf[PACKLEN];
    while (poweron) {
        ret = recvfrom(udpfd, buf, PACKLEN, 0, NULL, 0);
        if (nil != thisview) {
            display = thisview.PeerReturn;
            data = [NSString stringWithCharacters:(const unichar *)buf length:ret];
            [display setText:data];
        }
    }
    pthread_exit(NULL);
    return NULL;
}

@implementation ViewController
{
    struct sockaddr_in hostaddr, peeraddr;
    socklen_t peerlen;
}
@synthesize PeerReturn, LocalSend;

- (void) createSocket : (char *)server_addr {
    int sockfd = -1;
    int on = 1;
    int ret;
    int siret = 0;
    pthread_t recver;
    char buf[PACKLEN];
    
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
    siret = sendto(sockfd, buf, 5, 0, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
    if (0 > siret)	{
        perror("SEND");
    }
    siret = recvfrom(sockfd, buf, PACKLEN, 0, (struct sockaddr *)&peeraddr, &peerlen);
    if (sizeof(peeraddr) != siret) {
        perror("Get Peer");
    }
    memcpy(&peeraddr, buf, sizeof(peeraddr));
    printf("Get Peer %s : %d\n", inet_ntoa(peeraddr.sin_addr), ntohs(peeraddr.sin_port));
    //ret = connect(sockfd, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
    udpfd = sockfd;
    
    ret = pthread_create(&recver, NULL, recv_thread, NULL);
    
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
- (void)viewDidLoad {
    [super viewDidLoad];
    thisview = self;
    udpfd = -1;
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
        if (0 < udpfd) {
            ret = sendto(udpfd, [data UTF8String], [data length], 0, (struct sockaddr *)&peeraddr, sizeof(peeraddr));
        }
        else {
            char * addr = [[self.LocalSend text] UTF8String];
            [self createSocket:addr];
            if (0 > udpfd) {
                UIAlertView * note_invailable = [[UIAlertView alloc] initWithTitle:@"未连接服务器" message:@"没有连接上服务器" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
                [note_invailable show];
            }
        }
    }
    return;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // release udp
    if (0 < udpfd) {
        close(udpfd);
        udpfd = -1;
    }
    thisview = nil;
}

@end
