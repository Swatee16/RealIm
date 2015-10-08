//
//  ViewController.m
//  RealIm
//
//  Created by SAP Mobility on 10/2/15.
//  Copyright © 2015 Swatee. All rights reserved.
//


#import "ViewController.h"
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"
#import "UIImage+ResizeAdditions.h"
#import "EMNotificationPopup.h"


@interface ViewController ()<UIAlertViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,EMNotificationPopupDelegate>
{
    IBOutlet UIBubbleTableView *bubbleTable;
    IBOutlet UIView *textInputView;
    IBOutlet UITextField *textField;
    PFUser *user;
    NSMutableArray *bubbleData;
    UIImage *selectedImage;
}

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) EMNotificationPopup *notificationPopup;
@property (strong, nonatomic) IBOutlet UIView *viewImages;
@property (strong, nonatomic) IBOutlet UIImageView *imgPicker;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [bubbleTable setUserInteractionEnabled:NO];
    [self.view addSubview:self.viewJoin];
     [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(arrTobubble) userInfo:nil repeats:YES];
    // Keyboard events
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIAlert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [PFUser logInWithUsernameInBackground:self.txtUserName.text password:@"PASS" block:^(PFUser *user, NSError *error){
        if (!error) {
            // Hooray! Let them use the app now.
           // [self performSegueWithIdentifier:@"Login" sender:nil];
            
            
            [bubbleTable setUserInteractionEnabled:YES];
            self.viewJoin.hidden =YES;
            //[self.viewJoin removeFromSuperview];
            
            [self sync];
            [self arrTobubble];
            bubbleTable.bubbleDataSource = self;
            
            // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
            // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
            // Groups are delimited with header which contains date and time for the first message in the group.
            
            bubbleTable.snapInterval = 120;
            
            // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
            // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
            
            bubbleTable.showAvatars = YES;
            
           
            
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"ERROR : %@",errorString);
            // Show the errorString somewhere and let the user try again.
        }
    }];
}


-(void)sync{
    PFQuery *userQuery = [PFUser query];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    //[query whereKey:@"createdAt" greaterThanOrEqualTo:[NSDate date]];
//    PFObject *object = [PFObject objectWithClassName:@"Message"];
//    object.createdAt
    [query whereKey:@"createdAt" lessThan:[NSDate date]];
    [userQuery whereKey:@"Message" matchesQuery:query];
    [query includeKey:@"Message"];
    
   NSArray *arr = [userQuery findObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        
        for (PFObject *msg in messages) {
            
            
            
            
            // read user/car properties as needed
        }
    }];
    
}
-(void)arrTobubble{
    
    bubbleData = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (!error) {
             
             for (PFObject *obj in objects) {
                 
                 if ([[obj objectForKey:@"UserP"] isEqual:[PFUser currentUser]]) {
                     
                     if ([obj objectForKey:@"imgFile"]) {
                         PFFile *file = [obj objectForKey:@"imgFile"];


                         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                             if (!error) {
                                 UIImage *image = [UIImage imageWithData:data];
                                 NSBubbleData *photoBubble = [NSBubbleData dataWithImage:image date:[obj updatedAt] type:BubbleTypeMine name:@""];
                                 photoBubble.avatar = nil;
                                 // bubbleData = [[NSMutableArray alloc] initWithObjects:photoBubble, nil];
                                 // photoBubble.avatarName = @"";
                                 [bubbleData addObject:photoBubble];
                                 [bubbleTable reloadData];

                        
                            } else {
                                 NSLog(@"Error on fetching file");
                             }
                         }];
                         
                         
                     }
                     else{
                     NSBubbleData *heyBubble = [NSBubbleData dataWithText:[obj objectForKey:@"Message"] date:[obj updatedAt] type:BubbleTypeMine name:@""];
                     
                     heyBubble.avatar = nil;
                     
                     // bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, nil];
                     [bubbleData addObject:heyBubble];
                     }
                 }
                 else{
                     
                     if ([obj objectForKey:@"imgFile"]) {
                         PFFile *file = [obj objectForKey:@"imgFile"];
                         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                             if (!error) {
                                 
                                 
                                 UIImage *image = [UIImage imageWithData:data];
                                 NSBubbleData *photoBubble = [NSBubbleData dataWithImage:image date:[obj updatedAt] type:BubbleTypeSomeoneElse name:[obj objectForKey:@"userName"]];
                                 photoBubble.avatar = [UIImage imageNamed:@"User.png"];;
                                 
                                 // photoBubble.avatarName = [obj objectForKey:@"userName"];
                                 //    bubbleData = [[NSMutableArray alloc] initWithObjects:photoBubble, nil];
                                 [bubbleData addObject:photoBubble];
                                 [bubbleTable reloadData];
                                 
                             } else {
                                 NSLog(@"Error on fetching file");
                             }
                         }];
                         
                         
                     }
                     else{
                     NSBubbleData *heyBubble = [NSBubbleData dataWithText:[obj objectForKey:@"Message"] date:[obj updatedAt] type:BubbleTypeSomeoneElse name:[obj objectForKey:@"userName"]];
                     
                     heyBubble.avatar = [UIImage imageNamed:@"User.png"];
                     
                     // bubbleData = [[NSMutableArray alloc] initWithObjects:heyBubble, nil];
                     [bubbleData addObject:heyBubble];
                 }
                 }
             }
             [bubbleTable reloadData];

         }
    }];
}
#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [bubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [bubbleData objectAtIndex:row];
}


#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y -= kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height -= kbSize.height;
        bubbleTable.frame = frame;
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = textInputView.frame;
        frame.origin.y += kbSize.height;
        textInputView.frame = frame;
        
        frame = bubbleTable.frame;
        frame.size.height += kbSize.height;
        bubbleTable.frame = frame;
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - Actions

- (IBAction)sayPressed:(id)sender
{
   
    
    bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    
    PFObject *post = [PFObject objectWithClassName:@"Message"];
    [post setObject:textField.text forKey:@"Message"];
    [post setObject:[PFUser currentUser] forKey:@"UserP"];
    [post setObject:[PFUser currentUser].username forKey:@"userName"];
    // Save it to Parse
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            [self arrTobubble];
        }
    }];
    
    textField.text = @"";
    [textField resignFirstResponder];
}

- (IBAction)btnCamera_onClick:(UIButton *)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Ok" otherButtonTitles:@"Camera",@"Gallery", nil];
    [action showInView:self.view];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
   
    
    if (buttonIndex == 1) {
        // Camera
        
        [self takePhoto:nil];
    }
    else if (buttonIndex == 2) {
        //
        [self selectPhoto:nil];
    }
}


- (IBAction)takePhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    selectedImage =  info[UIImagePickerControllerEditedImage];
    _notificationPopup = [[EMNotificationPopup alloc] initWithView:self.viewImages enterDirection:EMNotificationPopupToDown exitDirection:EMNotificationPopupToRight popupPosition:EMNotificationPopupPositionCenter];
    _notificationPopup.delegate = self;
    [_notificationPopup setBouncePower:EMNotificationPopupBounceMedium];
    [_notificationPopup show];
    
    self.imgPicker.image =  selectedImage;
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (IBAction)btnSend_onClick:(UIButton *)sender {
    [_notificationPopup dismissWithAnimation:YES];
    
    //  UIImage *anImage = [UIImage imageNamed:@"halloween.jpg"];
    UIImage *resizedImage = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(250.0f, 250.0f) interpolationQuality:kCGInterpolationHigh];
    UIImage *thumbnailImage = [selectedImage thumbnailImage:86.0f transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return ;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    PFObject *post = [PFObject objectWithClassName:@"Message"];
    [post setObject:self.photoFile forKey:@"imgFile"];
    [post setObject:[PFUser currentUser] forKey:@"UserP"];
    [post setObject:[PFUser currentUser].username forKey:@"userName"];
    
    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [photoACL setPublicReadAccess:YES];
    post.ACL = photoACL;
    // Save it to Parse
    
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (!error) {
            
            //bubbleData= [[NSMutableArray alloc] init];
            [self arrTobubble];
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }
    }];
    
}


- (IBAction)btnJoin_onClick:(UIButton *)sender {
    _notificationPopup = [[EMNotificationPopup alloc] initWithView:self.viewPopUp enterDirection:EMNotificationPopupToDown exitDirection:EMNotificationPopupToRight popupPosition:EMNotificationPopupPositionCenter];
    _notificationPopup.delegate = self;
    [_notificationPopup setBouncePower:EMNotificationPopupBounceMedium];
    [_notificationPopup show];
}

#pragma mark - EMNotificationPopupDelegate
- (void) emNotificationPopupActionClicked {
    [_notificationPopup dismissWithAnimation:YES];
}

- (void) dismissCustomView {
    [_notificationPopup dismissWithAnimation:YES];
}

- (IBAction)btnAlert_onClick:(UIButton *)sender {
    [_notificationPopup dismissWithAnimation:YES];
    if (sender.tag != 0) {
        
        NSRange whiteSpaceRange = [self.txtUserName.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if (whiteSpaceRange.location != NSNotFound) {
            [Utilities showAlertWithTitle:@"Invalid" andMessage:@"Username should not be space and symbol." setDelegate:nil];
            self.txtUserName.text = @"";
            return;
        }
        NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
        
        if ([self.txtUserName.text rangeOfCharacterFromSet:set].location != NSNotFound) {
            NSLog(@"This string contains illegal characters");
            [Utilities showAlertWithTitle:@"Invalid" andMessage:@"Username should not be space and symbol." setDelegate:nil];
            self.txtUserName.text = @"";
            return;
        }
        user = [PFUser user];
        user.username = self.txtUserName.text;
        user.password = @"PASS";
        user.email = [NSString stringWithFormat:@"%@@example.com",self.txtUserName.text];
        
        // other fields can be set if you want to save more information
        //user[@"phone"] = @"650-555-0000";
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
              
                
                
                [bubbleTable setUserInteractionEnabled:YES];
                self.viewJoin.hidden =YES;
                //[self.viewJoin removeFromSuperview];
                [self sync];
                [self arrTobubble];
                bubbleTable.bubbleDataSource = self;
                
                // The line below sets the snap interval in seconds. This defines how the bubbles will be grouped in time.
                // Interval of 120 means that if the next messages comes in 2 minutes since the last message, it will be added into the same group.
                // Groups are delimited with header which contains date and time for the first message in the group.
                
                bubbleTable.snapInterval = 120;
                
                // The line below enables avatar support. Avatar can be specified for each bubble with .avatar property of NSBubbleData.
                // Avatars are enabled for the whole table at once. If particular NSBubbleData misses the avatar, a default placeholder will be set (missingAvatar.png)
                
                bubbleTable.showAvatars = YES;
              

                
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"ERROR : %@",errorString);
                [Utilities showAlertWithTitle:@"Message" andMessage:errorString setDelegate:self];
                
                // Show the errorString somewhere and let the user try again.
            }
        }];

    }
}

- (IBAction)btnDissmis_onClick:(UIButton *)sender {
    [self dismissCustomView];
}

- (IBAction)btnLogout_onClick:(UIButton *)sender {
    [bubbleTable setUserInteractionEnabled:NO];
    self.viewJoin.hidden =NO;
   
}


@end
