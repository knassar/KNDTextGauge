//
//  KNDTextGauge.h
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/9/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//
//  Version 1.0.0

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KNDTextGaugeState) {
    KNDTextGaugeStateEmpty, /** text length is 0 */
    KNDTextGaugeStateUnderLimit, /** text length is in the "green" zone */
    KNDTextGaugeStateInWarning,  /** text length is under the limit, but within the warning threshold */
    KNDTextGaugeStateAtLimit,    /** text length is exactly at the limit */
    KNDTextGaugeStateOverLimit   /** text length is over the limit */
};

typedef NS_ENUM(NSInteger, KNDTextGaugeLimitUnits) {
    KNDTextGaugeLimitUnitsCharacters,
    KNDTextGaugeLimitUnitsBytes
};

@protocol KNDTextGaugeDelegate;

@interface KNDTextGauge : UIView

#pragma mark - State

/**
 * This read-only property reflects the current state of the TextGauge as of the last recalculation
 */
@property(nonatomic, readonly) KNDTextGaugeState state;

#pragma mark - Object Relationships

/**
 * The following two properties hold a reference to the target field.
 * You should set ONE of the two properties to track a given text field/view.
 * If a previous field/view has been set when the other property is set, TextGauge will automatically
 * set the complimentary property reference to nil.
 * This makes it painless to use a single TextGauge for multiple fields.
 *
 * For the remainder of this documentation, any references to "the text field" refer to either UITextField or UITextView, whichever is set.
 */
@property(weak, nonatomic) IBOutlet UITextField *textField;
@property(weak, nonatomic) IBOutlet UITextView *textView;

/**
 * Set this delegate to receive notification of state changes
 */
@property(weak, nonatomic) IBOutlet id<KNDTextGaugeDelegate> delegate;

#pragma mark - Limit Metrics

/**
 * The number of characters to track the text field text length against.
 * Defaults to 100.
 * You should change this.
 */
@property(assign, nonatomic) NSInteger limit;

/**
 * The unit to use when computing progress against the limit.
 * Defaults to KNDTextGaugeLimitUnitsCharacters.
 */
@property(assign, nonatomic) KNDTextGaugeLimitUnits limitUnits;

/**
 * The encoding to use when measuring the target text for byte length
 * If not assigned explicitly or explicitly set to 0, 
 * this will be set to the result of calling smallestEncoding on the target text string on each length check.
 */
@property(assign, nonatomic) NSStringEncoding encodingForByteLength;

/**
 * A percentage of the limit property at which to issue a visual warning (color change) that the text is approaching the limit
 * This must be between 0 and 1
 * Defaults to 0.8f
 */
@property(assign, nonatomic) CGFloat warningThreshold;

#pragma mark - Appearance

#pragma mark Behaviors

/**
 * If 1, the TextGauge will only be visible when the text field is the first responder
 * ** treat this property as a Boolean. It is an NSInteger because the appearance protocol does not support BOOL **
 * Defaults to 0
 */
@property(assign, nonatomic) NSInteger visibleOnlyWhileEditing UI_APPEARANCE_SELECTOR;

/**
 * If 1, the TextGauge will not be hidden when the text field resigns first responder IF the TextGauge state is KNDTextGaugeStateOverLimit
 * ** treat this property as a Boolean. It is an NSInteger because the appearance protocol does not support BOOL **
 * This property has no effect if visibleOnlyWhileEditing is 0.
 * Defaults to 0
 */
@property(assign, nonatomic) NSInteger remainsVisibleIfOverLimit UI_APPEARANCE_SELECTOR;

/**
 * If 1, the TextGauge will copy the editable rect of its UITextField (or the contentInset of its UITextView), 
 * lining up with the left and right padding of the text within the view.
 * ** treat this property as a Boolean. It is an NSInteger because the appearance protocol does not support BOOL **
 * Defaults to 0
 */
@property(assign, nonatomic) NSInteger gaugeMatchesFieldInsets UI_APPEARANCE_SELECTOR;

#pragma mark Appearance Metrics

/**
 * The height of the TextGauge fill meter.
 * Defaults to 2.0f
 */
@property(assign, nonatomic) CGFloat gaugeHeight UI_APPEARANCE_SELECTOR;

/**
 * The amount the overfill meter is offset top and bottom from the TextGauge.
 * Defaults to 1.0f
 */
@property(assign, nonatomic) CGFloat overfillHeightOffset UI_APPEARANCE_SELECTOR;

/**
 * The animation duration used for all TextGauge animations.
 * You can set this to 0 to disable all animations.
 * Defaults to 0.125f
 */
@property(assign, nonatomic) CGFloat gaugeAnimationSpeed UI_APPEARANCE_SELECTOR;

#pragma mark Colors

/**
 * These properties allow you to adjust the TextGague colors
 */
@property(strong, nonatomic) UIColor *overLimitColor UI_APPEARANCE_SELECTOR;
@property(strong, nonatomic) UIColor *warningColor UI_APPEARANCE_SELECTOR;
@property(strong, nonatomic) UIColor *underLimitColor UI_APPEARANCE_SELECTOR;
@property(strong, nonatomic) UIColor *emptyGaugeColor UI_APPEARANCE_SELECTOR;

#pragma mark - Methods

/**
 * Recomputes the TextGague state.
 * Call this when you programmatically change the text of the text field.
 * You do NOT need to call this in most circumstances.
 */
- (void)recalculate;

/** 
 * Programatically show/hide the TextGauge
 */
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark - NSNotifications

/**
 * The following notifications are sent through NSNotificationCenter on state changes
 */

#pragma mark Fell Under Warning Threshold
/**
 * Sent when the character count has previous been within the warning threshold, and has fallen below the warning threshold
 */
UIKIT_EXTERN NSString *const KNDTextGaugeTextLengthFellUnderWarningThresholdNotification;

#pragma mark Entered Warning Threshold
/**
 * Sent when the character count has entered the warning threshold, and has previously been below the warning threshold
 */
UIKIT_EXTERN NSString *const KNDTextGaugeTextLengthEnteredWarningThresholdNotification;

#pragma mark Fell Under Limit
/**
 * Sent when the character count has previous been over the limit, and has fallen below the limit
 */
UIKIT_EXTERN NSString *const KNDTextGaugeTextLengthFellUnderLimitNotification;

#pragma mark Went Over Limit
/**
 * Sent when the character count goes over the limit
 */
UIKIT_EXTERN NSString *const KNDTextGaugeTextLengthWentOverLimitNotification;

