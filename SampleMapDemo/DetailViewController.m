//
//  DetailViewController.m
//  SampleMapDemo
//
//  Created by Yashwanth on 1/10/17.
//  Copyright © 2017 Yashwanth. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (nonatomic, weak) IBOutlet UIImageView * backgroundImage;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (nonatomic, weak) IBOutlet UILabel * subtitleLabel;
@property (nonatomic, weak) IBOutlet UIButton * getBackButton;
@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // fill the photo fields
    if (self.imageToShowInDetail) self.backgroundImage.image = self.imageToShowInDetail;
    if (self.photoTitle) self.titleLabel.text = self.photoTitle;
    else self.photoTitle = @"Unknown title";
    if (CLLocationCoordinate2DIsValid(self.photoCoordinate)) self.subtitleLabel.text = [NSString stringWithFormat:@"Longitude %f, Latitude %f", self.photoCoordinate.longitude, self.photoCoordinate.latitude];
    else self.subtitleLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Button actions

- (IBAction)getBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark messages and alerts

- (void) showAlertWithMessage: (NSString *) message isError: (BOOL) error {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:error?@"Error":@"Message" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

@end
