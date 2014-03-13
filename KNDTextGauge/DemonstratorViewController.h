//
//  DemonstratorViewController.h
//  KNDTextGauge
//
//  Created by Karim Nassar on 3/12/14.
//  Copyright (c) 2014 Karim Nassar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KNDTextGauge;

@interface DemonstratorViewController : UIViewController
{
    IBOutlet KNDTextGauge *_textGauge;
    IBOutlet UITextField *_textField;
    IBOutlet UITextView *_textView;
    
    IBOutlet UITextField *_barHeightTextField;
    IBOutlet UITextField *_overHeightTextField;
    
    IBOutlet UIButton *_save;
    IBOutlet UILabel *_stateMessage;
}

@end
