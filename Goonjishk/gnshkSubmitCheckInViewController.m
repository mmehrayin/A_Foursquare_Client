//
//  gnshkSubmitCheckInViewController.m
//  Goonjishk
/*
 
 This view enables user to add an optional mesaage and a photo from camera or photo library and check in to foursquare
 User can select to post the checkin to facebook and twitter. Notice that foursquare handles posting to facebook and foursquare. So, if user has not connected his/her facebook/twitter account to foursquare account then post to fb and twitter doesn't happen but we don't get any error message
 
 */


#import "gnshkSubmitCheckInViewController.h"

@interface gnshkSubmitCheckInViewController ()

@end

@implementation gnshkSubmitCheckInViewController
@synthesize txtShout,venueId,charCount,postToTwitter,postToFb,photoCamera,photoLibrary,photoRemove,lblMessage,btnCheckIn,fbLogo,twitterLogo;
UIImagePickerController *picker;

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
    foursquareS = [gnshkSessionHandler sharedFoursquare];
    NSString *NotificationName  = @"ReloadCheckInSubmit";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotification) name:NotificationName object:nil];
    
    NSString *NotificationName1  = @"ReloadAddPhoto";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useNotificationPhoto) name:NotificationName1 object:nil];
    
    //create the placeholder for textbox
    
    txtShout.text = @"Add a message to your Check In (Optional)";
    txtShout.textColor = [UIColor lightGrayColor];
    
    //create the border for textbox
    
    [txtShout.layer setBorderWidth:1.5f];
    [txtShout.layer setBorderColor:[[UIColor blackColor] CGColor]];
    
    //make sure Remove Photo button and Response label are invisible
    
    [photoRemove setHidden:YES];
    [photoLibrary setHidden:NO];
    [photoCamera setHidden:NO];
    [lblMessage setHidden:YES];
    
    
	// Do any additional setup after loading the view.
}


//hide the keyboard when user touches the background, make sure return the placeholder text if length is 0

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    
    if([txtShout.text isEqualToString:@""] ){
        txtShout.text = @"Add a message to your Check In (Optional)";
        txtShout.textColor = [UIColor lightGrayColor];
    }
    
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}


//remove the placeholder and prepare the textbox for user

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if([txtShout.text isEqualToString:@"Add a message to your Check In (Optional)"]){
    
        txtShout.text = @"";
        txtShout.textColor = [UIColor blackColor];
        
    }
    return YES;
}


//max accepatble message size is 140 chars, use needs to know number of Chars in textbox

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(txtShout.text.length == 0){
        txtShout.textColor = [UIColor lightGrayColor];
        txtShout.text = @"Add a message to your Check In (Optional)";
        
        [txtShout resignFirstResponder];
    }
    if([txtShout.text isEqualToString:@"Add a message to your Check In (Optional)"]){
        charCount.text = @"140";
    } else {
        int chCount = (140-txtShout.text.length);
    charCount.text = [NSString stringWithFormat:@"%d",chCount ];
        if(chCount <10){
            charCount.textColor = [UIColor redColor];
        } else {
            charCount.textColor = [UIColor blackColor];
        }
    }
}


//show the response after checkin and use the checkin id to add photo to checkin


-(void) useNotification{
   NSLog(@"%@",[[[foursquareS response] objectForKey:@"checkin"] objectForKey:@"id"]);
    id notification = [foursquareS notifications];
    
    //[tableData addObject:[[notification objectAtIndex:1] objectForKey:@"message"]];
    NSLog(@"%@",[[[notification objectAtIndex:1] objectForKey:@"item"] objectForKey:@"message"]);
    
    if(image != nil){
    [foursquareS addPhoto:[[[foursquareS response] objectForKey:@"checkin"] objectForKey:@"id"] jpgImage:UIImageJPEGRepresentation(image,8.0f) calledFrom:@"AddPhoto" ];
    }
    [txtShout setHidden:YES];
    [photoCamera setHidden:YES];
    [photoLibrary setHidden:YES];
    [photoRemove setHidden:YES];
    [postToFb setHidden:YES];
    [postToTwitter setHidden:YES];
    [btnCheckIn setHidden:YES];
    [fbLogo setHidden:YES];
    [twitterLogo setHidden:YES];
    [lblMessage setHidden:NO];
    lblMessage.text = [[[notification objectAtIndex:1] objectForKey:@"item"] objectForKey:@"message"];

}

-(void) useNotificationPhoto{
    
    image = [[UIImage alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//start processing user selections and send a request to foursquare based on user selection

-(IBAction)btnCheckInClicked:(id)sender{
    
    NSString *brdcastMessage = @"public";
    
     if(postToFb.on && postToTwitter.on){
         
         brdcastMessage = @"public,facebook,twitter";
     } else if (postToFb.on){
         brdcastMessage = @"public,facebook";
     } else if (postToTwitter.on){
         brdcastMessage = @"public,twitter";
     }
    
    if([txtShout.text isEqualToString:@"Add a message to your Check In (Optional)"]){
            
        [foursquareS checkin:[self venueId] checkInMessage:nil broadcastType:brdcastMessage calledFrom:@"CheckInSubmit"];
        
    } else {
        
        if(txtShout.text.length>140){
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Message should be less than 140 characters!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            
            [message show];
        } else {
            [foursquareS checkin:[self venueId] checkInMessage:txtShout.text broadcastType:brdcastMessage calledFrom:@"CheckInSubmit"];
        }
    }
}

//let user select an image from photo library

-(IBAction)addPhoto:(id)sender{
    
    picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate =self;
    [self presentModalViewController:picker animated:YES];
    
}


//check if camera functionality is available and let user capture photo from camera

-(IBAction)addPhotoFromCamera:(id)sender{
    
    if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
    {
        picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate =self;
        [self presentModalViewController:picker animated:YES];
    } else {
        UIAlertView *showMessage = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Camera is not available!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [showMessage show];
    }
}


//process the selected image

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // You have the image. You can use this to present the image in the next view like you require in `#3`.
    
   // imgView.image = image;
    
    [photoCamera setHidden:YES];
    [photoLibrary setHidden:YES];
    [photoRemove setHidden:NO];
    
    [self dismissModalViewControllerAnimated:YES];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}


//in case user decides to remove photo

-(IBAction)removePhotoClicked:(id)sender{
    image = [[UIImage alloc] init];
    [photoRemove setHidden:YES];
    [photoLibrary setHidden:NO];
    [photoCamera setHidden:NO];

}


@end
