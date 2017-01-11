//
//  Annotation.h
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ServiceManager.h"

@interface Annotation : NSObject<MKAnnotation>
- (id) initWithValuesFromDictionary: (NSDictionary *) dictionary;

@property (nonatomic, strong) UIImage * cachedBigImage;         // cached image, original (big) version
@property (nonatomic, strong) UIImage * cachedThumbnailImage;   // cached image, thumbnail
@property (nonatomic, strong) NSString * imageTitle;            // The name(title) of the Flickr Photo (if any)
@property (nonatomic, strong) NSString * bigImageURL;           // original (big) image data
@property (nonatomic, strong) NSString * thumbnailImageURL;
@end
