//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2014 by Steve Nygard.
//

@import AppKit;

@class DVTSourceModelItem, DVTTextStorage;

@protocol DVTTextStorageDelegate <NSTextStorageDelegate>

@optional
@property(readonly, nonatomic) NSDictionary *sourceLanguageServiceContext;
- (void)sourceLanguageServiceAvailabilityNotification:(BOOL)arg1 message:(NSString *)arg2;
- (BOOL)textStorageShouldAllowEditing:(DVTTextStorage *)arg1;
- (void)textStorageDidUpdateSourceLandmarks:(DVTTextStorage *)arg1;
- (long long)nodeTypeForItem:(DVTSourceModelItem *)arg1 withContext:(NSDictionary *)arg2;
@end

