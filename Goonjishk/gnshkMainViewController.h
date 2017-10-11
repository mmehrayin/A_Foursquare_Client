/*
    gnshkMainViewController.h
    Goonjishk

    This is the starting point of the application
    In this ViewController we check if user is already loggedin or not
    if the user is logged in we redirect the user to TabBar controller and show the nearby places
*/

#import <UIKit/UIKit.h>
#import "gnshkLoginViewController.h"
#import "gnshkSessionHandler.h"

@interface gnshkMainViewController : UIViewController {
    
    //Retreive the foursquare object from session handler
    
    gnshkSessionHandler *foursquare;
}


@end
