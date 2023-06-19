//
//  ViewController.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "ViewController.h"
#import <Castled_iOS_SDK/Castled_iOS_SDK-Swift.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnRegisterUser;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoSecondVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Castled";
    [self showRequiredViews];

}

- (void)showRequiredViews {
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"showRequiredViews %@",[CastledUserDefaults getString:CastledUserDefaults.kCastledUserIdKey]);

        if ([CastledUserDefaults getString:CastledUserDefaults.kCastledUserIdKey] != nil) {
            weakSelf.btnGotoSecondVC.hidden = NO;
        } else {
            weakSelf.btnGotoSecondVC.hidden = YES;
        }
        weakSelf.btnRegisterUser.hidden = !weakSelf.btnGotoSecondVC.hidden;


    });
}

- (IBAction)registerUserAction:(id)sender {
    [self registerUserAPI];
}

- (void)registerUserAPI {
    NSString *userId = @"abhilash@castled.io"; // user-101
    NSString *token = [CastledUserDefaults getString:CastledUserDefaults.kCastledAPNsTokenKey];
    [Castled registerUserWithUserId:userId apnsToken:token];
    [self showRequiredViews];
}

- (void)registerEvents {
    // Implementation for registering events
}

- (void)triggerCampaign {
    // Implementation for triggering campaign
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
