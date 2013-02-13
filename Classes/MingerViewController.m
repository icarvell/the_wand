//
//  MingerViewController.m
//  Minger
//
//  Created by icarvell on 1/17/12.
//  Copyright 2012 ThoughtWorks. All rights reserved.
//

#import "MingerViewController.h"

@implementation MingerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
    theAccelerometer.updateInterval = 0.1;
    theAccelerometer.delegate = self;    
    resultText.textColor = [UIColor whiteColor];
    resultText.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor blackColor];
    progressIndicator.hidesWhenStopped = YES;
    
    NSLog([self mingleBaseUrl]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];	
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
	self.resultImage = nil;
    self.resultText = nil;
    self.propertyText = nil;
    self.projectText = nil;
    self.serveripText = nil;
    
    cards = nil;
    reader = nil;
    currentPropertyValue = nil;
    currentCardNumber = nil;
    monitorAccel = nil;
    readerHelpText = nil;
}

@synthesize resultImage, resultText;
@synthesize propertyText, projectText, serveripText;

- (IBAction) scanButtonTapped
{	
    self.resultText.text = @"";
    resultText.alpha = 0;
    
    monitorAccel = true;
    
    reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
	
    ZBarImageScanner *scanner = reader.scanner;

    [scanner setSymbology: ZBAR_I25
				   config: ZBAR_CFG_ENABLE
					   to: 0];
    reader.showsZBarControls = NO;
    
    UIView *headsUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    headsUpView.userInteractionEnabled = YES;
    reader.cameraOverlayView = headsUpView;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect frame = CGRectMake(0, height - 80, width, 29);
    
    UIColor *mingleOrange = [UIColor colorWithRed:1 green:0.455 blue:0 alpha:1]; /*#ff7400*/ 
    readerHelpText.backgroundColor = mingleOrange;
    readerHelpText = [[UITextField alloc] initWithFrame:frame];
    readerHelpText.backgroundColor = mingleOrange;
    readerHelpText.hidden = YES;
    readerHelpText.textAlignment = UITextAlignmentCenter;
    [headsUpView addSubview:readerHelpText];
    
	reader.readerView.zoom = 1.0;

	cards = [[NSMutableArray alloc] init];
	    
    [self presentModalViewController: reader
							animated: YES];	
}
 
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return(NO);
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{	
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
	ZBarSymbol *symbol = nil;

    for(symbol in results)
        break;
    
    [self bulkUpdateWithPropertyFinish: symbol withReader: reader];	
}

- (void)bulkUpdateWithPropertyFinish: (ZBarSymbol*) symbol withReader:(UIImagePickerController*) reader {
    NSString *matchBarcode = @"property";	
	if(!NSEqualRanges(NSMakeRange(NSNotFound, 0), [symbol.data rangeOfString:matchBarcode])){
        [self closeReaderTalkToMingle: symbol.data];
	} else {        
        readerHelpText.hidden = NO;                
        readerHelpText.text = [NSString stringWithFormat:@"Flick to move #%@.", symbol.data];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [cards removeAllObjects];
		[cards addObject:symbol.data];
	}    
}

- (void)closeReaderTalkToMingle: (NSString*) propertyName {
    [reader dismissModalViewControllerAnimated: YES];
    [progressIndicator startAnimating];
    
    NSString *updatedCards = @"";
    
    NSEnumerator *e = [cards objectEnumerator];
    id cardNumber;
    while (cardNumber = [e nextObject]) {

        updatedCards = [updatedCards stringByAppendingString:[NSString stringWithFormat:@" %@", cardNumber]];
                
        NSString* propertyToUpdate = propertyName;
        
        currentCardNumber = cardNumber;
        
        NSString *currentValueForCard = [self getCardFromMingle:cardNumber];                        
        
    }		
}

- (void)postCardToMingle:(NSString *)cardNumber withProperty:(NSString *)propertyName withValue:(NSString *)propertyValue {
	
    NSLog(@"post the card");
    
	NSString *post = [NSString stringWithFormat:@"card[properties][][name]=%@&card[properties][][value]=%@", 
                      propertyName, propertyValue];
    
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
        
    NSString *url = [NSString stringWithFormat:@"%@/cards/%@.xml", [self mingleBaseUrl], cardNumber];
    
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"PUT"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	// send it
	NSError        *error = nil;
    NSURLResponse  *response = nil;
	NSData *serverReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
}


- (void)methodUsingJsonFromSuccessBlock:(id)json {
    currentPropertyValue = [NSString stringWithFormat:@"%@", [json valueForKeyPath:@"Status"]];
    currentPropertyValue = [currentPropertyValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
    currentPropertyValue = [currentPropertyValue stringByReplacingOccurrencesOfString:@")" withString:@""];
    currentPropertyValue = [currentPropertyValue stringByReplacingOccurrencesOfString:@"\"" withString:@""];        
    currentPropertyValue = [currentPropertyValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSArray *potentialValuesOfProperty = [NSArray arrayWithObjects: @"New", @"Open", @"Analysis In Progress", @"Ready for Development", @"Dev In Progress", @"Development Complete" ,@"Ready for Showcase", @"Accepted", @"Blocked", @"Deleted", @"Story Status", nil];
    
    NSUInteger index = [potentialValuesOfProperty indexOfObject:currentPropertyValue];
    
    if(index != NSNotFound){
        
        NSString *newValue;
        if([moveCardForward isEqualToString:@"plus"]){
            newValue = [potentialValuesOfProperty objectAtIndex:index + 1];
        }else{
            newValue = [potentialValuesOfProperty objectAtIndex:index + 1];
        }
            
        NSLog(@"set %@ from %@ -to %@", currentCardNumber, currentPropertyValue, newValue);
        [self postCardToMingle:currentCardNumber withProperty:@"Status" withValue:newValue];
        
        
        
        self.resultText.text = [NSString stringWithFormat: @"#%@ moved to %@", currentCardNumber, newValue];
        
        
        resultText.alpha = 1;
        resultText.transform = CGAffineTransformIdentity;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:5];
        //makes text fade in 100%
        resultText.alpha = 0;
        [UIView commitAnimations];
        
        
        
    }
    [progressIndicator stopAnimating];
}


- (NSString*)getCardFromMingle:(NSString *)cardNumber {
    
    NSLog(@"get the card");
    
    
    NSString *url_path = [NSString stringWithFormat:
                     @"%@/cards/execute_mql.json?mql=SELECT%%20Status%%20WHERE%%20Type=story%%20AND%%20NUMBER=%@",[self mingleBaseUrl], cardNumber];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_path]];
    
    __block id data;
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                
        currentPropertyValue = [NSString stringWithFormat:@"%@", [JSON valueForKeyPath:@"Status"]];
        currentPropertyValue = [currentPropertyValue stringByReplacingOccurrencesOfString:@"(" withString:@""];
        currentPropertyValue = [currentPropertyValue stringByReplacingOccurrencesOfString:@")" withString:@""];        
        currentPropertyValue = [currentPropertyValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self methodUsingJsonFromSuccessBlock:JSON];

    } failure:nil];
  
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation: operation];
    return currentPropertyValue;
    
}

- (NSString*)mingleBaseUrl{    
    NSString *username = @"admin";
    NSString *password = @"p";

    return [NSString stringWithFormat:@"http://%@:%@@%@/api/v2/projects/%@", username, password, serveripText.text, projectText.text];
}



// ACCELL STUFF

// High-pass filter constant
#define HIGHPASS_FILTER 0.1

// Axis
#define X_DIR  0
#define Y_DIR  1
#define Z_DIR  2

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
    // High pass filter
    accelerationArray[X_DIR] = acceleration.x - ((acceleration.x * HIGHPASS_FILTER) + (accelerationArray[X_DIR] * (1.0 - HIGHPASS_FILTER)));
    accelerationArray[Y_DIR] = acceleration.y - ((acceleration.y * HIGHPASS_FILTER) + (accelerationArray[Y_DIR] * (1.0 - HIGHPASS_FILTER)));
    accelerationArray[Z_DIR] = acceleration.z - ((acceleration.z * HIGHPASS_FILTER) + (accelerationArray[Z_DIR] * (1.0 - HIGHPASS_FILTER)));
 
    if(monitorAccel && [cards count] > 0 ) {    
        if (acceleration.x - accelerationArray[X_DIR] > 0.3 )
        {
            
            NSLog(@"right");
            moveCardForward = @"plus";
            [self closeReaderTalkToMingle: propertyText.text];
            monitorAccel = false;   
//            [reader dismissModalViewControllerAnimated: YES];
            
        } else if(acceleration.x - accelerationArray[X_DIR] < -0.3) {
                        moveCardForward = @"minus";
                        NSLog(@"left");
            [self closeReaderTalkToMingle: propertyText.text];
            monitorAccel = false;
        }
    }
    
    
}
@end
