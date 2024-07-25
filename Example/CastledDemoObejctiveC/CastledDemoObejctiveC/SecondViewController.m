//
//  SecondViewController.m
//  CastledDemoObejctiveC
//
//  Created by antony on 19/06/2023.
//

#import "SecondViewController.h"
#import <Castled-Swift.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Second VC";

    // Do any additional setup after loading the view.
}
- (IBAction)suspendedStateClicked:(id)sender {
    [[Castled sharedInstance] suspendInAppNotifications];
}
- (IBAction)resumeStateCLicked:(id)sender {
    [[Castled sharedInstance] resumeInAppNotifications];

}
- (IBAction)discardStateClicked:(id)sender {
    [[Castled sharedInstance] discardInAppNotifications];

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
