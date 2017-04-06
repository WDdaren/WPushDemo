//
//  ViewController.m
//  ArchitectureDemo
//
//  Created by w22543 on 2017/3/31.
//  Copyright © 2017年 w22543. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 120, 44)];
    [btn setTitle:@"发送本地推送" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.center = self.view.center;
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)btnClick{
    if ([[UIDevice currentDevice] systemVersion].floatValue >=10.0) {
        [self sendiOS10LocalNotification];
    }else{
        [self sendiOS8LocalNotification];
    }
}
- (void)sendiOS10LocalNotification
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = @"Body";
    content.badge = @(1);
    content.title = @"Title";
    content.subtitle = @"SubTitle";
    content.categoryIdentifier = kNotificationCategoryIdentifile;
    content.userInfo = @{@"customKeyForiOS8": @"customValue"};
    content.launchImageName = @"qq";
    //推送附件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"qq" ofType:@"png"];
    NSError *error = nil;
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"AttachmentIdentifile" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    content.attachments = @[attachment];
    
    //推送类型
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:4 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test" content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"iOS10 发送推送失败， error：%@", error);
        }else{
            NSLog(@"iOS10 发送推送成功");
        }
    }];
}
- (void)sendiOS8LocalNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //触发通知时间
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
    //重复间隔
    //    localNotification.repeatInterval = kCFCalendarUnitMinute;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    //通知内容
    localNotification.alertTitle = @"title";
    localNotification.alertBody = @"local notification";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    //通知参数
    localNotification.userInfo = @{@"customKeyForiOS10": @"customValue"};
    
    localNotification.category = kNotificationCategoryIdentifile;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
