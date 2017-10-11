//
//  gnshkFriendsViewController.h
//  Goonjishk
/*
 
 This view controller shows the complete list of user's friends on foursquare
 
 */

#import <UIKit/UIKit.h>
#import "gnshkSessionHandler.h"
#import "gnshkFriendsDetailViewController.h"

@interface gnshkFriendsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    
    gnshkSessionHandler *foursquareS;
    
}

@property (strong) IBOutlet UITableView *tview;

@end
