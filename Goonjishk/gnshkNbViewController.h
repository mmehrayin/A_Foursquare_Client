//
//  gnshkNbViewController.h
//  Goonjishk
/*
 
 
 In this view we get the location of the user and send a request to foursquare to provide a list
 of nearby places. We process the returned json object and populate it into tableView
 
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "gnshkSessionHandler.h"
#import "gnshkCheckInViewController.h"
#import <MapKit/MapKit.h>
#import "gnshkMapAnnotaion.h"

#define METERS_PER_MILE 1609.344

@interface gnshkNbViewController : UIViewController<BZFoursquareRequestDelegate, BZFoursquareSessionDelegate,CLLocationManagerDelegate, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    gnshkSessionHandler *foursquareS;
    id  JSONObject_;
    CLLocationManager *locationManager;
    BZFoursquare        *foursquare_;
    BZFoursquareRequest *request_;
    NSDictionary        *meta_;
    NSArray             *notifications_;
    NSDictionary        *response_;
    
}

@property (nonatomic) BZFoursquare *foursquare;
@property(nonatomic,strong) BZFoursquareRequest *request;
@property(nonatomic,copy) NSDictionary *meta;
@property(nonatomic,copy) NSArray *notifications;
@property(nonatomic,copy) NSDictionary *response;
@property(weak,nonatomic) IBOutlet MKMapView *_mapView;
@property(weak,nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* filteredTableData;
@property (nonatomic) bool isFiltered;

//IBAction for logout button

-(IBAction)logOut:(id)sender;

@end