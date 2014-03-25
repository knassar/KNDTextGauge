//
//  KNDTextGauge.m
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/9/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//  Licensed under MIT License
//  License text at http://github.com/knassar/KNDTextGauge
//

#import "KNDTextGauge.h"
#import "KNDTextGaugeDelegate.h"

NSString *const KNDTextGaugeTextLengthFellUnderWarningThresholdNotification = @"com.karimnassar.textGauge-fell-under-warning-notification";
NSString *const KNDTextGaugeTextLengthEnteredWarningThresholdNotification   = @"com.karimnassar.textGauge-entered-warning-notification";
NSString *const KNDTextGaugeTextLengthFellUnderLimitNotification            = @"com.karimnassar.textGauge-fell-under-limit-notification";
NSString *const KNDTextGaugeTextLengthWentOverLimitNotification             = @"com.karimnassar.textGauge-went-over-limit-notification";

@interface KNDTextGauge()
{
    UIView *_baseGauge;
    UIView *_fill;
    UIView *_overfill;
    UIColor *_overfillBaseColor;
    BOOL _encodingExplicitlySet;
}

@end

#define kKNDTextGaugeDefaultLimit                   10
#define kKNDTextGaugeDefaultWarningThreshold        0.8f
#define kKNDTextGaugeDefaultGaugeAnimationSpeed     0.125f
#define kKNDTextGaugeDefaultGaugeHeight             2.0f
#define kKNDTextGaugeDefaultOverfillHeightOffset    1.0f

#define kKNDTextGaugeDefaultOverLimitColor          [UIColor redColor]
#define kKNDTextGaugeDefaultWarningColor            [UIColor yellowColor]
#define kKNDTextGaugeDefaultUnderLimitColor         [UIColor greenColor]
#define kKNDTextGaugeDefaultEmptyGaugeColor         [UIColor lightGrayColor]

@implementation KNDTextGauge

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeDefaults];
        [self initializeSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeDefaults];
        [self initializeSubviews];
    }
    return self;
}

#pragma mark - Setters

#pragma mark Object Relationships

- (void)setTextField:(UITextField *)textField
{
    if (_textField != textField) {
        if (_textField) {
            [self stopMonitoringText];
        }
        else if (_textView) {
            [self setTextView:nil];
        }
        _textField = textField;
        [self reframeSubviews];
        [self recalculate];
        [self monitorText];
    }
}

- (void)setTextView:(UITextView *)textView
{
    if (_textView != textView) {
        if (_textView) {
            [self stopMonitoringText];
        }
        else if (_textField) {
            [self setTextField:nil];
        }
        _textView = textView;
        [self reframeSubviews];
        [self recalculate];
        [self monitorText];
    }
}

#pragma mark Limit Metrics

- (void)setLimit:(NSInteger)limit
{
    if (_limit != limit) {
        _limit = limit;
        [self recalculate];
    }
}

- (void)setLimitUnits:(KNDTextGaugeLimitUnits)limitUnits
{
    if (_limitUnits != limitUnits) {
        _limitUnits = limitUnits;
        [self recalculate];
    }
}

- (void)setEncodingForByteLength:(NSStringEncoding)encodingForByteLength
{
    if (_encodingForByteLength != encodingForByteLength) {
        _encodingForByteLength = encodingForByteLength;
        [self recalculate];
    }
    _encodingExplicitlySet = !!_encodingForByteLength;
}

- (void)setWarningThreshold:(CGFloat)warningThreshold
{
    if (_warningThreshold != warningThreshold) {
        if (warningThreshold < 0 || warningThreshold > 1) {
            NSLog(@"KNDTextGauge -- you tried to set warningThreshold to an invalid value. Must be a positive CGFloat <= 1");
            return;
        }
        _warningThreshold = warningThreshold;
        [self recalculate];
    }
}

#pragma mark - Appearance Setters

#pragma mark Behaviors

- (void)setGaugeMatchesFieldInsets:(NSInteger)gaugeMatchesFieldInsets
{
    if (_gaugeMatchesFieldInsets != gaugeMatchesFieldInsets) {
        _gaugeMatchesFieldInsets = gaugeMatchesFieldInsets;
        [self reframeSubviews];
    }
}

- (void)setVisibleOnlyWhileEditing:(NSInteger)visibleOnlyWhileEditing
{
    if (_visibleOnlyWhileEditing != visibleOnlyWhileEditing) {
        _visibleOnlyWhileEditing = visibleOnlyWhileEditing;
        [self checkIsEditing:nil];
    }
}

- (void)setRemainsVisibleIfOverLimit:(NSInteger)remainsVisibleIfOverLimit
{
    if (_remainsVisibleIfOverLimit != remainsVisibleIfOverLimit) {
        _remainsVisibleIfOverLimit = remainsVisibleIfOverLimit;
        [self checkIsEditing:nil];
    }
}

#pragma mark Appearance Metrics

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reframeSubviews];
    [self recalculate];
}

- (void)setGaugeHeight:(CGFloat)gaugeHeight
{
    if (_gaugeHeight != gaugeHeight) {
        if (gaugeHeight <= 0) {
            gaugeHeight = kKNDTextGaugeDefaultGaugeHeight;
        }
        _gaugeHeight = gaugeHeight;
        [self reframeSubviews];
    }
}

- (void)setOverfillHeightOffset:(CGFloat)overfillHeightOffset
{
    if (_overfillHeightOffset != overfillHeightOffset) {
        if (overfillHeightOffset < 0) {
            overfillHeightOffset = kKNDTextGaugeDefaultOverfillHeightOffset;
        }
        _overfillHeightOffset = overfillHeightOffset;
        [self reframeSubviews];
    }
}

#pragma mark Colors

- (void)setOverLimitColor:(UIColor *)overLimitColor
{
    if (_overLimitColor != overLimitColor) {
        _overLimitColor = overLimitColor;
        
        CGFloat r, g, b, a;
        CGFloat darken = 0.75;
        if ([overLimitColor getRed:&r green:&g blue:&b alpha:&a]) {
            r *= darken;
            g *= darken;
            b *= darken;
            _overfillBaseColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
        }
        else {
            _overfillBaseColor = overLimitColor;
        }
    }
}

#pragma mark - Public Methods

- (void)recalculate
{
    NSInteger count = [self currentCount];
    
    KNDTextGaugeState oldState = _state;
    if (count == 0) {
        _state = KNDTextGaugeStateEmpty;
    }
    else if (count > self.limit) {
        _state = KNDTextGaugeStateOverLimit;
    }
    else if (count == self.limit) {
        _state = KNDTextGaugeStateAtLimit;
    }
    else if ((CGFloat)count >= (CGFloat)self.limit * self.warningThreshold) {
        _state = KNDTextGaugeStateInWarning;
    }
    else {
        _state = KNDTextGaugeStateUnderLimit;
    }
    if (oldState != _state) {
        [self notifyStateChangeFrom:oldState];
    }
    
    [self redrawGaugesForCount:count];
    
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated) {
        if (hidden) {
            [UIView animateWithDuration:self.gaugeAnimationSpeed animations:^{
                [self setAlpha:0];
            } completion:^(BOOL finished) {
                [self setHidden:YES];
            }];
        }
        else {
            [self setAlpha:0];
            [self setHidden:NO];
            [UIView animateWithDuration:self.gaugeAnimationSpeed animations:^{
                [self setAlpha:1.0f];
            }];
        }
    }
    else {
        [self setHidden:hidden];
    }
}

#pragma mark - Private

- (NSStringEncoding)encodingForText:(NSString *)text
{
    if (!_encodingExplicitlySet) {
        _encodingForByteLength = [text smallestEncoding];
    }
    return self.encodingForByteLength;
}

- (NSInteger)currentCount
{
    NSString *text;
    if (_textField) {
        text = _textField.text;
    }
    else if (_textView) {
        text = _textView.text;
    }
    if (self.limitUnits == KNDTextGaugeLimitUnitsBytes) {
        NSStringEncoding encoding = [self encodingForText:text];
        return [text maximumLengthOfBytesUsingEncoding:encoding];
    }
    else {
        return text.length;
    }
}

- (void)initializeDefaults
{
    _limit = kKNDTextGaugeDefaultLimit;
    _warningThreshold = kKNDTextGaugeDefaultWarningThreshold;
    _gaugeAnimationSpeed = kKNDTextGaugeDefaultGaugeAnimationSpeed;
    _gaugeHeight = kKNDTextGaugeDefaultGaugeHeight;
    _overfillHeightOffset = kKNDTextGaugeDefaultOverfillHeightOffset;
    _visibleOnlyWhileEditing = NO;
    _remainsVisibleIfOverLimit = NO;
    
    [self setOverLimitColor:kKNDTextGaugeDefaultOverLimitColor];
    _warningColor = kKNDTextGaugeDefaultWarningColor;
    _underLimitColor = kKNDTextGaugeDefaultUnderLimitColor;
    _emptyGaugeColor = kKNDTextGaugeDefaultEmptyGaugeColor;
}

- (void)initializeSubviews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
    
    _baseGauge = [[UIView alloc] initWithFrame:[self baseFrame]];
    [self addSubview:_baseGauge];

    _fill = [[UIView alloc] initWithFrame:[self baseFrame]];
    [self addSubview:_fill];
    
    _overfill = [[UIView alloc] initWithFrame:[self overfillFrame]];
    [_overfill setHidden:YES];
    [self addSubview:_overfill];
    
    if (self.visibleOnlyWhileEditing) {
        [self setAlpha:0];
    }
    [self reframeSubviews];
}

- (void)reframeSubviews
{
    [_baseGauge setFrame:[self baseFrame]];
    
    [self recalculate];
    
    [self styleGaugeBar:_baseGauge];
    [self styleGaugeBar:_fill];
    [self styleGaugeBar:_overfill];
    
}

#pragma mark - Field Monitoring

- (void)checkTextLength:(NSNotification *)notification
{
    if (notification.object == _textField || notification.object == _textView) {
        [self recalculate];
    }
}

- (id)field
{
    return (_textField) ? _textField : _textView;
}

- (void)checkIsEditing:(NSNotification *)notification
{
    BOOL hidden = NO;
    if (self.visibleOnlyWhileEditing &&
        (!self.remainsVisibleIfOverLimit || self.state != KNDTextGaugeStateOverLimit) &&
        (!notification || notification.object == _textField || notification.object == _textView)) {

        hidden = ![[self field] isFirstResponder];
    }
    [self setHidden:hidden animated:YES];
}

- (void)monitorText
{
    if (_textField) {
        // text changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextLength:) name:UITextFieldTextDidChangeNotification object:_textField];
        // editing changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsEditing:) name:UITextFieldTextDidBeginEditingNotification object:_textField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsEditing:) name:UITextFieldTextDidEndEditingNotification object:_textField];
    }
    else if (_textView) {
        // text changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextLength:) name:UITextViewTextDidChangeNotification object:_textView];
        // editing changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsEditing:) name:UITextViewTextDidBeginEditingNotification object:_textView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIsEditing:) name:UITextViewTextDidEndEditingNotification object:_textView];
    }
}

- (void)stopMonitoringText
{
    if (_textField) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:_textField];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:_textField];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:_textField];
    }
    else if (_textView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_textView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:_textView];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:_textView];
    }
}

#pragma mark - Delegation & Notifications

- (void)notifyStateChangeFrom:(KNDTextGaugeState)prevState
{
    if ([_delegate respondsToSelector:@selector(textGauge:didGoFromState:toState:)]) {
        [_delegate textGauge:self didGoFromState:prevState toState:_state];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *notification;
    if (prevState == KNDTextGaugeStateOverLimit) {
        notification = KNDTextGaugeTextLengthFellUnderLimitNotification;
    }
    else {
        switch (self.state) {
            case KNDTextGaugeStateOverLimit:
                notification = KNDTextGaugeTextLengthWentOverLimitNotification;
                break;
            case KNDTextGaugeStateInWarning:
                if (prevState == KNDTextGaugeStateUnderLimit) {
                    notification = KNDTextGaugeTextLengthEnteredWarningThresholdNotification;
                }
                break;
            case KNDTextGaugeStateUnderLimit:
                if (prevState == KNDTextGaugeStateInWarning) {
                    notification = KNDTextGaugeTextLengthFellUnderWarningThresholdNotification;
                }
                break;
            default:;
        }
    }
    if (notification) {
        [nc postNotificationName:notification object:self];
    }
}

#pragma mark - Redraw Gauges

- (void)redrawGaugesForCount:(NSInteger)count
{
    if (count <= self.limit) {
        if (!_overfill.hidden) {
            [_overfill setHidden:YES];
        }
        CGFloat fillW = ((CGFloat)count / (CGFloat)self.limit) * [self gaugeWidth];

        [UIView animateWithDuration:self.gaugeAnimationSpeed animations:^{
            [self setFillWidth:fillW];
        }];
    }
    else {
        [self setFillWidth:0];
        if (_overfill.hidden) {
            [self setOverfillWidth:[self gaugeWidth]];
            [_overfill setHidden:NO];
        }
        
        CGFloat overFillW = ((CGFloat)self.limit / (CGFloat)count) * [self gaugeWidth];
        [UIView animateWithDuration:self.gaugeAnimationSpeed animations:^{
            [self setOverfillWidth:overFillW];
        }];
    }
    [self setGaugeColors];
}

#pragma mark - Styling

- (void)setGaugeColors
{
    [_overfill setBackgroundColor:self.overLimitColor];
    switch (self.state) {
        case KNDTextGaugeStateOverLimit:
            [_baseGauge setBackgroundColor:_overfillBaseColor];
            break;
        case KNDTextGaugeStateAtLimit:
            [_baseGauge setBackgroundColor:self.underLimitColor];
            [_fill setBackgroundColor:self.underLimitColor];
            break;
        case KNDTextGaugeStateInWarning:
            [_baseGauge setBackgroundColor:self.warningColor];
            [_fill setBackgroundColor:self.underLimitColor];
            break;
        case KNDTextGaugeStateUnderLimit:
        default:
            [_baseGauge setBackgroundColor:self.emptyGaugeColor];
            [_fill setBackgroundColor:self.underLimitColor];
            break;
    }
}

- (void)styleGaugeBar:(UIView *)bar
{
    CGFloat r = CGRectGetHeight(bar.frame) / 2;
    [bar.layer setCornerRadius:r];
}

#pragma mark - Metrics

- (UIEdgeInsets)insets
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (self.gaugeMatchesFieldInsets) {
        if (_textField) {
            CGRect rect = [_textField editingRectForBounds:_textField.bounds];
            insets.left = CGRectGetMinX(rect);
            insets.right = CGRectGetWidth(_textField.frame) - (insets.left + CGRectGetWidth(rect));
        }
        else if (_textView) {
            if ([_textView respondsToSelector:@selector(textContainerInset)]) {
                insets = _textView.textContainerInset;
            }
            insets.left += _textView.contentInset.left;
            insets.right += _textView.contentInset.right;
        }
    }
    return insets;
}

- (void)setFillWidth:(CGFloat)width
{
    CGRect frame = _fill.frame;
    frame.size.width = width;
    [_fill setFrame:frame];
}

- (void)setOverfillWidth:(CGFloat)width
{
    CGRect frame = _overfill.frame;
    frame.origin.x = [self gaugeWidth] - width + self.insets.left;
    frame.size.width = width;
    [_overfill setFrame:frame];
}

- (CGFloat)gaugeWidth
{
    return CGRectGetWidth(self.frame) - (self.insets.left + self.insets.right);
}

- (CGRect)baseFrame
{
    return CGRectMake(self.insets.left, self.overfillHeightOffset, [self gaugeWidth], self.gaugeHeight);
}

- (CGRect)overfillFrame
{
    return CGRectMake(self.insets.left, 0, [self gaugeWidth], self.gaugeHeight + (2 * self.overfillHeightOffset));
}

@end
