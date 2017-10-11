/*
    gnshkLoginViewController.h
    Goonjishk

    This is the view controller for login page
    Once user press login button, we call the start authorization method of foursquare object
    The startAuthorization method will land the user on foursquare login page in Safari
  
*/

#import <UIKit/UIKit.h>
#import "gnshkSessionHandler.h"

@interface gnshkLoginViewController : UIViewController{
    
    gnshkSessionHandler *foursquare;
    
}

@property (strong) IBOutlet UIImageView *imgView;
@property (strong) IBOutlet UIButton *btnLogin;

-(IBAction)btnLoginClicked:(id)sender;

@end
