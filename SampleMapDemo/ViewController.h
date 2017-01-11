//
//  ViewController.h
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "ServiceManager.h"
#import "DetailViewController.h"
#import "Annotation.h"

@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//@property (strong, nonatomic) IBOutlet GMSMapView *mapView;


@end

