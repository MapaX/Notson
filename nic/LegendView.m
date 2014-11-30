//
//  LegendView.m
//  Notson
//
//  Created by Heikki Junnila on 07/03/14.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "LegendView.h"

#define COLOR_DARKEN_AMOUNT 0.2

@interface LegendView ()
@property (nonatomic, weak) IBOutlet UIView* view;
@property (nonatomic, weak) IBOutlet UIView* color;
@property (nonatomic, weak) IBOutlet UILabel* valueLabel;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@end

@implementation LegendView

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    DLog();

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSBundle mainBundle] loadNibNamed:@"LegendView" owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:@"iPadLegendView" owner:self options:nil];
    }
    [self addSubview:self.view];

    [self.valueLabel setText:@""];
    [self.titleLabel setText:@""];
    [self.titleLabel setTextColor:UIColorFromRGB(0x404040)];

    [self.color setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void) setupWithValue:(NSString*)value title:(NSString*)title color:(UIColor*)color darkenText:(BOOL)darkenText
{
    DLog();

    [self.titleLabel setText:title];
    [self.valueLabel setText:value];
    [self.color setBackgroundColor:color];
    [self.valueLabel setTextColor:color];
}

- (void) makeCompact
{
    DLog();

    // Reduce font size and move the labels a bit closer together to make the legend a bit more compact.
    UIFont* valueFont = self.valueLabel.font;
    [self.valueLabel setFont:[UIFont boldSystemFontOfSize:valueFont.pointSize - 3]];

    UIFont* titleFont = self.titleLabel.font;
    [self.titleLabel setFont:[UIFont systemFontOfSize:titleFont.pointSize - 3]];

    CGRect r = self.valueLabel.frame;
    r.origin.y += 1;
    self.valueLabel.frame = r;

    r = self.titleLabel.frame;
    r.origin.y -= 1;
    self.titleLabel.frame = r;

    r = self.color.frame;
    r.origin.y += 2;
    r.size.height = 26;
    self.color.frame = r;
}

+ (CGSize) defaultSize
{
    return CGSizeMake(92, 35);
}

@end
