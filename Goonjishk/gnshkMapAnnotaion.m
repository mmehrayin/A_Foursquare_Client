//
//  gnshkMapAnnotaion.m
//  Goonjishk
/*
 
 This class creates the annotations for mapview
 
 */

#import "gnshkMapAnnotaion.h"

@implementation gnshkMapAnnotaion

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	self = [super init];
	title = ttl;
	coordinate = c2d;
	return self;
}



@end
