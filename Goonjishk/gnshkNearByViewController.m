/*
    gnshkNearByViewController.m
    Goonjishk
 
    In this view we get the location of the user and send a request to foursquare to provide a list
    of nearby places. We process the returned json object and populate it into tableView
*/

#import "gnshkNearByViewController.h"
#import "gnshkLoginViewController.h"

@interface gnshkNearByViewController ()
@property(nonatomic,readwrite,copy) id JSONObject;

@end

@implementation gnshkNearByViewController
@synthesize JSONObject = JSONObject_;
@synthesize foursquare=foursquare_;
@synthesize request = request_;
@synthesize meta = meta_;
@synthesize notifications = notifications_;
@synthesize response = response_;
@synthesize _mapView;
NSMutableArray *s;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        
    }
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = newLocation.coordinate.latitude;
    zoomLocation.longitude= newLocation.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    
    [_mapView setRegion:adjustedRegion animated:YES];
   
    //once the location is updated pass it to searchVenues method to get the nearby places
    
    [foursquareS searchVenues:[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude] calledFrom:@"NearBy"];
    
    //reload the table to show nearby places
    
    [self.tableView reloadData];
    
}


-(IBAction)logOut:(id)sender{
    
    //call invalidatesession method to logout and delete token from database
    
    [[foursquareS foursquare] invalidateSession];
    
    //redirect the user to login page
    
    gnshkLoginViewController *vwLoginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
    [self presentViewController:vwLoginViewController animated:YES completion:nil];
    
    //stop the locationmanager update and release it
    
    [locationManager stopUpdatingLocation];
    locationManager.delegate =nil;
    locationManager =nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Nearby Locations";
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    self.foursquare = [foursquareS foursquare];
  
    //assign some default location in case location simulator is not enables
    //delete below line in final version
    
   // [foursquareS searchVenues:@"37.33,-122.03" calledFrom:@"NearBy"];
    
    s = [[NSMutableArray alloc] init];
    
    //prepare the locatioManager object
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 1000;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation]; 
    
    self.JSONObject = [self response];
    NSString *NotificationName  = @"ReloadNearBy";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification) name:NotificationName object:nil];
   
}

-(void) useNotification {
    
    [self updateView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateView {
    self.response = [foursquareS response];
    self.JSONObject = [self response];
    id value = nil;
    value = [JSONObject_ objectForKey:@"venues"];
    id value1 = nil;
    
    for(int t=0;t<[value count];t++){
        value1 = [value objectAtIndex:t];
        
        for(NSString* key in value1){
            NSString *p = @"name";
            
            if([key isEqualToString:p]){
                [s addObject:[NSString stringWithFormat:@"%@",[value1 objectForKey:key]]];
            } else {
                // NSLog(@"%@",key);
            }
        }
    }
    
    self.JSONObject = s;
    
    if ([self isViewLoaded]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}


//process the json object returned from four square to get the name of nearby places
/*
- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    self.JSONObject = [self response];
    id value = nil;
    value = [JSONObject_ objectForKey:@"venues"];
    id value1 = nil;
    
    for(int t=0;t<[value count];t++){
        value1 = [value objectAtIndex:t];
        
        for(NSString* key in value1){
            NSString *p = @"name";
        
            if([key isEqualToString:p]){
                [s addObject:[NSString stringWithFormat:@"%@",[value1 objectForKey:key]]];
            } else {
               // NSLog(@"%@",key);
            }
        }
    }
    
    self.JSONObject = s;
    [self updateView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)updateView {
    if ([self isViewLoaded]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)cancelRequest {
    if (request_) {
        request_.delegate = nil;
        [request_ cancel];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    self.meta = nil;
    self.notifications = nil;
    self.response = nil;
}

//this method gets coordinates and returns nearby places

- (void)searchVenues:(NSString *) locS {
    [self prepareForRequest];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:locS, @"ll", nil];
    self.request = [foursquare_ requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [request_ start];
    [self updateView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

 */

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//returns number of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if([s count]>0){
        return [s count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.gestureRecognizers = nil;
    }
     if([s count]==0){
        cell.textLabel.text =nil;
    }else {
    
        cell.textLabel.text = [s objectAtIndex:[indexPath row]];
    }
    return cell;

}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
