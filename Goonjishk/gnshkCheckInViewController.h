//
//  gnshkCheckInViewController.h
//  Goonjishk
/*
 
 This view presents a picture of place that user selected from Nearby tab and presents the address
 User can click on get directions link and get redirected to google maps for directions
 
 
 */

#import <UIKit/UIKit.h>
#import "gnshkSessionHandler.h"
#import "gnshkSubmitCheckInViewController.h"


@interface gnshkCheckInViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    gnshkSessionHandler *foursquareS;
}
@property (nonatomic) NSString *t;
@property (strong) IBOutlet UIImageView *imgView;
@property (strong) IBOutlet UIActivityIndicatorView *loader;
@property (strong) NSDictionary *placeDetailedInfo;
@property (strong) IBOutlet UITableView *tview;


@end
