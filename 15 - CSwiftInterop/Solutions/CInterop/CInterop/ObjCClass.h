#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, BitwiseOptions) {
    BitwiseOptionsNone          = 0,
    BitwiseOptionsSortBackwards = 1 << 0,
    BitwiseOptionsFeedTheCat    = 1 << 1,
    BitwiseOptionsUseBlinkTag   = 1 << 2
};


typedef enum : NSInteger {
    kThisIsZero,
    kThisIsOne,

    kThisIsFnord = 23,
    kThisIsNot,

    kThisIsFortyTwo = 42
} BareEnum;


typedef NS_ENUM(NSInteger, SuitEnum) {
    SuitEnumHearts,
    SuitEnumClubs,
    SuitEnumGaberdine = 21,
    SuitEnumLaw = 45
};


typedef struct {
    CGRect thing1;
    CGRect thing2;
} TwoRects;


struct Forward;
typedef struct Forward *ForwardRef;


@class SwiftClass;

@interface ObjCClass : NSObject
@property (weak, nonatomic) SwiftClass *swift;

- (void)receiveBitFlags:(BitwiseOptions)options;

// Methods called by IBActions in ViewController.m
- (void)printStuffToConsole;
- (void)callSwift;
- (void)playWithBitSets;
- (void)enumNumNum;
- (void)useStructs;
- (void)useBlocks;
- (void)useFunctionPointers;
- (void)playWithPointers;

@end
