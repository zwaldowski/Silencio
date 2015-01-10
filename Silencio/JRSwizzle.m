// JRSwizzle.m semver:1.0
//   Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/jrswizzle

#import "JRSwizzle.h"
#import <objc/objc-class.h>

NS_INLINE NS_FORMAT_FUNCTION(3, 4) OS_NONNULL1 void setErrorFor(__autoreleasing NSError **outErr, const char *func, NSString *format, ...) {
    if (outErr == nil) { return; }
    va_list args; va_start(args, format);
    NSString *suffix = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *description = [NSString stringWithFormat:@"%s: %@", func, suffix];
    *outErr = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{
        NSLocalizedDescriptionKey: description
    }];
    va_end(args);
}
#define SetNSError(ERROR_VAR, FORMAT,...) setErrorFor(ERROR_VAR, __func__, FORMAT, ##__VA_ARGS__)

@implementation NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(out NSError **)error_ {
	Method origMethod = class_getInstanceMethod(self, origSel_);
	if (!origMethod) {
		SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]);
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, altSel_);
	if (!altMethod) {
		SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self class]);
		return NO;
	}
	
	class_addMethod(self,
					origSel_,
					class_getMethodImplementation(self, origSel_),
					method_getTypeEncoding(origMethod));
	class_addMethod(self,
					altSel_,
					class_getMethodImplementation(self, altSel_),
					method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
	return YES;
}

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(out NSError **)error_ {
	return [object_getClass(self) jr_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

@end
