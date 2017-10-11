//
//  gnshkMapAnnotaion.h
//  Goonjishk
//
/*
 
 This class creates the annotations for mapview
 
 */

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface gnshkMapAnnotaion : NSObject<MKAnnotation>{
    NSString *title;
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;

@end