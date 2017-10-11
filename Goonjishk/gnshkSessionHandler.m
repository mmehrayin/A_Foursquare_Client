/*
    gnshkSessionHandler.m
    Goonjishk
 
    In this class we create an instance of Foursquare object and make it available to all views
*/

#import "gnshkSessionHandler.h"

#define kClientID       FOURSQUARE_CLIENT_ID
#define kCallbackURL    FOURSQUARE_CALLBACK_URL


@implementation gnshkSessionHandler

static gnshkSessionHandler *sharedInstance = nil;

@synthesize foursquare=foursquare_;
@synthesize request = request_;
@synthesize meta = meta_;
@synthesize notifications = notifications_;
@synthesize response = response_;

NSString *CalledFromView;

//initialize the foursquare object with ClientID and callbackurl

- (id)initWithCoder{
    self = [super init];
    if (self) {
        self.foursquare = [[BZFoursquare alloc] initWithClientID:kClientID callbackURL:kCallbackURL];
        foursquare_.version = @"20111119";
        foursquare_.locale = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        foursquare_.sessionDelegate = self;
        CalledFromView = [[NSString alloc] init];
    }
    return self;
}


//check if sharedfoursquare object exists! Create one if it doesn't exist...


+(id) sharedFoursquare{
    if (sharedInstance == nil){
        sharedInstance = [[gnshkSessionHandler alloc] initWithCoder];
    }
    return sharedInstance;
}

//request is complete we need to process response from foursquare and notify the view that called the request in session handler

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    if(CalledFromView==@"NearBy"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadNearBy" object:nil];
        
    }
    if(CalledFromView==@"CheckIn"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCheckIn" object:nil];
        
    }
    if(CalledFromView==@"CheckInSubmit"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadCheckInSubmit" object:nil];
        
    }
    if(CalledFromView==@"NewsFeed"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadNewsFeed" object:nil];
      //   NSLog(@"%@",self.response);
    }
    
    if(CalledFromView==@"LatestCheckIns"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadLatestCheckIns" object:nil];
      //  NSLog(@"%@",self.response);
    }
    
    if(CalledFromView==@"AddPhoto"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadAddPhoto" object:nil];
    //    NSLog(@"%@",self.response);
    }
    
    if(CalledFromView==@"returnMayorships"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadReturnMayorship" object:nil];
        //    NSLog(@"%@",self.response);
    }
    
    if(CalledFromView==@"returnUserTips"){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadReturnUserTips" object:nil];
        //    NSLog(@"%@",self.response);
    }
    
    
  //  NSLog(@"%@", CalledFromView);

    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

- (void)searchVenues:(NSString *) locS calledFrom: (NSString *) vw{
    [self prepareForRequest];
    CalledFromView = vw;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:locS, @"ll",@"intent",@"checkin", nil];
    self.request = [foursquare_ requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

//this method gets the pictures of a specific place

- (void)returnPics:(NSString *) locId calledFrom: (NSString *) vw{
    [self prepareForRequest];
    CalledFromView = vw;
    NSString *rpath;
    rpath = [NSString stringWithFormat: @"venues/%@/photos",locId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:locId, @"VENUE_ID",@"group",@"venue", nil];
    self.request = [foursquare_ requestWithPath:rpath HTTPMethod:@"GET" parameters:parameters delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

//this method allows user to checkin to a specific place

- (void)checkin: (NSString *) venueId checkInMessage:(NSString *)checkInMessage broadcastType:(NSString *)broadcastType calledFrom: (NSString *) vw {
    
    [self prepareForRequest];
    CalledFromView = vw;
    
    if(checkInMessage==nil ){
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:venueId, @"venueId", broadcastType, @"broadcast", nil];
        self.request = [foursquare_ requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
        [request_ start];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    } else {
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:venueId, @"venueId", @"public,facebook,twitter", @"broadcast",checkInMessage,@"shout", nil];
        self.request = [foursquare_ requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
        [request_ start];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    }
    
}


//This method allows user to add a photo to his/her checkin

- (void)addPhoto: (NSString *) checkInId jpgImage:(NSData *) jpgImage calledFrom:(NSString *) vw {
    [self prepareForRequest];
    CalledFromView = vw;
   // NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"TokyoBa-Z" withExtension:@"jpg"];
   // NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:jpgImage, @"photo.jpg", checkInId, @"checkinId", nil];
    self.request = [foursquare_ requestWithPath:@"photos/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)returnFriends:(NSString *) vw {
    
    [self prepareForRequest];
    CalledFromView = vw;
    
    self.request = [foursquare_ requestWithPath:@"users/self/friends" HTTPMethod:@"GET" parameters:nil delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    

}

-(void) returnMayorships: (NSString *) userId calledFrom:(NSString *) vw {
 
    
    [self prepareForRequest];
    CalledFromView = vw;
    NSString *rpath;
    rpath = [NSString stringWithFormat: @"users/%@/mayorships",userId];
    self.request = [foursquare_ requestWithPath:rpath HTTPMethod:@"GET" parameters:nil delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}


-(void) returnTipsOfUser: (NSString *) userId calledFrom:(NSString *) vw {
    
    
    [self prepareForRequest];
    CalledFromView = vw;
    NSString *rpath;
    rpath = [NSString stringWithFormat: @"users/%@/tips?sort=recent",userId];
    self.request = [foursquare_ requestWithPath:rpath HTTPMethod:@"GET" parameters:nil delegate:self];
    [request_ start];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
}



@end
