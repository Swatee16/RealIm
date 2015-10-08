//
//  ViewController.h
//  RealIm
//
//  Created by SAP Mobility on 10/2/15.
//  Copyright © 2015 Swatee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"

@interface ViewController : UIViewController <UIBubbleTableViewDataSource>
- (IBAction)btnCamera_onClick:(UIButton *)sender;
- (IBAction)btnSend_onClick:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *viewPopUp;
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
- (IBAction)btnAlert_onClick:(UIButton *)sender;
- (IBAction)btnDissmis_onClick:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIView *viewJoin;
- (IBAction)btnJoin_onClick:(UIButton *)sender;

@end
