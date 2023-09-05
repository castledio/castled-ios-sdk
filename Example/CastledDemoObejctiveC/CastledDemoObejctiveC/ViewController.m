//
//  ViewController.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "ViewController.h"
#import <Castled/Castled-Swift.h>

static NSString *userIdKey = @"userIdKey";
@interface ViewController () <CastledInboxDelegate>
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


        if ([[NSUserDefaults standardUserDefaults] valueForKey:userIdKey] != nil) {
            weakSelf.btnGotoSecondVC.hidden = NO;

            UIImageSymbolConfiguration *largeConfig = [UIImageSymbolConfiguration configurationWithTextStyle:UIFontTextStyleLargeTitle];
            [self.navigationItem setRightBarButtonItem:nil];
            UIBarButtonItem *inboxButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"bell" withConfiguration:largeConfig] style:UIBarButtonItemStylePlain target:self action:@selector(inboxTapped)];
            [self.navigationItem setRightBarButtonItem:inboxButton];
            [self inboxCallBack];

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
    NSString *userId = @"antony@castled.io"; // user-101
    NSString *token = nil;// Replace with valid token
    [Castled registerUserWithUserId:userId apnsToken:token];
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:userIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showRequiredViews];
}

-(void)inboxCallBack{
    //    [[Castled sharedInstance] getInboxItemsWithCompletion:^(BOOL succes, NSArray<CastledInboxItem *> * _Nullable inboxItems, NSString * _Nullable errorMessage) {
    //        NSLog(@"Inbox items are %@", inboxItems);
    //
    //    }];
    [[Castled sharedInstance] setInboxUnreadCountWithCallback:^(NSInteger unreadCount) {
        NSLog(@"Inbox unread count is %ld", (long)unreadCount);
        NSLog(@"Inbox unread count is -- %ld", [[Castled sharedInstance] getUnreadMessageCount]);

    }];

}
- (void)inboxTapped {
    // Handle the button tap here
    CastledInboxConfig *style = [[CastledInboxConfig alloc] init];
    style.backgroundColor = [UIColor whiteColor];
    style.navigationBarBackgroundColor = [UIColor linkColor];
    style.title = @"Castled Inbox";
    style.navigationBarButtonTintColor = [UIColor whiteColor];
    style.loaderTintColor = [UIColor blueColor];
    style.hideCloseButton = NO;

    UIViewController *inboxViewController = [[Castled sharedInstance] getInboxViewControllerWith:style andDelegate:self];
    // inboxViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    // [self presentViewController:inboxViewController animated:YES completion:nil];
    [self.navigationController pushViewController:inboxViewController animated:YES];
}

- (void)didSelectedInboxWith:(NSDictionary * _Nullable)kvPairs :(CastledInboxItem * _Nonnull)inboxItem {
    NSLog(@"didSelectedInboxWith ----kvPairs  %@ item %@",kvPairs,inboxItem);

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
