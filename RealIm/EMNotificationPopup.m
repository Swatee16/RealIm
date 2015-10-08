//
//  EMNotificationPopup.m
//  Twist And Turn
//
//  Created by Ennio Masi on 15/07/14.
//  Copyright (c) 2014 tactify. All rights reserved.
//

#import "EMNotificationPopup.h"


#import "UIFont+EMNotificationPopup.h"


#define kDefaultBigPopupWidth 220.0f
#define kDefaultBigPopupHeight 300.0f
#define kDefaultSlimPopupHeight 80.0f

#define kDefaultBigPopupImageSize 0.0f

@implementation EMNotificationPopup {
    UIWindow *referredWindow;
    
    UIImageView *imageView;
    UITextView *contentTextView;

    UIView *actionView;
    UILabel *actionTitleLbl;
    
    UIView *titleView;
    UILabel *popupTitle;
    
    UIView *subtitleView;
    UILabel *popupSubtitle;

    UIView *backgroundView;
    
    EMNotificationPopupDirection enterDirection;
    EMNotificationPopupDirection exitDirection;
    EMNotificationPopupPosition popupPosition;
    
    EMNotificationPopupType popupType;
    
    CGSize popoverSize;
    
    UIColor *popupActionBackgroundColor;
    UIColor *popupActionTitleColor;
    UIColor *popupBackgroundColor;
    UIColor *popupBorderColor;
    UIColor *popupSubtitleColor;
    UIColor *popupTitleColor;
    
    NSInteger bouncePower;
}

@synthesize delegate = _delegate;

@synthesize actionTitle = _actionTitle;
@synthesize image = _image;
@synthesize subtitle = _subtitle;
@synthesize title = _title;

// Default View

- (void) setActionTitle: (NSString *)actionTitle {
    _actionTitle = actionTitle;
    actionTitleLbl.text = _actionTitle;
}

- (void) setImage: (UIImage *) image {
    _image = image;
    imageView.image = _image;
}
- (void) setSubtitle: (NSString *)subtitle {
    _subtitle = subtitle;
    popupSubtitle.text = _subtitle;
}

- (void) setTitle:(NSString *)title {
    _title = title;
    popupTitle.text = _title;
}

// Customize the bounce power
- (void) setBouncePower:(NSInteger) bouncePwr {
    bouncePower = bouncePwr;
}

// Customize the default view
- (void) setPopupActionBackgroundColor: (UIColor *) color {
    popupActionBackgroundColor = color;
    actionTitleLbl.backgroundColor = popupActionBackgroundColor;
}

- (void) setPopupActionTitleColor: (UIColor *) color {
    popupActionTitleColor = color;
    actionTitleLbl.textColor = popupActionTitleColor;
}

- (void) setPopupBackgroundColor:(UIColor *)color {
    popupBackgroundColor = color;
    self.backgroundColor = popupBackgroundColor;
}

- (void) setPopupBorderColor: (UIColor *)color {
    popupBorderColor = color;
    self.layer.borderColor = popupBorderColor.CGColor;
}

- (void) setPopupSubtitleColor:(UIColor *)color {
    popupSubtitleColor = color;
    popupSubtitle.textColor = popupSubtitleColor;
}

- (void) setPopupTitleColor:(UIColor *)color {
    popupTitleColor = color;
    popupTitle.textColor = popupTitleColor;
}


- (id) initWithView:(UIView *)view enterDirection:(EMNotificationPopupDirection) enter exitDirection:(EMNotificationPopupDirection) exit popupPosition: (EMNotificationPopupPosition) position {
    if (self = [super init]) {
        referredWindow = [[[UIApplication sharedApplication] delegate] window];

        enterDirection = enter;
        exitDirection = exit;
        popupPosition = position;
        
        popoverSize = CGSizeMake(view.frame.size.width, view.frame.size.height);
        [self manageInitialPopoverPosition];

        [self addSubview:view];
    }
    
    return self;
}

- (void) defaultSettings {
    enterDirection = EMNotificationPopupToDown;
    exitDirection = EMNotificationPopupToDown;
    popupPosition = EMNotificationPopupPositionCenter;
}

- (void) show {
    [self addOpaqueBackground];
    
    [referredWindow addSubview:self];
    [UIView animateWithDuration:0.8f
                          delay:0.01f
         usingSpringWithDamping:[self computeDamping]
          initialSpringVelocity:0.1f
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            switch (popupPosition) {
                                case EMNotificationPopupPositionTop:
                                    self.center = CGPointMake(referredWindow.center.x, self.frame.size.height / 2);
                                    break;
                                case EMNotificationPopupPositionBottom:
                                    self.center = CGPointMake(referredWindow.center.x, referredWindow.frame.size.height - popoverSize.height / 2);
                                    break;
                                case EMNotificationPopupPositionCenter:
                                    self.center = referredWindow.center;
                                    break;
                                default:
                                    break;
                            }
                        }
                     completion:^(BOOL finished) {
                         //Completion Block
                     }];
}
- (void) dismissWithAnimation:(BOOL) animate {
    if (animate) {
        [UIView animateWithDuration:0.6f
                              delay:0.0f
             usingSpringWithDamping:0.2f
              initialSpringVelocity:0.7f
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                [backgroundView removeFromSuperview];
                                self.center = [self exitCenter];
                            }
                         completion:^(BOOL finished) {
                             [self setHidden:YES];
                             [self removeFromSuperview];
                         }];
    } else {
        [self removeFromSuperview];
    }
}

- (void) tapGestureRecognized {
    if (self.delegate && [self.delegate respondsToSelector:@selector(emNotificationPopupActionClicked)]) {
        [self.delegate emNotificationPopupActionClicked];
    } else {
        [NSException raise:@"The delegate doesn't respond to the method emNotificationPopupActionClicked" format:@"The delegate doesn't respond to the method emNotificationPopupActionClicked"];
    }
}

- (BOOL) isVisible {
    return !self.isHidden;
}

- (void) addOpaqueBackground {
    backgroundView = [[UIView alloc] init];
    backgroundView.frame = CGRectMake(-200.0f, -200.0f, referredWindow.frame.size.width + 400.0f, referredWindow.frame.size.height + 400.0f);
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = .7f;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [referredWindow insertSubview:backgroundView belowSubview:self];
        });
    });
}

- (void) manageInitialPopoverPosition {
    CGFloat yOrigin = 0.0f;
    
    switch (enterDirection) {
        case EMNotificationPopupToDown:
            self.frame = CGRectMake((referredWindow.frame.size.width - popoverSize.width) / 2.0f, -popoverSize.height, popoverSize.width, popoverSize.height);
            break;
        case EMNotificationPopupToTop:
            self.frame = CGRectMake((referredWindow.frame.size.width - popoverSize.width) / 2.0f, referredWindow.frame.size.height, popoverSize.width, popoverSize.height);
            break;
        case EMNotificationPopupToLeft:

            switch (popupPosition) {
                case EMNotificationPopupPositionTop:
                    yOrigin = 0.0f;
                    break;
                case EMNotificationPopupPositionBottom:
                    yOrigin = referredWindow.frame.size.height - popoverSize.height;
                    break;
                case EMNotificationPopupPositionCenter:
                    yOrigin = (referredWindow.frame.size.height - popoverSize.height) / 2.0f;
                    break;
                default:
                    break;
            }
            
            self.frame = CGRectMake(referredWindow.frame.size.width, yOrigin, popoverSize.width, popoverSize.height);
            break;
        case EMNotificationPopupToRight:
            
            switch (popupPosition) {
                case EMNotificationPopupPositionTop:
                    yOrigin = 0.0f;
                    break;
                case EMNotificationPopupPositionBottom:
                    yOrigin = referredWindow.frame.size.height - popoverSize.height;
                    break;
                case EMNotificationPopupPositionCenter:
                    yOrigin = (referredWindow.frame.size.height - popoverSize.height) / 2.0f;
                    break;
                default:
                    break;
            }

            self.frame = CGRectMake(-popoverSize.width, yOrigin, popoverSize.width, popoverSize.height);
            break;
        default:
            break;
    }
}

- (CGPoint) exitCenter {
    CGPoint newCenter;
    switch (exitDirection) {
        case EMNotificationPopupToDown:
            newCenter = CGPointMake(self.center.x, referredWindow.frame.size.height + popoverSize.height);
            break;
        case EMNotificationPopupToTop:
            newCenter = CGPointMake(self.center.x, -popoverSize.height);
            break;
        case EMNotificationPopupToLeft:
            newCenter = CGPointMake(-popoverSize.width, self.center.y);
            break;
        case EMNotificationPopupToRight:
            newCenter = CGPointMake(referredWindow.frame.size.width + popoverSize.width, self.center.y);
            break;
        default:
            break;
    }
    
    return newCenter;
}

- (CGFloat) computeDamping {
    switch (bouncePower) {
        case EMNotificationPopupNoBounce:
            return 1.0f;
            break;
        case EMNotificationPopupBounceWeak:
            return 0.8f;
            break;
        case EMNotificationPopupBounceMedium:
            return 0.5f;
            break;
        case EMNotificationPopupBounceStrong:
            return 0.1f;
            break;
        default:
            return 0.5f;
            break;
    }
}

@end