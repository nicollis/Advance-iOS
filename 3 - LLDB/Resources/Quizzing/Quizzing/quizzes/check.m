#import <Foundation/Foundation.h>

// clang -g -Wall -framework Foundation -o check check.m

int main (int argc, const char *argv[]) {
    if (argc != 2) {
        printf ("usage: %s path-to-questions-plist\n", argv[0]);
        return -1;
    }
    NSString *path = @( argv[1] );

    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile: path
                           options: 0
                           error: &error];
    if (!data) {
        NSLog (@"error reading from path: %@", error);
        return -1;
    }

    id plist = [NSPropertyListSerialization propertyListWithData: data
                                            options: NSPropertyListImmutable
                                            format: NULL
                                            error: &error];
    if (!plist) {
        NSLog (@"error plisting: %@", error);
        return -1;
    }

    NSLog (@"yay\n\n %@", plist);

    return 0;
} // main
