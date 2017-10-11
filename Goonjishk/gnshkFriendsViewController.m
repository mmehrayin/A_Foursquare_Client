//
//  gnshkFriendsViewController.m
//  Goonjishk
/*
 
 This view controller shows the complete list of user's friends on foursquare
 
 */

#import "gnshkFriendsViewController.h"

@interface gnshkFriendsViewController ()

@end

@implementation gnshkFriendsViewController
@synthesize tview;
NSMutableArray *tableFriendsNameData;
NSMutableArray *tableImageData;
NSMutableArray *tableIdData;
NSMutableArray *tableHomeCityData;
NSMutableArray *tableEmailData;
NSMutableArray *tableFbIdData;
NSMutableArray *tableTwitterIdData;

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
    
    //retrieve the shared foursquare instance from session handler
    
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    
    
    //When foursquare returned the list of friends we need to refresh the friend list
    
    NSString *NotificationName  = @"ReloadNewsFeed";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification) name:NotificationName object:nil];
    
    //send request to foursquare to send us the friend list
    
    [foursquareS returnFriends:@"NewsFeed"];
    
    //initialize the table data variables
    
    tableFriendsNameData = [[NSMutableArray alloc] init];
    tableImageData = [[NSMutableArray alloc] init];
    tableIdData = [[NSMutableArray alloc] init];
    tableEmailData = [[NSMutableArray alloc] init];
    tableFbIdData = [[NSMutableArray alloc] init];
    tableTwitterIdData = [[NSMutableArray alloc] init];
    
    self.title = @"Friends";
   // NSLog(@"Friends View Loaded");
	// Do any additional setup after loading the view.
}

//Foursquare returned the friends list, refresh the table data

-(void) useNotification{
    
   // NSLog(@"In Notification");
    id value;
    value = [[[foursquareS response] objectForKey:@"friends"] objectForKey:@"items"] ;
    NSString *firstName = [[NSString alloc] init];
    NSString *lastName = [[NSString alloc] init];
    NSURL *thumbUrl =[[NSURL alloc] init];
    NSString *uid = [[NSString alloc] init];
    NSString *homeCity = [[NSString alloc] init];
    NSString *userEmail = [[NSString alloc] init];
    NSString *userFbId = [[NSString alloc] init];
    NSString *userTwitterId = [[NSString alloc] init];
    
             for(int pk=0;pk<[value count];pk++){
                 firstName =  [[value objectAtIndex:pk] objectForKey:@"firstName"];
                 if([[value objectAtIndex:pk] objectForKey:@"lastName"] == nil){
                     lastName = @"";
                 } else {
                     lastName =   [[value objectAtIndex:pk] objectForKey:@"lastName"];
                 }
                 
                 thumbUrl = [[value objectAtIndex:pk] objectForKey:@"photo"];
                 
                 [tableFriendsNameData addObject:[NSString stringWithFormat:@"%@ %@", firstName,lastName]];
                 [tableImageData addObject:thumbUrl];
                 
                 uid = [[value objectAtIndex:pk] objectForKey:@"id"];
                 [tableIdData addObject:uid];
                 
                 homeCity = [[value objectAtIndex:pk] objectForKey:@"homeCity"];
                 [tableHomeCityData addObject:homeCity];
                 
                 if([[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"email"] !=nil){
                     userEmail = [[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"email"];
                 } else {
                     userEmail = @"";
                 }
                 [tableEmailData addObject:userEmail];
                 
                 if([[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"facebook"] !=nil){
                     userFbId = [[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"facebook"];
                 } else {
                     userFbId = @"";
                 }
                 [tableFbIdData addObject:userFbId];
                 
                 if([[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"twitter"] !=nil){
                     userTwitterId = [[[value objectAtIndex:pk] objectForKey:@"contact"] objectForKey:@"twitter"];
                 } else {
                     userFbId = @"";
                 }
                 [tableTwitterIdData addObject:userTwitterId];

                 

                 
                 
             }
    
    [tview reloadData];
             
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//returns number of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableFriendsNameData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // NSLog(@"%@",[tableFriendsNameData objectAtIndex:0]);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.gestureRecognizers = nil;
    }
    
    if([tableHomeCityData objectAtIndex:[indexPath row]] != nil){
        
        cell.detailTextLabel.text = [tableHomeCityData objectAtIndex:[indexPath row]];
        
    }
    
    cell.textLabel.text = [tableFriendsNameData objectAtIndex:[indexPath row]];
    
    if([tableImageData objectAtIndex:[indexPath row]]==nil){
        
        
        //if there is no picture, show the no picture
        
        UIImage *originalImage = [UIImage imageNamed:@"NoPicture.jpg"];
        
        //change the size of returned image with the thumbnail function
        
        UIImage *thumbImage = [self makeThumbnailOfSize:CGSizeMake(70,44) originalImage:originalImage];
        
        cell.imageView.image = thumbImage;
        
    } else {
        NSURL *originalImageUrl = [NSURL URLWithString:[tableImageData objectAtIndex:[indexPath row]]];
        NSData *data = [[NSData alloc] initWithContentsOfURL:originalImageUrl];
        UIImage *originalImage = [UIImage imageWithData:data];
        UIImage *thumbImage = [self makeThumbnailOfSize:CGSizeMake(50,50) originalImage:originalImage];
        cell.imageView.image = thumbImage;
    }
    
    
    
    return cell;

}

#pragma mark - Table view delegate

//when user selects a friend redirect him to detailed page

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
     gnshkFriendsDetailViewController *vwFriendViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"friendsDetail"];
    
    NSURL *originalImageUrl = [NSURL URLWithString:[tableImageData objectAtIndex:[indexPath row]]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:originalImageUrl];
    UIImage *originalImage = [UIImage imageWithData:data];
    
    vwFriendViewController.title = [tableFriendsNameData objectAtIndex:[indexPath row]];
    vwFriendViewController.uPic = originalImage;
    
    vwFriendViewController.uEmail = [tableEmailData objectAtIndex:[indexPath row]];
    vwFriendViewController.uFbId = [tableFbIdData objectAtIndex:[indexPath row]];
    vwFriendViewController.uTwitterId = [tableTwitterIdData objectAtIndex:[indexPath row]];
    vwFriendViewController.uid = [tableIdData objectAtIndex:[indexPath row]];
    
    
    [self.navigationController pushViewController:vwFriendViewController animated:YES];
    

    
}


//below method creates the thumbnail view from original image

- (UIImage *) makeThumbnailOfSize:(CGSize)size originalImage:(UIImage *) originalImage;
{
    UIGraphicsBeginImageContext(size);
    // draw scaled image into thumbnail context
    [originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}


//customize the height of cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
