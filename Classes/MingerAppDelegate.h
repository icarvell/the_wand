//
//  MingerAppDelegate.h
//  Minger
//
//  Created by icarvell on 1/17/12.
//  Copyright 2012 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MingerViewController;

@interface MingerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MingerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MingerViewController *viewController;

@end

