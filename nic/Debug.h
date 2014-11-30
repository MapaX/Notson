//
//  Debug.h
//  NIC
//
//  Created by Heikki Junnila on 25.11.2014.
//  Copyright (c) 2012 Nordea. All rights reserved.
//

#ifndef NIC_Debug_h
#define NIC_Debug_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [L:%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#endif
