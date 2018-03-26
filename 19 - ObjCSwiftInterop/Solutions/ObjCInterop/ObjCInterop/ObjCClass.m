#import "ObjCClass.h"

#import "ObjCInterop-Swift.h"

@implementation ObjCClass

- (void)setDate:(NSDate *)date {
    NSLog(@"SNOOGLE set a date with %@ (%p)", date, date);
}

- (void)setData:(NSData *)data {
    NSLog(@"SNOOGLE set a data with %@ (%p)", data, data);
}


- (void)changeButtonTitle:(UIButton *)button {
    [button bnr_setTheTitle: @"ObjC"]; 
}


- (void)addCallbackToButton:(UIButton *)button {
    [button addTarget: self
               action: @selector(showAboutBox)
     forControlEvents: UIControlEventTouchUpInside];
}

- (void) showAboutBox {
    NSLog(@"pretending to show about box from Objective-C");
}


- (BOOL)messWithFileSystem:(NSString *)source  destination:(NSString *)toPath
         error:(NSError **)error {

    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *fmError;

    BOOL success = [fm moveItemAtPath: source  toPath: toPath  error: &fmError];
    if (!success) {
        if (error) *error = fmError;
        return NO;  // Tell the caller an error happened.
    }
    
    return YES; // yay, success
}


- (void)useSwiftErrorFunc {
    NSError *error;
    BOOL status = [self.swift errorFuncAndReturnError: &error];
    NSLog(@"status %d from Swift", status);
    if (!status) {
        NSLog(@"Got an error from Swift: %@", error);
    }
}



@end
