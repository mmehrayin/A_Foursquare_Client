//
//  gnshkFriendsDetailViewController.h
//  Goonjishk
/*
 
 This view presents detail information about a foursquare friend
 If twitter, facebook or email info is available then user can contact this friend by clicking on buttons. 
 This view also shows the mayorships and tips by user
 
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "gnshkSessionHandler.h"

@interface gnshkFriendsDetailViewController : UIViewController<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UITableViewDataSource,UITableViewDelegate>{
    gnshkSessionHandler *foursquareS;
}

//users picture

@property (strong) IBOutlet UIImageView *userPicture;

//contact buttons

@property (retain) IBOutlet UIButton *btnSendEmail;
@property (retain) IBOutlet UIButton *btnFbProfile;
@property (retain) IBOutlet UIButton *btnTwitterProfile;
@property (strong) UIImage *uPic;
@property (strong) NSString *uEmail;
@property (strong) NSString *uFbId;
@property (strong) NSString *uTwitterId;
@property (strong) NSString *uid;
@property (strong) IBOutlet UITableView *tview;

-(IBAction)sendEmail:(id)sender;
-(IBAction)showFbProfile:(id)sender;
-(IBAction)showTwitterId:(id)sender;

@end
