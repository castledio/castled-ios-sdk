//
//  CastledNotificationViewControllerObjC.m
//  CastledNotificationContent
//
//  Created by antony on 20/06/2023.
//

#import "CastledNotificationViewControllerObjC.h"

#if __has_include("CastledNotificationContent-Swift.h")
#import "CastledNotificationContent-Swift.h"
#else
#import <CastledNotificationContent/CastledNotificationContent-Swift.h>
#endif

static CastledNotificationViewControllerObjC *sharedInstance = nil;

@interface CastledNotificationViewControllerObjC ()
@property (nonatomic, strong) CastledNotificationViewController *contentViewController;

@end

@implementation CastledNotificationViewControllerObjC
 
+ (CastledNotificationViewControllerObjC *)extensionInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
 
    });
    return sharedInstance;
}
- (CastledNotificationViewController *)contentViewController {
    if (!_contentViewController) {
        _contentViewController = [[CastledNotificationViewController alloc] init];
        // _contentViewController = [CastledNotificationViewController extensionInstance];

    }
    return _contentViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize the Swift view controller
    [self createCastledNotificationViewController];
   

}
- (void)setAppGroupId:(NSString *)appGroupId{
    self.contentViewController.appGroupId = appGroupId;
    _appGroupId = appGroupId; // Use copy if you want to ensure an immutable copy is assigned

 
}
- (BOOL)isCastledPushNotification:(UNNotification *)notification{
    return [self.contentViewController isCastledPushNotification:notification];
}


- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    // Call the Swift view controller's method
    [self.contentViewController didReceiveNotificationResponse:response completionHandler:^(UNNotificationContentExtensionResponseOption responseOption) {
        completion(responseOption);
    }];
}

-(void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.preferredContentSize = self.contentViewController.preferredContentSize;

    });
    
}
-(void)createCastledNotificationViewController{
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    if([_appGroupId isKindOfClass:[NSString class]]){
        self.contentViewController.appGroupId = _appGroupId;
    }
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];

    // Add constraints to match the parent view's size
    [self.contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.contentViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    [self.contentViewController didMoveToParentViewController:self];
}
/*- (void)handleRichNotification:(UNNotification *)notification withViewController:(UIViewController *)viewController{
    if([_appGroupId isKindOfClass:[NSString class]]){
        self.contentViewController.appGroupId = _appGroupId;
    }
    [self.contentViewController handleRichNotification:notification with:viewController];
}*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
 }

- (void)didReceiveNotification:(UNNotification *)notification {

    [self.contentViewController didReceiveNotification:notification];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.preferredContentSize = self.contentViewController.preferredContentSize;
    });
}
@end
