//
//  WandAppDelegate.h
//  Wand
//
//  Created by icarvell on 1/17/12.
//  Copyright 2012 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WandViewController;

@interface WandAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WandViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WandViewController *viewController;

@end

