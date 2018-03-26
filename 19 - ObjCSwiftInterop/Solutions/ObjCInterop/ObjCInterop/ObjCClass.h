#import <UIKit/UIKit.h>

@class SwiftClass;

@interface ObjCClass : NSObject
@property (weak, nonatomic) SwiftClass *swift;

- (void)setDate:(NSDate *)date;
- (void)setData:(NSData *)data;

- (void)changeButtonTitle:(UIButton *)button;
- (void)addCallbackToButton:(UIButton *)button;

- (BOOL)messWithFileSystem:(NSString *)source  destination:(NSString *)toPath
         error:(NSError **)error;
- (void)useSwiftErrorFunc;

@end
