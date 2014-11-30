//
//  Bubble.m
//  nic
//
//  Created by Miikka Pakkanen on 29/11/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "Bubble.h"
#import "MyEconomicsMeViewController.h"
#import "SmileyView.h"

@implementation Bubble

- (void)blobInView:(UIView *)view inPosition:(CGPoint)position
{
    self.bubbleView = [[BubbleView alloc] initWithFrame:CGRectMake(position.x + self.bubbleSize * kBubbleMaxSize / 2, position.y + self.bubbleSize * kBubbleMaxSize / 2, 0, 0)];
    if ([self.bubbleTitle length] == 0)
    {
        [self.bubbleView setDrawEstimate:YES];
    }
    self.bubbleView.backgroundColor = [UIColor clearColor];
    [self.bubbleView setMainColor:self.bubbleColor];
    [self.bubbleView setSpent:self.spending];
    [self.bubbleView setAutoresizesSubviews:YES];
    [view addSubview:self.bubbleView];
    
    UILabel *bubbleLabel = [[UILabel alloc] initWithFrame:self.bubbleView.frame];
    [bubbleLabel setTextAlignment:NSTextAlignmentCenter];
    [bubbleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [bubbleLabel setText:[self.bubbleTitle uppercaseString]];
    [bubbleLabel setTextColor:[UIColor whiteColor]];
    [bubbleLabel setMinimumScaleFactor:0.1];
    bubbleLabel.numberOfLines = 1;
    bubbleLabel.adjustsFontSizeToFitWidth = YES;

    [self.bubbleView addSubview:bubbleLabel];
    if (self.image)
    {
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        [self.imageView setFrame:CGRectMake(12, 12, self.bubbleSize * kBubbleMaxSize - 24, self.bubbleSize * kBubbleMaxSize - 24)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageView setClipsToBounds:YES];
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        [self.bubbleView addSubview:self.imageView];
        [self.bubbleView bringSubviewToFront:self.imageView];
        
        UIButton *iButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage = [UIImage imageNamed:@"smileyFace"];
        [iButton setFrame:CGRectMake(0, 0, btnImage.size.width, btnImage.size.height)];
        [iButton setImage:btnImage forState:UIControlStateNormal];
        if (_smileyFactor == 1.0)
        {
            [iButton.imageView setTintColor:[UIColor redColor]];
        }
        else
        {
            [iButton.imageView setTintColor:[UIColor greenColor]];
        }
        [iButton setCenter:CGPointMake((self.bubbleSize * kBubbleMaxSize)-17, 17)];
        [self.bubbleView addSubview:iButton];
        [iButton addTarget:self action:@selector(iButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        // Do smile on the iButton
        SmileyView *smiley = [[SmileyView alloc] initWithFrame:CGRectMake(0,0,iButton.frame.size.width, iButton.frame.size.height)];
        [smiley setSmileFactor:self.smileyFactor];
        [smiley setBackgroundColor:[UIColor clearColor]];
        [smiley setUserInteractionEnabled:NO];
        [iButton addSubview:smiley];
        [iButton bringSubviewToFront:smiley];
    }
    else if (!self.bubbleTitle){
        UIImage* camera = [UIImage imageNamed:@"CameraIcon_white"];
        self.imageView = [[UIImageView alloc] initWithImage:camera];
        [self.imageView setFrame:CGRectMake(12, 12, self.bubbleSize * kBubbleMaxSize - 24, self.bubbleSize * kBubbleMaxSize - 24)];
        [self.imageView setContentMode:UIViewContentModeCenter];
        [self.imageView setClipsToBounds:YES];
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        [self.bubbleView addSubview:self.imageView];
        [self.bubbleView bringSubviewToFront:self.imageView];        
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = CGRectMake(position.x, position.y, self.bubbleSize * kBubbleMaxSize, self.bubbleSize * kBubbleMaxSize);
        [self.bubbleView setFrame:frame];
        [bubbleLabel setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }];
    
}

- (void)iButtonTapped
{
    [[[UIAlertView alloc] initWithTitle:@"How am I doing?" message:@"\nGreat job on saving in Car expenses, you'll be 15% below your average budget in this period!\n\nHowever, you should be aware that you've already gone over the Food budget, and may spend 10% more than your average in that category." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end
