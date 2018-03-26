#import "ViewController.h"
#import "ObjCClass.h"
#import "CInterop-Swift.h"  // new

@interface ViewController ()
@property (strong, nonatomic) ObjCClass *objc;
@property (strong, nonatomic) SwiftClass *swift;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objc = ObjCClass.new;
    self.swift = SwiftClass.new;
    
    self.objc.swift = self.swift;
    self.swift.objc = self.objc;
}

- (IBAction) printToConsole {
    [self.objc printStuffToConsole];
} // printToConsole

- (IBAction) callSwiftCode {
    [self.objc callSwift];
}

- (IBAction) bitSets {
    [self.objc playWithBitSets];
}

- (IBAction) enums {
    [self.objc enumNumNum];
}

- (IBAction) structs {
    [self.objc useStructs];
}

- (IBAction) closures {
    [self.objc useBlocks];
}

- (IBAction) functionPointers {
    [self.objc useFunctionPointers];
}

- (IBAction) pointerMadness {
    [self.objc playWithPointers];
}

@end
