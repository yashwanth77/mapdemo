//
//  ViewController.m
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import "ViewController.h"
#import "Annotation.h"
#import "DetailViewController.h"

#define kNearbyFlickrPhotosAnnotationName       @"Annotation"
#define kNearbyFlickrShowPhotoInDetailSegue     @"ShowPhotoInDetail"

static BOOL firstLocationHasBeenRetrieved = NO;

@interface ViewController ()
/** Main map view */

/** Map Annotations containing the photos and details extracted from Flickr REST API */
@property (nonatomic, strong) NSArray * mapAnnotations;

/** Current user's location */
@property (nonatomic) CLLocationCoordinate2D userLocation;

/** Image to show in the segue for detail Flickr Photo */
@property (nonatomic, strong) Annotation * selectedFlickrPhoto;

/** Loading quick dialog alert */
@property (nonatomic, strong) UIAlertView * loadingAlert;

/** CLLocationManager needed for retrieving the user location since iOS 8 */
@property (nonatomic, strong) CLLocationManager * locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.mapView.camera = [GMSCameraPosition
//                                 cameraWithLatitude:self.mapView.camera.target.latitude
//                                 longitude:self.mapView.camera.target.longitude
//                                 zoom:kGMSMinZoomLevel
//                                 bearing:self.mapView.camera.bearing
//                                 viewingAngle:self.mapView.camera.viewingAngle];
//    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(10, 10);
//    GMSMarker *marker = [GMSMarker markerWithPosition:position];
//    marker.title = @"Hello World";
//    marker.map = self.mapView;
//    
//    CLLocationCoordinate2D position1 = CLLocationCoordinate2DMake(37.810000, -122.477989);
//    GMSMarker *marker1 = [GMSMarker markerWithPosition:position1];
//    marker1.title = @"Hello World";
//    marker1.map = self.mapView;
//    
//    CLLocationCoordinate2D position2 = CLLocationCoordinate2DMake(39.9042,116.4074);
//    GMSMarker *marker2 = [GMSMarker markerWithPosition:position2];
//    marker2.title = @"Hello World";
//    marker2.map = self.mapView;
//    
//    CLLocationCoordinate2D position3 = CLLocationCoordinate2DMake(40.7128, 74.0059);
//    GMSMarker *marker3 = [GMSMarker markerWithPosition:position3];
//    marker3.title = @"Hello World";
//    marker3.map = self.mapView;
//    
//    CLLocationCoordinate2D position4 = CLLocationCoordinate2DMake(61.9241, 25.7482);
//    GMSMarker *marker4 = [GMSMarker markerWithPosition:position4];
//    marker4.title = @"Hello World";
//    marker4.map = self.mapView;
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    MKCoordinateSpan span = {.latitudeDelta = 180, .longitudeDelta = 360};
    
    // step.2 crate region as follows
    MKCoordinateRegion region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0000f, 0.0000f), span);
    
    // step.3 zoom using region to map as follows
    [self.mapView setRegion:region animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/** Lazily update map annotations when array contents change */
- (void) setMapAnnotations:(NSArray *)mapAnnotations {
    _mapAnnotations = mapAnnotations;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.mapAnnotations];
    //MKCoordinateRegion region = MKCoordinateRegionMake(self.mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
    //[_mapView setRegion:region animated:YES];
   
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!firstLocationHasBeenRetrieved) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [self.locationManager requestWhenInUseAuthorization];
#endif
        self.mapView.showsUserLocation = NO;
    }
}

#pragma mark map and annotations methods

/**
 * @brief Generates the annotations from the entries received from the Flickr REST API
 * @param entries an array of JSON extracted NSDictionary entries with the Flickr photos
 */
- (void) generateMapAnnotationsForEntries: (NSArray *) entries {
    NSMutableArray * newMapAnnotations = [NSMutableArray arrayWithCapacity:entries.count];
    for (NSDictionary * entry in entries) {
        Annotation * fpa = [[Annotation alloc] initWithValuesFromDictionary: entry];
        if (fpa) [newMapAnnotations addObject:fpa];
    }
    
    self.mapAnnotations = [newMapAnnotations copy];
    [self.mapView setNeedsDisplay];
}

#pragma mark MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self updateFlickrImagesInMap];
}

- (void) updateFlickrImagesInMap {
    CLLocationCoordinate2D bottomLeft = [self getBottomLeftCornerOfMap];
    CLLocationCoordinate2D topRight = [self getTopRightCornerOfMap];
    
    [[ServiceManager sharedInstance] loadFlickrImagesFromLocation:bottomLeft toLocation:topRight andExecuteBlock:^(BOOL success, NSArray *entries) {
        if (success) {
            [self generateMapAnnotationsForEntries:entries];
        } else self.mapAnnotations = @[];
    }];
}

// mapView:viewForAnnotation: provides the view for each annotation.
// This method may be called for all or some of the added annotations.
// For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // return user's location default blue dot if annotation is user's location
    if (annotation == mapView.userLocation) return nil;
    
    
    // else show flickr photo annotation
    MKPinAnnotationView * mkav =  nil; //(MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:nil];
    if (!mkav) {
        mkav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: nil];
        mkav.canShowCallout = YES;
        mkav.enabled = YES;
        
        mkav.leftCalloutAccessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton * entryButton = (UIButton *) mkav.leftCalloutAccessoryView;
        [entryButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    mkav.annotation = annotation;
    return mkav;
    
}


// mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    NSString * originalPhotoURL = nil;
    if ([view.annotation isKindOfClass:[Annotation class]]) {
        originalPhotoURL = [(Annotation *) view.annotation bigImageURL];
    }
    
    if (originalPhotoURL) { // If we do have a photo, try to download and segue to show it.
        [self showLoadingAlert];
        [[ServiceManager sharedInstance] loadRemoteImageFromURL:[NSURL URLWithString:originalPhotoURL] andExecuteBlock:^(BOOL success, UIImage *image, NSURL *url) {
            dispatch_async(dispatch_get_main_queue(), ^{ // update UX/UI only in main thread
                if (success) {
                    Annotation * ann = (Annotation *) view.annotation;
                    ann.cachedBigImage = image;
                    self.selectedFlickrPhoto = ann;
                    [self closeLoadingAlert];
                    [self performSegueWithIdentifier:kNearbyFlickrShowPhotoInDetailSegue sender:nil];
                } else {
                    [self closeLoadingAlert];
                    [self showAlertWithMessage:@"Error loading image from Flickr" isError:YES];
                }
            });
        }];
    } else [self showAlertWithMessage:@"Unable to load image from Flickr" isError:YES];
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIButton class]]) {
        view.leftCalloutAccessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton * entryButton = (UIButton *) view.leftCalloutAccessoryView;
        [entryButton setImage:nil forState:UIControlStateNormal];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIButton class]]) {
        if ([view.annotation isKindOfClass:[Annotation class]]) {
            Annotation * fpa = (Annotation *) view.annotation;
            UIImage * image = fpa.cachedThumbnailImage;
            UIButton * entryButton = (UIButton *) view.leftCalloutAccessoryView;
            [entryButton setImage:image forState:UIControlStateNormal];
            [entryButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.userLocation = userLocation.coordinate;
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    if (!firstLocationHasBeenRetrieved) {
        firstLocationHasBeenRetrieved = YES;
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
        
        // calculate first nearby photos
        [self updateFlickrImagesInMap];
    }
}

- (CLLocationCoordinate2D) getBottomLeftCornerOfMap {
    return [self.mapView convertPoint:CGPointMake(0, self.mapView.frame.size.height) toCoordinateFromView:self.mapView];
}

- (CLLocationCoordinate2D) getTopRightCornerOfMap {
    return [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width, 0) toCoordinateFromView:self.mapView];
}

#pragma mark messages and alerts

- (void) showAlertWithMessage: (NSString *) message isError: (BOOL) error {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:error?@"Error":@"Message" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

- (void) showLoadingAlert {
    self.loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [self.loadingAlert show];
}

- (void) closeLoadingAlert {
    if (self.loadingAlert) {
        [self.loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.loadingAlert = nil;
    }
}


#pragma mark navigation and segues

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kNearbyFlickrShowPhotoInDetailSegue]) {
        DetailViewController * pdvc = (DetailViewController *) segue.destinationViewController;
        pdvc.imageToShowInDetail = self.selectedFlickrPhoto.cachedBigImage?self.selectedFlickrPhoto.cachedBigImage:self.selectedFlickrPhoto.cachedThumbnailImage;
        pdvc.photoTitle = self.selectedFlickrPhoto.title;
        pdvc.photoCoordinate = self.selectedFlickrPhoto.coordinate;
    }
}

#pragma mark CLLocationManager delegate methods

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self closeLoadingAlert];
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) { // we got authorized.
        [self.locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
    } else if (status == kCLAuthorizationStatusRestricted) {
        [self showAlertWithMessage:@"Unable to retrieve your location. Unable to retrieve nearby Flickr photos" isError:YES];
    } else if (status == kCLAuthorizationStatusDenied) {
        [self showAlertWithMessage:@"You must authorize access to your location to NearbyFlickrPhotos if you want to retrieve the nearby Flickr photos" isError:YES];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!locations || locations.count < 1) return;
    NSLog(@"Got locations: %@", locations);
    [self.locationManager stopUpdatingLocation];
    
    self.userLocation = [(CLLocation *) [locations lastObject] coordinate];
    [self.mapView setCenterCoordinate:self.userLocation animated:YES];
    if (!firstLocationHasBeenRetrieved) {
        firstLocationHasBeenRetrieved = YES;
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
        
        // calculate first nearby photos
        [self updateFlickrImagesInMap];
        
    }
    
}

@end
