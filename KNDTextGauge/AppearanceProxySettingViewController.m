//
//  AppearanceProxySettingViewController.m
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/12/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//

#import "AppearanceProxySettingViewController.h"
#import "KNDTextGauge.h"

@interface AppearanceProxySettingViewController ()
{
    IBOutlet UISegmentedControl *_colorSelector;
    IBOutlet UIView *_colorSwatches;
}

@end

@implementation AppearanceProxySettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeColorMode:_colorSelector];
    [self setupColorButtons];
}

#pragma mark - Swiches

- (IBAction)toggleVisibility:(UISwitch *)sender
{
    [[KNDTextGauge appearance] setVisibleOnlyWhileEditing:sender.on];
}

- (IBAction)toggleOverLimitVisibility:(UISwitch *)sender
{
    [[KNDTextGauge appearance] setRemainsVisibleIfOverLimit:sender.on];
}

- (IBAction)toggleMatchesInsets:(UISwitch *)sender
{
    [[KNDTextGauge appearance] setGaugeMatchesFieldInsets:sender.on];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _barHeightTextField) {
        [[KNDTextGauge appearance] setGaugeHeight:[_barHeightTextField.text floatValue]];
    }
    else if (textField == _overHeightTextField) {
        if (_overHeightTextField.text.length == 0) {
            [[KNDTextGauge appearance] setOverfillHeightOffset:-1];
        }
        else {
            [[KNDTextGauge appearance] setOverfillHeightOffset:[_overHeightTextField.text floatValue]];
        }
    }
}

#pragma mark - Colors

- (IBAction)changeColorMode:(UISegmentedControl *)sender
{
    [self highlightColorMatching:[self colorForCurrentMode]];
}

- (IBAction)setColor:(UIButton *)sender
{
    [self setColorForCurrentMode:sender.backgroundColor];
    [self highlightColorMatching:[self colorForCurrentMode]];
}

- (void)highlightColorMatching:(UIColor *)color
{
    for (UIButton *button in _colorSwatches.subviews) {
        if ([button.backgroundColor isEqual:color]) {
            [button.layer setBorderColor:[UIColor blackColor].CGColor];
            [button.layer setBorderWidth:3.0f];
        }
        else {
            [button.layer setBorderWidth:0];
        }
    }
}

- (void)setupColorButtons
{
    for (UIButton *button in _colorSwatches.subviews) {
        [button addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setColorForCurrentMode:(UIColor *)color
{
    switch (_colorSelector.selectedSegmentIndex) {
        case 0:
            [[KNDTextGauge appearance] setEmptyGaugeColor:color];
            break;
        case 1:
            [[KNDTextGauge appearance] setUnderLimitColor:color];
            break;
        case 2:
            [[KNDTextGauge appearance] setWarningColor:color];
            break;
        case 3:
            [[KNDTextGauge appearance] setOverLimitColor:color];
            break;
    }
}

- (UIColor *)colorForCurrentMode
{
    switch (_colorSelector.selectedSegmentIndex) {
        case 0:
            return [KNDTextGauge appearance].emptyGaugeColor;
        case 1:
            return [KNDTextGauge appearance].underLimitColor;
        case 2:
            return [KNDTextGauge appearance].warningColor;
        case 3:
            return [KNDTextGauge appearance].overLimitColor;
    }
    return nil;
}

@end