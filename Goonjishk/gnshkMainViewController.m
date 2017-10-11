/*
    gnshkMainViewController.m
    Goonjishk

    This is the starting point of the application
    In this ViewController we check if user is already loggedin or not
    if the user is logged in we redirect the user to TabBar controller and show the nearby places
*/

#import "gnshkMainViewController.h"

@interface gnshkMainViewController ()

@end

@implementation gnshkMainViewController


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
    //retreive foursquare object from session Handler
    
    foursquare = [gnshkSessionHandler sharedFoursquare];
    
	// Do any additional setup after loading the view.
}



-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //check if user has not authorized the app redirect user to login page

    if([[foursquare foursquare] isSessionValid]) {
        
        //if user is logged in redirect user to Tab bar controller and show nearby places
        
        gnshkLoginViewController *vwTabBarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
        
        [self presentViewController:vwTabBarViewController animated:YES completion:nil];
        
    } else {
        
        //if user is not logged in redirect user to login page
        
        gnshkLoginViewController *vwLoginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginviewcontroller"];
        [self presentViewController:vwLoginViewController animated:YES completion:nil];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
