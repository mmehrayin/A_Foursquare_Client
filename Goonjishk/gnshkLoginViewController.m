/*
    gnshkLoginViewController.m
    Goonjishk

    This is the view controller for login page
    Once user press login button, we call the start authorization method of foursquare object
    The startAuthorization method will land the user on foursquare login page in Safari
*/


#import "gnshkLoginViewController.h"

@interface gnshkLoginViewController ()


@end

@implementation gnshkLoginViewController


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
    
	// Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{
    
    foursquare = [gnshkSessionHandler sharedFoursquare];
    if([[foursquare foursquare] isSessionValid]) {
        
        gnshkLoginViewController *vwTabBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        [self presentViewController:vwTabBarViewController animated:YES completion:nil];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnLoginClicked:(id)sender{
    
    
    //call the startAuthorization method on foursquare will redirect the user to Safari for login
    
    [[foursquare foursquare] startAuthorization];
    
}

@end
