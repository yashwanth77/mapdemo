//
//  DetailViewController.h
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController : UIViewController
@property (nonatomic, strong) UIImage * imageToShowInDetail;
@property (nonatomic, strong) NSString * photoTitle;
@property (nonatomic) CLLocationCoordinate2D photoCoordinate;
@end
