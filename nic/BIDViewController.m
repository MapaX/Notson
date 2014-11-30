//
//  BIDViewController.m
//  Camera
//
//  Created by Ejay on 11/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

#import "BIDViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import <MobileCoreServices/UTCoreTypes.h>
#import "AppDelegate.h"

@interface BIDViewController ()
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UITextField *userNameLabel;


@property(strong, nonatomic) MPMoviePlayerController *moviePlayerController;
@property (strong,nonatomic) UIImageView *image;
@property (copy, nonatomic)  NSString *lastChosenMediaType;

@end

@implementation BIDViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if(![UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
           {
               self.takePictureButton.hidden =YES;
           }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.userNameLabel setDelegate:self];
    
    NSString* username = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
    if (username) {
        [self.userNameLabel setText:username];
    }
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.userNameLabel resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [self.userNameLabel resignFirstResponder];
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)shootPictureOrVideo:(id)sender
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectExistingPictureOrVideo:(id)sender
{
    [self pickMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)pickMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediaTypes = [UIImagePickerController
                           availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController
         isSourceTypeAvailable:sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
                               availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"Error accessing media"
                                   message:@"Unsupported media source."
                                  delegate:nil
                         cancelButtonTitle:@"Drat!"
                         otherButtonTitles:nil];
        [alert show];
    }
}

- (UIImageView *)shrinkImage:(UIImage *)original toSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGFloat originalAspect = original.size.width / original.size.height;
    CGFloat targetAspect = size.width / size.height;
    CGRect targetRect;
    
    if (originalAspect > targetAspect) {
        // original is wider than target
        targetRect.size.width = size.width;
        targetRect.size.height = size.height * targetAspect / originalAspect;
        targetRect.origin.x = 0;
        targetRect.origin.y = (size.height - targetRect.size.height) * 0.5;
    } else if (originalAspect < targetAspect) {
        // original is narrower than target
        targetRect.size.width = size.width * originalAspect / targetAspect;
        targetRect.size.height = size.height;
        targetRect.origin.x = (size.width - targetRect.size.width) * 0.5;
        targetRect.origin.y = 0;
    } else {
        // original and target have same aspect ratio
        targetRect = CGRectMake(0, 0, size.width, size.height);
    }
    
    [original drawInRect:targetRect];
    UIImage *final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView* finalImageView = [[UIImageView alloc]init];
    finalImageView.layer.cornerRadius = final.size.width / 2;
    finalImageView.clipsToBounds = YES;
    return finalImageView;
}

#pragma mark - Image Picker Controller delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage* chosenImage = info[UIImagePickerControllerEditedImage];
    if (chosenImage) {
        self.imageView.image = chosenImage;
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        self.imageView.clipsToBounds = YES;
        //self.imageView.image = [self shrinkImage:chosenImage
                              //  toSize:self.imageView.bounds.size].image;
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate setSelfie:chosenImage];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"selfie.png"]; //Add the file name
        NSData *pngData = UIImagePNGRepresentation(chosenImage);
        [pngData writeToFile:filePath atomically:YES]; //Write the file
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    if ([self.userNameLabel.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameLabel.text forKey:kUserName];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end

