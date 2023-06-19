//
//  DeeplinkViewController.m
//  CastledDemoObejctiveC
//
//  Created by antony on 19/06/2023.
//

#import "DeeplinkViewController.h"

@interface DeeplinkViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblEventType;
@property(nonatomic,retain) NSDictionary* params;

@end

@implementation DeeplinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Deeplink View";
    // Do any additional setup after loading the view.
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
