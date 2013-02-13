//
//  MingerViewController.h
//  Minger
//
//  Created by icarvell on 1/17/12.
//  Copyright 2012 ThoughtWorks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../AFNetworking/AFHTTPRequestOperation.h"
#import "../AFNetworking/AFXMLRequestOperation.h"
#import "../AFNetworking/AFJSONRequestOperation.h"
#import "../AFNetworking/AFHTTPClient.h"
#import <AudioToolbox/AudioServices.h>

@interface MingerViewController : UIViewController <ZBarReaderDelegate, UIAccelerometerDelegate, NSXMLParserDelegate>
{
    UIImageView *resultImage;
    UITextView *resultText;
    
    UITextField *propertyText;
    UITextField *projectText;
    UITextField *serveripText;
    
    UIActivityIndicatorView *progressIndicator;
    
    NSMutableArray *cards;
    
    UIAccelerationValue accelerationArray[3];
    
    ZBarReaderViewController *reader;
    
    NSString *currentPropertyValue;
    
    NSString *currentCardNumber;
    
    BOOL *monitorAccel;
    
    NSString *moveCardForward;
    
    UITextField *readerHelpText;

}

- (NSString*)getCardFromMingle:(NSString *)cardNumber;

- (void)postCardToMingle:(NSString *)cardNumber withProperty:(NSString *)propertyName withValue:(NSString *)propertyValue;

- (void)bulkUpdateWithPropertyFinish: (ZBarSymbol*) symbol withReader:(UIImagePickerController*) reader;

- (void)closeReaderTalkToMingle: (NSString*) propertyName; 

- (NSString*)mingleBaseUrl;

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UITextView *resultText;
@property (nonatomic, retain) IBOutlet UITextField *propertyText;
@property (nonatomic, retain) IBOutlet UITextField *projectText;
@property (nonatomic, retain) IBOutlet UITextField *serveripText;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *progressIndicator;

- (IBAction) scanButtonTapped;
@end