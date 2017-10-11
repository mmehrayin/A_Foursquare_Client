/*
    gnshkSessionHandler.h
    Goonjishk

    In this class we create an instance of Foursquare object and make it available to all views
  
*/

#import <Foundation/Foundation.h>
#import "BZFoursquare.h"

@interface gnshkSessionHandler : NSObject <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate> {

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

-(id) initWithCoder;
+(id) sharedFoursquare;
- (void)searchVenues:(NSString *) locS calledFrom: (NSString *) vw;
- (void)returnPics:(NSString *) locId calledFrom: (NSString *) vw;
- (void)checkin: (NSString *) venueId checkInMessage:(NSString *)checkInMessage broadcastType:(NSString *)broadcastType calledFrom: (NSString *) vw;
- (void)addPhoto: (NSString *) checkInId jpgImage:(NSData *) jpgImage calledFrom: (NSString *) vw;
-(void)returnFriends:(NSString *) vw;
-(void) returnMayorships: (NSString *) userId calledFrom:(NSString *) vw;
-(void) returnTipsOfUser: (NSString *) userId calledFrom:(NSString *) vw;



@end
