//
//  AppDelegate+Push.m
//  ArchitectureDemo
//
//  Created by w22543 on 2017/3/31.
//  Copyright © 2017年 w22543. All rights reserved.
//

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "AppDelegate+Push.h"
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@end
@implementation AppDelegate (Push)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)pushApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center setNotificationCategories:[self createiOS10Categorys]];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"注册成功");
                //注册远程推送
                [application registerForRemoteNotifications];
            } else {
                NSLog(@"注册失败");
            }
        }];
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[self createiOS9Categorys]];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound categories:[self createiOS8Categorys]];
        [UIApplication.sharedApplication registerUserNotificationSettings:settings];
    }else {
        [UIApplication.sharedApplication registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound];
    }
    
}


#pragma mark - app delegate
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)settings
{
    NSLog(@"Registering device for push notifications..."); // iOS 8
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token
{
    NSLog(@"Registration successful, bundle identifier: %@, device token: %@",
          [NSBundle.mainBundle bundleIdentifier], token );
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register: %@", error);
}
#pragma clang diagnostic pop
#pragma mark - iOS10
//接收到通知的事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    //这个和下面的userNotificationCenter:didReceiveNotificationResponse withCompletionHandler: 处理方法一样
    NSDictionary *userInfo = notification.request.content.userInfo;
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    NSNumber *badge = content.badge;
    NSString *body = content.body;
    NSString *title = content.title;
    NSString *subTitle = content.subtitle;
    UNNotificationSound *sound = content.sound;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 在前台，收到远程通知:%@", userInfo);
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 在前台，收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}", body, title, subTitle, badge, sound, userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

//通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    NSNumber *badge = content.badge;
    NSString *body = content.body;
    NSString *title = content.title;
    NSString *subTitle = content.subtitle;
    UNNotificationSound *sound = content.sound;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知，点击了按钮:%@", userInfo);
    } else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知，点击了按钮:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}", body, title, subTitle, badge, sound, userInfo);
    }
    NSString *actionIdentifile = response.actionIdentifier;
    if ([actionIdentifile isEqualToString:kNotificationActionIdentifileBtnOne]) {
        [self showAlertView:@"点了按钮"];
    } else if ([actionIdentifile isEqualToString:kNotificationActionIdentifileBtnTwo]) {
        [self showAlertView:[(UNTextInputNotificationResponse *)response userText]];
    }
    
    completionHandler();
}

#pragma mark - iOS9 及之前方法
// (iOS8和9)推送通知回调函数，当应用程序在前台时或点击条幅时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"获取本地推送%@", notification.userInfo);
    [self showAlertView:@"用户没点击按钮直接点的推送消息进来的/或者该app在前台状态时收到推送消息"];
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge -= notification.applicationIconBadgeNumber;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"获取远程推送%@", userInfo);
    [self showAlertView:@"用户没点击按钮直接点的推送消息进来的/或者该app在前台状态时收到推送消息"];
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge -= 1;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    completionHandler(UIBackgroundFetchResultNewData);
}
//ios9点击按钮调用（不是条幅）
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    
    NSLog(@"iOS9 点击了按钮,本地推送消息为%@",notification.userInfo);
    if ([identifier isEqualToString:kNotificationActionIdentifileBtnOne]) {
        [self showAlertView:@"iOS9 来自本地推送，点了按钮"];
    } else if ([identifier isEqualToString:kNotificationActionIdentifileBtnTwo]) {
        [self showAlertView:[NSString stringWithFormat:@"iOS9 来自本地推送，用户回复为:%@", responseInfo[UIUserNotificationActionResponseTypedTextKey]]];
    }
    
    completionHandler();
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler
{
    
    NSLog(@"iOS9 点击了按钮,远程推送消息为%@",userInfo);
    if ([identifier isEqualToString:kNotificationActionIdentifileBtnOne]) {
        [self showAlertView:@"iOS9 来自远程推送，点了按钮"];
    } else if ([identifier isEqualToString:kNotificationActionIdentifileBtnTwo]) {
        [self showAlertView:[NSString stringWithFormat:@"iOS9 来自远程推送，用户回复为:%@", responseInfo[UIUserNotificationActionResponseTypedTextKey]]];
    }
    completionHandler();
}
//ios8点击按钮调用（不是条幅）
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification completionHandler:(nonnull void (^)())completionHandler
{
    
    NSLog(@"iOS8 点击了按钮,本地推送消息为%@",notification.userInfo);
    if ([identifier isEqualToString:kNotificationActionIdentifileBtnOne]) {
        [self showAlertView:@"iOS8 来自本地推送，点了按钮"];
    } else if ([identifier isEqualToString:kNotificationActionIdentifileBtnTwo]) {
      [self showAlertView:@"iOS8 来自本地推送，点了回复"];
    }
    
    completionHandler();
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler
{
    
    NSLog(@"iOS8 点击了按钮,远程推送消息为%@",userInfo);
    if ([identifier isEqualToString:kNotificationActionIdentifileBtnOne]) {
        [self showAlertView:@"iOS8 来自远程推送，点了按钮"];
    } else if ([identifier isEqualToString:kNotificationActionIdentifileBtnTwo]) {
        [self showAlertView:@"iOS8 来自本地推送，点了回复"];
        
    }
    completionHandler();
}
#pragma mark - private
-(NSSet<UIUserNotificationCategory *> *)createiOS9Categorys{
    UIMutableUserNotificationAction *action1 = [self createiOS9ActionWithID:kNotificationActionIdentifileBtnOne title:@"按钮" activationMode:UIUserNotificationActivationModeBackground authenticationRequired:YES destructive:NO isTextInput:NO titleForSubBtn:nil];
    UIMutableUserNotificationAction *action2 = [self createiOS9ActionWithID:kNotificationActionIdentifileBtnTwo title:@"回复" activationMode:UIUserNotificationActivationModeBackground authenticationRequired:NO destructive:YES isTextInput:YES titleForSubBtn:@"回复"];
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = kNotificationCategoryIdentifile;
    [category setActions:@[action1, action2] forContext:(UIUserNotificationActionContextMinimal)];
    return [NSSet setWithObjects:category, nil];
}
-(NSSet<UIUserNotificationCategory *> *)createiOS8Categorys{
    UIMutableUserNotificationAction *action1 = [self createiOS9ActionWithID:kNotificationActionIdentifileBtnOne title:@"按钮" activationMode:UIUserNotificationActivationModeBackground authenticationRequired:YES destructive:NO isTextInput:NO titleForSubBtn:nil];
    UIMutableUserNotificationAction *action2 = [self createiOS9ActionWithID:kNotificationActionIdentifileBtnTwo title:@"回复" activationMode:UIUserNotificationActivationModeBackground authenticationRequired:NO destructive:YES isTextInput:NO titleForSubBtn:nil];
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = kNotificationCategoryIdentifile;
    [category setActions:@[action1, action2] forContext:(UIUserNotificationActionContextMinimal)];
    return [NSSet setWithObjects:category, nil];
}
-(NSSet<UNNotificationCategory *> *)createiOS10Categorys{
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:kNotificationActionIdentifileBtnOne title:@"按钮" options:UNNotificationActionOptionAuthenticationRequired];
    UNTextInputNotificationAction *action2 = [UNTextInputNotificationAction actionWithIdentifier:kNotificationActionIdentifileBtnTwo title:@"回复" options:UNNotificationActionOptionForeground textInputButtonTitle:@"回复" textInputPlaceholder:@"请输入回复内容"];
    UNNotificationCategory *catetory = [UNNotificationCategory categoryWithIdentifier:kNotificationCategoryIdentifile actions:@[action1, action2] intentIdentifiers:@[kNotificationActionIdentifileBtnOne, kNotificationActionIdentifileBtnTwo] options:UNNotificationCategoryOptionNone];
    return [NSSet setWithObject:catetory];
}

-(UIMutableUserNotificationAction *)createiOS9ActionWithID:(NSString *)identifier title:(NSString *)title activationMode:(UIUserNotificationActivationMode)activationMode authenticationRequired:(BOOL)authenticationRequired destructive:(BOOL)destructive isTextInput:(BOOL )isTextInput titleForSubBtn:(NSString *)titleForsubBtn{
    UIMutableUserNotificationAction *action = [UIMutableUserNotificationAction new];
    action.identifier = identifier;
    action.title = title;
    action.activationMode = activationMode;
    action.authenticationRequired = authenticationRequired;
    action.destructive = destructive;
    if (isTextInput) {
        action.behavior = UIUserNotificationActionBehaviorTextInput;
        action.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: titleForsubBtn};
    }
    return action;
}
- (void)showAlertView:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.window.rootViewController showDetailViewController:alert sender:nil];
}

@end
