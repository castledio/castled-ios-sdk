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

@interface CastledNotificationViewControllerObjC ()
@property (nonatomic, strong) CastledNotificationViewController *contentViewController;

@end

@implementation CastledNotificationViewControllerObjC
@synthesize appGroupId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize the Swift view controller
    self.contentViewController = [[CastledNotificationViewController alloc] init];
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentViewController.appGroupId = appGroupId;
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];

    // Add constraints to match the parent view's size
    [self.contentViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.contentViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.contentViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.contentViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

    [self.contentViewController didMoveToParentViewController:self];

}
- (void)setAppGroupId:(NSString *)appGroupId{
    self.contentViewController.appGroupId = appGroupId;

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
        self.view.frame = self.contentViewController.view.frame;
        self.preferredContentSize = self.contentViewController.preferredContentSize;

    });
    
}
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
    self.preferredContentSize = self.contentViewController.view.frame.size;
}

- (void)didReceiveNotification:(UNNotification *)notification {

    [self.contentViewController didReceiveNotification:notification];
    [self.contentViewController.view layoutIfNeeded];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.view.frame = self.contentViewController.view.frame;
        self.preferredContentSize = self.contentViewController.preferredContentSize;

    });
}
@end
