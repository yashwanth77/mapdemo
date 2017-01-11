//
//  ServiceManager.h
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface ServiceManager : NSObject
+ (ServiceManager *) sharedInstance;

- (void) loadRemoteImageFromURL: (NSURL *) url andExecuteBlock: ( void (^) (BOOL success, UIImage * image, NSURL * url) ) block;

- (void) loadFlickrImagesFromLocation: (CLLocationCoordinate2D) bottomLeft toLocation: (CLLocationCoordinate2D) topRight andExecuteBlock: ( void (^) (BOOL success, NSArray * entries) ) block;

@end
