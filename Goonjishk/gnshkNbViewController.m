//
//  gnshkNbViewController.m
//  Goonjishk
/*
 
 
 In this view we get the location of the user and send a request to foursquare to provide a list
 of nearby places. We process the returned json object and populate it into tableView
 
 */

#import "gnshkNbViewController.h"
#import "gnshkLoginViewController.h"

@interface gnshkNbViewController ()
@property(nonatomic,readwrite,copy) id JSONObject;

@end

@implementation gnshkNbViewController
@synthesize JSONObject = JSONObject_;
@synthesize foursquare=foursquare_;
@synthesize request = request_;
@synthesize meta = meta_;
@synthesize notifications = notifications_;
@synthesize response = response_;
@synthesize _mapView;
@synthesize tableView,filteredTableData,isFiltered,searchBar;
NSMutableArray *s;
NSMutableArray *locations;
NSMutableArray *annotations;
NSMutableArray *filteredLocations;
NSDictionary *fsqResponse;
bool firstTimeLoading = true;

id value, value1;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Hide the keyboard when user is done with typing the search term

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}


//Hide the keyboard when the user press the cancel button

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    isFiltered =FALSE;
    [self updateView];
    [searchBar resignFirstResponder];
}

//Update the search result set when the user starts typing in the search bar

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        isFiltered = FALSE;
        [self updateView];
    }
    else
    {
        
        isFiltered = true;
        filteredTableData = [[NSMutableArray alloc] init];
        filteredLocations = [[NSMutableArray alloc] init];
       // NSLog(@"%d",[filteredTableData count]);
        NSLog(@"%d",[s count]);
        
        int kk=-1;
        
        for (NSString* item in s)
        {
            kk++;
            NSRange nameRange = [item rangeOfString:text options:NSCaseInsensitiveSearch];
           // NSLog(@"%@",text);
            if(nameRange.location != NSNotFound)
            {
                [filteredTableData addObject:item];
                [filteredLocations addObject:[locations objectAtIndex:kk]];
            }
        }
       // NSLog(@"%d",[filteredTableData count]);
        NSLog(@"%d",[s count]);
        [self updateView];
    }
    
    [self.tableView reloadData];
}


//Get the location of the user and update table data and map data accordingly


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = newLocation.coordinate.latitude;
    zoomLocation.longitude= newLocation.coordinate.longitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.2*METERS_PER_MILE, 0.2*METERS_PER_MILE);
    
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    
    [_mapView setRegion:adjustedRegion animated:YES];
    
    //once the location is updated pass it to searchVenues method to get the nearby places
    
    [foursquareS searchVenues:[NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude] calledFrom:@"NearBy"];
    
    //reload the table to show nearby places
    
    [self.tableView reloadData];
    
}

//invalidate user session and remove token when user press logout button

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
    
    self.title = @"Nearby";
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    self.foursquare = [foursquareS foursquare];
    
    //assign some default location in case location simulator is not enables
    //delete below line in final version
    
    // [foursquareS searchVenues:@"37.33,-122.03" calledFrom:@"NearBy"];
    
    s = [[NSMutableArray alloc] init];
    locations = [[NSMutableArray alloc] init];
    annotations = [[NSMutableArray alloc] init];

    
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

//when seession handler is done with processing the request to load nearby locations, it send s a notification
//we process the response object in this view after receiving the notification

-(void) useNotification {
    
    fsqResponse = [[NSDictionary alloc] init];
    
    fsqResponse =[foursquareS response];
    
    [self updateView];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//update the table view


- (void)updateView {
    [s removeAllObjects];
    [self._mapView removeAnnotations:annotations];
    [annotations removeAllObjects];
    [locations removeAllObjects];
    self.response = fsqResponse;
    self.JSONObject = [self response];
    value = nil;
    value = [JSONObject_ objectForKey:@"venues"];
    value1 = nil;
    
    for(int t=0;t<[value count];t++){
        value1 = [value objectAtIndex:t];
        
        for(NSString* key in value1){
            NSString *p = @"name";
            
           // NSLog(@"%@",key);
            
            if([key isEqualToString:p]){
                [s addObject:[NSString stringWithFormat:@"%@",[value1 objectForKey:key]]];
            } else if([key isEqualToString:@"location"]){
                [locations addObject: [value1 objectForKey:key]];
            }
        }
    }
   // NSLog(@"%@",[[locations objectAtIndex:1] objectForKey:@"lat"]);
    
    if(isFiltered){
        
        for(int tt=0;tt<[filteredLocations count];tt++){
            CLLocationCoordinate2D location;
            location.latitude = [[[filteredLocations objectAtIndex:tt] objectForKey:@"lat"] doubleValue];
            location.longitude = [[[filteredLocations objectAtIndex:tt] objectForKey:@"lng"] doubleValue];
            
            gnshkMapAnnotaion *newAnnotation = [[gnshkMapAnnotaion alloc] initWithTitle:[filteredTableData objectAtIndex:tt] andCoordinate:location];
            
            [annotations addObject:newAnnotation];
        
                [self._mapView addAnnotation:[annotations objectAtIndex:tt]];
        
        }
    }
    
    for(int tt=0;tt<[locations count];tt++){
        CLLocationCoordinate2D location;
        location.latitude = [[[locations objectAtIndex:tt] objectForKey:@"lat"] doubleValue];
        location.longitude = [[[locations objectAtIndex:tt] objectForKey:@"lng"] doubleValue];
        
        gnshkMapAnnotaion *newAnnotation = [[gnshkMapAnnotaion alloc] initWithTitle:[s objectAtIndex:tt] andCoordinate:location];
        
        [annotations addObject:newAnnotation];
        
        
        if(tt<6 && !isFiltered){
            [self._mapView addAnnotation:[annotations objectAtIndex:tt]];
        }
        
    }
    
    
    self.JSONObject = s;
    
    if ([self isViewLoaded]) {
        NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
        [tableView reloadData];
        if (indexPath) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//returns number of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isFiltered){
        return [filteredTableData count];
    } else {
        if([s count]>0){
            return [s count];
        } else {
            return 1;
            
        }
    }
}

//generate table cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.gestureRecognizers = nil;
    }
    if(isFiltered){
        cell.textLabel.text = [filteredTableData objectAtIndex:[indexPath row]];
     //   cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
    if([s count]==0){
        cell.textLabel.text =nil;
        
    }else {

        cell.textLabel.text = [s objectAtIndex:[indexPath row]];
        
     //   cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    }}
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
    value1 =nil;
     gnshkCheckInViewController *vwCheckInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkInViewController"];
    for(int t=0;t<[value count];t++){
        value1 = [value objectAtIndex:t];
        NSString *p2 = nil;
        NSString *p3 = nil;
        
        for(NSString* key in value1){
            NSString *p = @"name";
            NSString *p1 = @"id";
            
            
            if([key isEqualToString:p]){
                p2 = [NSString stringWithFormat:@"%@",[value1 objectForKey:key]];
            }
            if([key isEqualToString:p1]){
                p3 = [NSString stringWithFormat:@"%@",[value1 objectForKey:key]];
            }
        }
        if(!isFiltered){
            
            if ([p2 isEqualToString:[s objectAtIndex:[indexPath row]]]){
                
                vwCheckInViewController.t = p3;
                vwCheckInViewController.title =p2;
                vwCheckInViewController.placeDetailedInfo = value1;
            }
        } else {
           
            if ([p2 isEqualToString:[filteredTableData objectAtIndex:[indexPath row]]]){
                vwCheckInViewController.t = p3;
                vwCheckInViewController.title =p2;
                vwCheckInViewController.placeDetailedInfo = value1;
            }
        }
    }
    [foursquareS returnPics:vwCheckInViewController.t calledFrom:@"CheckIn"];

   
    [self.navigationController pushViewController:vwCheckInViewController animated:YES];

    
}


//When accessory button is touched in tableview

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    value1 =nil;
    gnshkCheckInViewController *vwCheckInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"checkInViewController"];
    for(int t=0;t<[value count];t++){
        value1 = [value objectAtIndex:t];
        NSString *p2 = nil;
        NSString *p3 = nil;
        
        for(NSString* key in value1){
            NSString *p = @"name";
            NSString *p1 = @"id";
            
            
            if([key isEqualToString:p]){
                p2 = [NSString stringWithFormat:@"%@",[value1 objectForKey:key]];
            }
            if([key isEqualToString:p1]){
                p3 = [NSString stringWithFormat:@"%@",[value1 objectForKey:key]];
            }
        }
        if(!isFiltered){
            
            if ([p2 isEqualToString:[s objectAtIndex:[indexPath row]]]){
                
                vwCheckInViewController.t = p3;
                vwCheckInViewController.title =p2;
                vwCheckInViewController.placeDetailedInfo = value1;
            }
        } else {
            
            if ([p2 isEqualToString:[filteredTableData objectAtIndex:[indexPath row]]]){
                vwCheckInViewController.t = p3;
                vwCheckInViewController.title =p2;
                vwCheckInViewController.placeDetailedInfo = value1;
            }}
    }
    [foursquareS returnPics:vwCheckInViewController.t calledFrom:@"CheckIn"];
    
    
    [self.navigationController pushViewController:vwCheckInViewController animated:YES];
    
    
}


//update the pins on map when user starts scrolling


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(!isFiltered){
    
    NSArray *visible = [tableView indexPathsForVisibleRows];
    
    
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
    
    int firstVisibleRow = [indexpath row];
    
    indexpath = nil;
    indexpath = (NSIndexPath*)[visible lastObject];
    
    int lastVisibleRow = [indexpath row];
    [self._mapView removeAnnotations:annotations];

    for(int tt=firstVisibleRow;(tt<=lastVisibleRow && tt<[annotations count]);tt++){
        
        
            [self._mapView addAnnotation:[annotations objectAtIndex:tt]];
    
    }
    }
    
  //  NSLog(@"%d",[indexpath row]);
    
        
}

//hide keyboard when user touches background and want to go out of search

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
   
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


@end
