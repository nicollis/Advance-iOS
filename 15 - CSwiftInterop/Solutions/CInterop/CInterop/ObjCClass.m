#import "ObjCClass.h"
#import "CInterop-Swift.h"


@interface ObjCClass()
@end


@implementation ObjCClass


- (void)printStuffToConsole {
    NSLog(@"Stuff to console");
}


- (void)callSwift {
    SwiftClass *swift = SwiftClass.new;
    [swift callMe];
}



- (void)receiveBitFlags:(BitwiseOptions)options {
    NSMutableArray<NSString*> *names = NSMutableArray.new;

    if (options == BitwiseOptionsNone) {
        [names addObject: @"no flags"];
    }

    if (options & BitwiseOptionsSortBackwards) {
        [names addObject: @"sort backwards"];
    }

    if (options & BitwiseOptionsFeedTheCat) {
        [names addObject: @"feed the cat"];
    }

    if (options & BitwiseOptionsUseBlinkTag) {
        [names addObject: @"use blink tag"];
    }

    NSString *finalString = [names componentsJoinedByString: @", "];
    NSLog (@"got bit fields: 0x%02lx : %@", (long)options, finalString);
}

- (void)playWithBitSets {
    [self receiveBitFlags: BitwiseOptionsFeedTheCat | BitwiseOptionsSortBackwards];
    [self.swift takesOptions: BitwiseOptionsFeedTheCat | BitwiseOptionsUseBlinkTag];
}




- (void)enumNumNum {
    [self.swift processVisibleEnum: VisibleEnumIs23];
    [self.swift processVisibleEnum: 666];
    
    [self.swift processBareEnum: kThisIsFnord];
    [self.swift processBareEnum: 666];
    
    [self.swift processSuitEnum: SuitEnumClubs];
    [self.swift processSuitEnum: 666];
    
}


- (void)useStructs {
    [self.swift useStructs];
}


- (void)useBlocks {
    NSInteger integers[] = { 15, 23, 5, 42, 12, 0, 66, 41 };  // new starting here

    qsort_b(integers, sizeof(integers) / sizeof(*integers), sizeof(*integers),
            ^int(const void *l, const void *r) {
        NSInteger left = *((NSInteger *)l);
        NSInteger right = *((NSInteger *)r);
        if (left < right) return -1;
        if (left == right) return 0;
        return 1;
    });

    NSMutableString *output = NSMutableString.new;

    for (NSInteger i = 0; i < sizeof(integers) / sizeof(*integers); i++) {
        [output appendFormat: @"%ld ", (long) integers[i]];
    }

    NSLog (@"sorted integers: %@", output);
    
    [self.swift useClosures];
}


- (void)useFunctionPointers {
    [self.swift useFunctionPointers];
}


- (void)playWithPointers {
    NSInteger intValue = 42;
    [self.swift printIntPointer: &intValue];
    [self.swift printIntPointer: NULL];
    
    [self.swift writeIntoPointer: &intValue];
    [self.swift printIntPointer: &intValue];
    
    NSInteger integers[] = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    [self.swift randomAccessPointer: integers];
    
    [self.swift allocations];
    [self.swift useCString];

}

@end
