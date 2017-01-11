//
//  Annotation.m
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import "Annotation.h"
#define kNearbyFlickrPhotosDictionaryParameterLongitude     @"longitude"
#define kNearbyFlickrPhotosDictionaryParameterLatitude      @"latitude"
#define kNearbyFlickrPhotosDictionaryParameterTitle         @"title"
#define kNearbyFlickrPhotosDictionaryParameterThumbnailURL  @"url_t"
#define kNearbyFlickrPhotosDictionaryParameterBigURL        @"url_m"
#define kNearbyFlickrPhotosDictionaryParameterThumbnailURL  @"url_t"
@implementation Annotation

@synthesize coordinate = _coordinate;

- (id) initWithValuesFromDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) { // fill Flickr Photo Annotation parameters from REST API response
        // Thumbnail image
        if (dictionary[kNearbyFlickrPhotosDictionaryParameterThumbnailURL]) {
            self.thumbnailImageURL = dictionary[kNearbyFlickrPhotosDictionaryParameterThumbnailURL];
            [[ServiceManager sharedInstance] loadRemoteImageFromURL:[NSURL URLWithString:self.thumbnailImageURL] andExecuteBlock:^(BOOL success, UIImage *image, NSURL *url) {
                if (success) {
                    self.cachedThumbnailImage = image;
                }
            }];
        }
        if (!self.cachedThumbnailImage) self.cachedThumbnailImage = [UIImage imageNamed:@"unknownImage"];
        
        // Big image
        self.bigImageURL = dictionary[kNearbyFlickrPhotosDictionaryParameterBigURL];
        
        // Location
        _coordinate = CLLocationCoordinate2DMake([dictionary[kNearbyFlickrPhotosDictionaryParameterLatitude] floatValue], [dictionary[kNearbyFlickrPhotosDictionaryParameterLongitude] floatValue]);
        
        // Title
        if (dictionary[kNearbyFlickrPhotosDictionaryParameterTitle]) {
            self.imageTitle = dictionary[kNearbyFlickrPhotosDictionaryParameterTitle];
        } else self.imageTitle = @"Unknown Photo";
    }
    return self;
}

- (NSString *) title { return self.imageTitle; }
- (NSString *) subtitle { return nil; }

@end
