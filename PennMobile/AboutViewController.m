//
//  AboutViewController.m
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *tripeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeText)];
    tripeTap.numberOfTapsRequired = 3;
    [_labsLogo addGestureRecognizer:tripeTap];
}

- (void)changeText {
    _labsHeader.text = @"You will never beat the real Best";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)featureRequest:(id)sender {
    // Email Subject
    NSString *messageSubject = @"[Penn iOS] Request: ";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"sachab@seas.upenn.edu"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    //mc.mailComposeDelegate = self;
    [mc setSubject:messageSubject];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}
- (IBAction)moreInfo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://pennlabs.org"]];
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
