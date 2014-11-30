//
//  PieChartView.h
//  Notson
//
//  Created by Heikki Junnila on 05/03/14
//  Copyright (c) 2014 Nordea. All rights reserved.
//

#import "ChartViewBase.h"

#define PIE_ZERO_ANGLE_DEGREES 270

@interface PieChartView : ChartViewBase
@property (nonatomic, assign) float zeroAngle;
@end