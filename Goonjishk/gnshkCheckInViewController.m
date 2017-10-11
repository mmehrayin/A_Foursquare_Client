//
//  gnshkCheckInViewController.m
//  Goonjishk
/*
 
 This view presents a picture of place that user selected from Nearby tab and presents the address
 User can click on get directions link and get redirected to google maps for directions
 
 
 */

#import "gnshkCheckInViewController.h"

@interface gnshkCheckInViewController ()

@end

@implementation gnshkCheckInViewController
@synthesize t,imgView,loader,placeDetailedInfo,tview;

NSMutableArray *tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //get the address information based on response in nearby view and load it to one variable to present in table view
    
    
    NSString *placeAddress = [NSString stringWithFormat:@"%@,%@,%@ %@",[[placeDetailedInfo objectForKey:@"location"] objectForKey:@"address"],[[placeDetailedInfo objectForKey:@"location"] objectForKey:@"city"],[[placeDetailedInfo objectForKey:@"location"] objectForKey:@"state"],  [[placeDetailedInfo objectForKey:@"location"] objectForKey:@"postalCode"]];
    tableData = [[NSMutableArray alloc] init];
    [tableData addObject:placeAddress];
    [tableData addObject:@"Get Directions"];
   
  //  NSLog(@"%@",[tableData objectAtIndex:3]);
    
    NSString *NotificationName  = @"ReloadCheckIn";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification) name:NotificationName object:nil];
    
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStylePlain target:self action:@selector(showDetailedCheckInPage)];
    self.navigationItem.rightBarButtonItem = anotherButton;
  
    //show loader animation instead of the picture so the user knows we are retreiving picture from foursquare
    
    [loader startAnimating];
    
}


//This function opens google map link so user can get directions to intended place

-(void)openMap:(NSString *) llc {
    UIApplication *app = [UIApplication sharedApplication];
    NSString *str = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",llc];
    
    NSString * escapedUrlString =(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)str,NULL,(CFStringRef)@"!*'();@&+$,%#[]",kCFStringEncodingUTF8 ));
    
    [app openURL:[NSURL URLWithString:escapedUrlString]];
}


//redirect the user to final checkin page

-(void) showDetailedCheckInPage {
    
    gnshkSubmitCheckInViewController *vwCheckInViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubmitCheckIn"];
    
    vwCheckInViewController.venueId = self.t;
    vwCheckInViewController.title = self.title;
    
    [self.navigationController pushViewController:vwCheckInViewController animated:YES];
    
}


//Once the app retrieves the image for place it sends a notification to this view. This view should update the imageview based on returned image

-(void) useNotification {
    
    [self updateImageView];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//process the returned image from foursquare and show it in image view

-(void) updateImageView {
    
    [loader stopAnimating];
    NSLog(@"in image view");
    NSMutableArray *ss = [[NSMutableArray alloc] init];
    
    id value = [[foursquareS response] objectForKey:@"photos"];
    
    for(NSString* key in value){
       // NSLog(@"%@",key);
    }
    
    id value1 = [value objectForKey:@"groups"];
    id value2;
    
    for(int pk=1;pk<[value1 count];pk++){
    value2 = [value1 objectAtIndex:pk];
    id value3 = [value2 objectForKey:@"items"];
   NSLog(@"%@",[[value3 objectAtIndex:0] objectForKey:@"url"]);
        [ss addObject:[[value3 objectAtIndex:0] objectForKey:@"url"]];
        
    }
    
    NSLog(@"%d",[ss count]);
    if([ss count]>0){
    
    NSURL *url = [NSURL URLWithString:[ss objectAtIndex:0]];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    
    UIImage *tmpImage = [[UIImage alloc] initWithData:data];
    
        
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = tmpImage;
        
    } else {
        imgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"photo_not_available" ofType:@"jpg"]];
        
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//returns number of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [tableData count];
    
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
    
    if([[tableData objectAtIndex:[indexPath row]] isEqualToString:@"Get Directions"]){
        cell.textLabel.text = @"Get Directions";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = [tableData objectAtIndex:[indexPath row]];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([indexPath section]==0){
        if([indexPath row] == 1){
            
            UIAlertView *msg =[[UIAlertView alloc] initWithTitle:@"Attention" message:@"Go to Google Maps for directions?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [msg show];
            
        }
    }

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex ==1){
        [self openMap:[tableData objectAtIndex:0]];
    }
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    if([indexPath section]==0){
        if([indexPath row] == 1){
            [self openMap:[tableData objectAtIndex:0]];
        }
    }
    
}


@end
