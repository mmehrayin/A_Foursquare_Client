//
//  gnshkSubmitCheckInViewController.h
//  Goonjishk
/*
 
 This view enables user to add an optional mesaage and a photo from camera or photo library and check in to foursquare
 User can select to post the checkin to facebook and twitter. Notice that foursquare handles posting to facebook and foursquare. So, if user has not connected his/her facebook/twitter account to foursquare account then post to fb and twitter doesn't happen but we don't get any error message
 
 */

#import <UIKit/UIKit.h>
#import "gnshkSessionHandler.h"
 #import <QuartzCore/QuartzCore.h>

@interface gnshkSubmitCheckInViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate> {
    
    gnshkSessionHandler *foursquareS;
    UIImage *image;
}

@property (strong) NSString *venueId;
@property (strong) IBOutlet UITextView *txtShout;
@property (strong) IBOutlet UILabel *charCount;
@property (strong) IBOutlet UISwitch *postToTwitter;
@property (strong) IBOutlet UISwitch *postToFb;
@property (strong) IBOutlet UIButton *photoLibrary;
@property (strong) IBOutlet UIButton *photoCamera;
@property (strong) IBOutlet UIButton *photoRemove;
@property (strong) IBOutlet UILabel *lblMessage;
@property (strong) IBOutlet UIButton *btnCheckIn;
@property (strong) IBOutlet UIImageView *fbLogo;
@property (strong) IBOutlet UIImageView *twitterLogo;


-(IBAction)btnCheckInClicked:(id)sender;
-(IBAction)addPhoto:(id)sender;
-(IBAction)addPhotoFromCamera:(id)sender;
-(IBAction)removePhotoClicked:(id)sender;


@end
