//
//  DemonstratorViewController.m
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/12/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//

#import "DemonstratorViewController.h"
#import "KNDTextGauge.h"
#import "KNDTextGaugeDelegate.h"

@interface DemonstratorViewController () <UITextFieldDelegate, KNDTextGaugeDelegate>

@end

@implementation DemonstratorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tap];

    if (_textView) {
        [self styleTextView];
        [_textGauge setLimit:100];
    }
    
    [_stateMessage setText:@""];
}

- (void)styleTextView
{
    [_textView.layer setBorderColor:[UIColor colorWithWhite:0.8f alpha:1.0f].CGColor];
    [_textView.layer setBorderWidth:0.5f];
    [_textView.layer setCornerRadius:5.0f];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

#pragma mark - Swiches

- (IBAction)toggleVisibility:(UISwitch *)sender
{
    [_textGauge setVisibleOnlyWhileEditing:sender.on];
}

- (IBAction)toggleOverLimitVisibility:(UISwitch *)sender
{
    [_textGauge setRemainsVisibleIfOverLimit:sender.on];
}

- (IBAction)toggleMatchesInsets:(UISwitch *)sender
{
    [_textGauge setGaugeMatchesFieldInsets:sender.on];
}

- (IBAction)monitorNotifications:(UISwitch *)sender
{
    if (sender.on) {
        [self startObservingNotifications];
    }
    else {
        [self stopObservingNotifications];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _barHeightTextField) {
        [_textGauge setGaugeHeight:[_barHeightTextField.text floatValue]];
    }
    else if (textField == _overHeightTextField) {
        if (_overHeightTextField.text.length == 0) {
            [_textGauge setOverfillHeightOffset:-1];
        }
        else {
            [_textGauge setOverfillHeightOffset:[_overHeightTextField.text floatValue]];
        }
    }
}

#pragma mark - Notifications

- (void)startObservingNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(fellUnderLimit) name:KNDTextGaugeTextLengthFellUnderLimitNotification object:_textGauge];
    [nc addObserver:self selector:@selector(wentOverLimit) name:KNDTextGaugeTextLengthWentOverLimitNotification object:_textGauge];
}

- (void)stopObservingNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

#pragma mark KNDTextGauge Notifications

- (void)wentOverLimit
{
    [_textField setBackgroundColor:[UIColor colorWithRed:1.0f green:0.8f blue:0.8f alpha:1.0f]];
    [_save setEnabled:NO];
}

- (void)fellUnderLimit
{
    [_textField setBackgroundColor:[UIColor whiteColor]];
    [_save setEnabled:YES];
}

#pragma mark - KNDTextGaugeDelegate

- (void)textGauge:(KNDTextGauge *)textGauge
   didGoFromState:(KNDTextGaugeState)previousState
          toState:(KNDTextGaugeState)currentState
{
    NSString *msg;
    UIColor *msgColor;
    switch (currentState) {
        case KNDTextGaugeStateEmpty:
        case KNDTextGaugeStateUnderLimit:
            msg = @"Looks Good";
            msgColor = [UIColor greenColor];
            break;
        case KNDTextGaugeStateInWarning:
            if (previousState == KNDTextGaugeStateOverLimit) {
                msg = @"That's better";
            }
            else if (previousState == KNDTextGaugeStateAtLimit) {
                msg = @"Going in the right direction";
            }
            else {
                msg = @"Careful now";
            }
            msgColor = [UIColor orangeColor];
            break;
        case KNDTextGaugeStateAtLimit:
            if (previousState == KNDTextGaugeStateOverLimit) {
                msg = @"Nice Editing";
            }
            else if (previousState == KNDTextGaugeStateInWarning) {
                msg = @"Alright... no more";
            }
            else {
                msg = @"That's It";
            }
            msgColor = [UIColor greenColor];
            break;
        case KNDTextGaugeStateOverLimit:
            msg = @"Woah there... too much";
            msgColor = [UIColor redColor];
            break;
    }
    
    [_stateMessage setText:msg];
    [_stateMessage setTextColor:msgColor];
}

@end
