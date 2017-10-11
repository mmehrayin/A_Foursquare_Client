//
//  gnshkFriendsDetailViewController.m
//  Goonjishk
/*
 
 This view presents detail information about a foursquare friend
 If twitter, facebook or email info is available then user can contact this friend by clicking on buttons.
 This view also shows the mayorships and tips by user
 
 */

#import "gnshkFriendsDetailViewController.h"

@interface gnshkFriendsDetailViewController ()

@end

@implementation gnshkFriendsDetailViewController
@synthesize userPicture,uPic,uEmail,btnSendEmail,btnFbProfile,uFbId,uTwitterId,btnTwitterProfile,tview,uid;

NSString *http_Fb_id;
NSString *fb_Fb_id;
NSString *http_Twitter_id;
NSString *twitter_Twitter_id;
NSMutableArray *tableMayorData;
NSMutableArray *tableUserTipsData;
NSMutableArray *tableUserTipsLocationData;

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
  //  NSLog(@"%@",uEmail);
    
    //set the user picture
    
    userPicture.image = uPic;
    
    //set the address to user's facebook profile. If facebook app is installed we will use facebook app, otherwise open it in Safari
    
    http_Fb_id = [NSString stringWithFormat:@"https://www.facebook.com/profile.php?id=%@",uFbId];
    fb_Fb_id = [NSString stringWithFormat:@"fb://profile/%@",uFbId];
    
     //set the address to user's twitter profile. If twitter app is installed we will use twitter app, otherwise open it in Safari
    
    http_Twitter_id = [NSString stringWithFormat:@"https://www.twitter.com/%@",uTwitterId];
    twitter_Twitter_id = [NSString stringWithFormat:@"twitter://user?screen_name=%@",uTwitterId];
    
    
    //if there is no email address disable the email button
    
    if(uEmail.length == 0){
        [btnSendEmail setEnabled:NO];
    } 
    
    //get the shared foursquare instance
    
    
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    
    //the notification that this class receives after retrieving mayorship info
    
    NSString *NotificationName  = @"ReloadReturnMayorship";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification) name:NotificationName object:nil];
    [foursquareS returnMayorships:uid calledFrom:@"returnMayorships"];
    
    
    
    //the notification that this class receives after retrieving tips info
    
    NSString *NotificationName1  = @"ReloadReturnUserTips";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification1) name:NotificationName1 object:nil];
    [foursquareS returnTipsOfUser:uid calledFrom:@"returnUserTips"];
    

    
    //initialize table data variables
    
    tableMayorData =[[NSMutableArray alloc] init];
    tableUserTipsData =[[NSMutableArray alloc] init];
    tableUserTipsLocationData =[[NSMutableArray alloc] init];
    
	// Do any additional setup after loading the view.
}


//update the mayorship section of the table

-(void) useNotification {
  //  NSLog(@"%@",[foursquareS response]);
    id value;
    value = [[[foursquareS response] objectForKey:@"mayorships"] objectForKey:@"items"];
     NSString *placeName = [[NSString alloc] init];
    
 //   NSLog(@"%@",value);
    
    for(int pk=0;pk<[value count];pk++){
        placeName =  [[[value objectAtIndex:pk] objectForKey:@"venue"] objectForKey:@"name"];
        
      //  NSLog(@"%@",placeName);
        [tableMayorData addObject:placeName];
    }
    
    [tview reloadData];
    
}


//update the tips section of the table

-(void) useNotification1 {
    id value;
    value = [[[foursquareS response]objectForKey:@"tips"] objectForKey:@"items"];
    NSString *tipPlaceName = [[NSString alloc] init];
    NSString *tipText = [[NSString alloc] init];
    
    for(int pk=0;pk<[value count];pk++){
        
        tipPlaceName =[[[value objectAtIndex:pk] objectForKey:@"venue"] objectForKey:@"name"];
        tipText = [[value objectAtIndex:pk] objectForKey:@"text"];
        
        if(tipPlaceName == nil || tipText==nil){
            [tableUserTipsData addObject:@""];
            [tableUserTipsLocationData addObject:@""];
        } else {
            [tableUserTipsData addObject:tipText];
            [tableUserTipsLocationData addObject:tipPlaceName];
        }
        
    }
    
    [tview reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//returns number of rows in section

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        if([tableMayorData count] == 0 ){
            return 1;
        } else {
            return [tableMayorData count];
        }
    } else {
        if([tableUserTipsData count] == 0){
            return 1;
        } else {
            return [tableUserTipsData count];
        }
    }
}


//set the titles of sections

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section ==0){
        return @"Mayorships";
    } else {
        return @"Tips!";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    if([indexPath section] == 0 ){
        if([tableMayorData count] == 0){
            cell.textLabel.text = @"No Mayorships found for this user!";
            cell.textLabel.adjustsFontSizeToFitWidth =YES;
            
        } else {
            cell.textLabel.text = [tableMayorData objectAtIndex:[indexPath row]];
        }
    } else {
        
        if([tableUserTipsData count] == 0){
            
            cell.textLabel.text = @"No Tips found for this user!";
            cell.textLabel.adjustsFontSizeToFitWidth =YES;
            

        } else {
            cell.textLabel.text = [tableUserTipsLocationData objectAtIndex:[indexPath row]];
            cell.detailTextLabel.text= [tableUserTipsData objectAtIndex:[indexPath row]];
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.detailTextLabel.numberOfLines =0;
        }
    }
    
    return cell;
    
}

//set the height of each row, some rows may have multiple lines of data in tips section

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0){
        return 60;
    } else {
        if([tableUserTipsData count] == 0){
            return 60;
        } else {
        
        if([[tableUserTipsData objectAtIndex:[indexPath row]] length] >=120 ){
            return 140;
        } else if ([[tableUserTipsData objectAtIndex:[indexPath row]] length] >=80){
            return 110;
        } else {
            return 80;
        }
        }
    }
        
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//the ibaction for sending email

-(IBAction)sendEmail:(id)sender{
    
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"A Message from Goonjishk"];
        NSArray *toRecipients = [NSArray arrayWithObjects:uEmail, nil];
        [mailer setToRecipients:toRecipients];
      //  UIImage *myImage = [UIImage imageNamed:@"mobiletuts-logo.png"];
      //  NSData *imageData = UIImagePNGRepresentation(myImage);
      //  [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"mobiletutsImage"];
        NSString *emailBody = @"Goonjishk Rocks!";
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentModalViewController:mailer animated:YES];
    }
    else
    {
        
        //display alert if mail application is not setup yet
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


//ibaction for showing facebook profile


-(IBAction)showFbProfile:(id)sender{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile"]] == NO){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:http_Fb_id]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fb_Fb_id]];
    }

}


//ibaction for showing twitter page

-(IBAction)showTwitterId:(id)sender{
    NSLog(@"%@",twitter_Twitter_id);
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://shahroom"]] == NO){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:http_Twitter_id]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:twitter_Twitter_id]];
    }
    
}


//handle the operation when user composes the mail and returns to app

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}


@end
