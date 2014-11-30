//
//  Macros.h
//  nic
//
//  Created by Heikki Junnila on 25.11.2014.
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#ifndef nic_Macros_h
#define nic_Macros_h

// RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
    blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:a]

// Create a random number
#define random(x) (arc4random() % ((unsigned)x))

//! Clamp $x between $low and $high
#define CLAMP(x, low, high) (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

// Conversion between degrees and radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#endif
