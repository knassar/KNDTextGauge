//
//  KNDTextGaugeDelegate.h
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/13/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//  Licensed under MIT License
//  License text at http://github.com/knassar/KNDTextGauge
//

#import <Foundation/Foundation.h>
#import "KNDTextGauge.h"

@protocol KNDTextGaugeDelegate <NSObject>

@optional

/**
 * This message will be sent to the delegate when the TextGauge state changes.
 */
- (void)textGauge:(KNDTextGauge *)textGauge didGoFromState:(KNDTextGaugeState)previousState toState:(KNDTextGaugeState)currentState;

@end

