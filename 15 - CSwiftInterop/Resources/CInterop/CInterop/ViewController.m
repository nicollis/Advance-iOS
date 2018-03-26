#import "ViewController.h"
#import "ObjCClass.h"

@interface ViewController ()
@property (strong, nonatomic) ObjCClass *objc;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objc = ObjCClass.new;
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
