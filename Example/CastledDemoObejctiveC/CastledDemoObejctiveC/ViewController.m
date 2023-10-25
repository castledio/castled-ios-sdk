//
//  ViewController.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "ViewController.h"
#import <Castled/Castled-Swift.h>

static NSString *userIdKey = @"userIdKey";
@interface ViewController () <CastledInboxViewControllerDelegate>
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
    [[Castled sharedInstance] setUserId:@"antony@castled.io" userToken:nil];
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:userIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showRequiredViews];
}

-(void)inboxCallBack{
   [[Castled sharedInstance] getInboxItemsWithCompletion:^(BOOL succes, NSArray<CastledInboxItem *> * _Nullable inboxItems, NSString * _Nullable errorMessage) {
            NSLog(@"Inbox items are %@", inboxItems);
       [[Castled sharedInstance] deleteInboxItem:inboxItems.lastObject];


        }];
    [[Castled sharedInstance] observeUnreadCountChangesWithListener:^(NSInteger unreadCount) {
        NSLog(@"Inbox unread count is %ld", (long)unreadCount);
        NSLog(@"Inbox unread count is -- %ld", [[Castled sharedInstance] getInboxUnreadCount]);

    }];


}
- (void)inboxTapped {
    // Handle the button tap here
    CastledInboxDisplayConfig *style = [[CastledInboxDisplayConfig alloc] init];
    style.inboxViewBackgroundColor = [UIColor whiteColor];
    style.navigationBarBackgroundColor = [UIColor linkColor];
    style.navigationBarTitle = @"Castled Inbox";
    style.navigationBarButtonTintColor = [UIColor whiteColor];
    style.loaderTintColor = [UIColor blueColor];
    style.hideCloseButton = YES;


    style.showCategoriesTab = YES;
    style.tabBarDefaultTextColor = [UIColor greenColor];
    style.tabBarSelectedTextColor = [UIColor brownColor];
    style.tabBarDefaultBackgroundColor = [UIColor purpleColor];
    style.tabBarSelectedBackgroundColor = [UIColor lightGrayColor];
    style.tabBarIndicatorBackgroundColor = [UIColor redColor];

    UIViewController *inboxViewController = [[Castled sharedInstance] getInboxViewControllerWithUIConfigs:style andDelegate:self];
    // inboxViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    // [self presentViewController:inboxViewController animated:YES completion:nil];
    [self.navigationController pushViewController:inboxViewController animated:YES];
}

- (void)didSelectedInboxWith:(CastledClickActionType)action :(NSDictionary * _Nullable)kvPairs :(CastledInboxItem * _Nonnull)inboxItem {
    NSLog(@"didSelectedInboxWith ----kvPairs  %@ item %@",kvPairs,inboxItem);
    switch (action) {
        case CastledClickActionTypeDeepLink:

            break;
        case CastledClickActionTypeNavigateToScreen:

            break;
        case CastledClickActionTypeRichLanding:

            break;
        case CastledClickActionTypeRequestForPush:

            break;
        case CastledClickActionTypeDismiss:

            break;
        case CastledClickActionTypeCustom:

            break;
        default:
            break;
    }

}

- (void)registerEvents {
    // Implementation for registering events
}

- (void)triggerCampaign {
    // Implementation for triggering campaign
}



@end
