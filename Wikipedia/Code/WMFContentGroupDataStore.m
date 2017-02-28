#import "WMFContentGroupDataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMFContentGroupDataStore ()

@property (nonatomic, strong) MWKDataStore *dataStore;

@end

@implementation WMFContentGroupDataStore

- (instancetype)initWithDataStore:(MWKDataStore *)dataStore {
    self = [super init];
    if (self) {
        self.dataStore = dataStore;
    }
    return self;
}

#pragma mark - section access

- (void)enumerateContentGroupsWithBlock:(void (^)(WMFContentGroup *_Nonnull section, BOOL *stop))block {
    if (!block) {
        return;
    }
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return;
    }
    [contentGroups enumerateObjectsUsingBlock:^(WMFContentGroup *_Nonnull section, NSUInteger idx, BOOL *_Nonnull stop) {
        block(section, stop);
    }];
}

- (NSArray<WMFContentGroup *> *)contentGroupsOfKind:(WMFContentGroupKind)kind sortedByDescriptors:(nullable NSArray *)sortDescriptors {
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contentGroupKindInteger == %@", @(kind)];
    fetchRequest.sortDescriptors = sortDescriptors;
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError || !contentGroups) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return @[];
    }
    return contentGroups;
}

- (NSArray<WMFContentGroup *> *)contentGroupsOfKind:(WMFContentGroupKind)kind sortedByKey:(NSString *)sortKey ascending:(BOOL)ascending {
    return [self contentGroupsOfKind:kind sortedByDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending]]];
}

- (NSArray<WMFContentGroup *> *)contentGroupsOfKind:(WMFContentGroupKind)kind {
    return [self contentGroupsOfKind:kind sortedByDescriptors:nil];
}

- (void)enumerateContentGroupsOfKind:(WMFContentGroupKind)kind sortedByKey:(NSString *)key ascending:(BOOL)ascending withBlock:(void (^)(WMFContentGroup *_Nonnull group, BOOL *stop))block {
    if (!block) {
        return;
    }
    NSArray<WMFContentGroup *> *contentGroups = [self contentGroupsOfKind:kind sortedByKey:key ascending:ascending];
    [contentGroups enumerateObjectsUsingBlock:^(WMFContentGroup *_Nonnull section, NSUInteger idx, BOOL *_Nonnull stop) {
        block(section, stop);
    }];
}

- (void)enumerateContentGroupsOfKind:(WMFContentGroupKind)kind withBlock:(void (^)(WMFContentGroup *_Nonnull group, BOOL *stop))block {
    if (!block) {
        return;
    }
    NSArray<WMFContentGroup *> *contentGroups = [self contentGroupsOfKind:kind];
    [contentGroups enumerateObjectsUsingBlock:^(WMFContentGroup *_Nonnull section, NSUInteger idx, BOOL *_Nonnull stop) {
        block(section, stop);
    }];
}

- (nullable WMFContentGroup *)contentGroupForURL:(NSURL *)URL {
    NSParameterAssert(URL);
    if (!URL) {
        return nil;
    }

    NSString *key = [WMFContentGroup databaseKeyForURL:URL];
    if (!key) {
        return nil;
    }

    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key == %@", key];
    fetchRequest.fetchLimit = 1;
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return nil;
    }
    return [contentGroups firstObject];
}

- (nullable WMFContentGroup *)firstGroupOfKind:(WMFContentGroupKind)kind {
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contentGroupKindInteger == %@", @(kind)];
    fetchRequest.fetchLimit = 1;
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return nil;
    }
    return [contentGroups firstObject];
}

- (nullable WMFContentGroup *)firstGroupOfKind:(WMFContentGroupKind)kind forDate:(NSDate *)date {
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contentGroupKindInteger == %@ && midnightUTCDate == %@", @(kind), date.wmf_midnightUTCDateFromLocalDate];
    fetchRequest.fetchLimit = 1;
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return nil;
    }
    return [contentGroups firstObject];
}

- (nullable WMFContentGroup *)firstGroupOfKind:(WMFContentGroupKind)kind forDate:(NSDate *)date siteURL:(NSURL *)url {
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contentGroupKindInteger == %@ && midnightUTCDate == %@ && siteURLString == %@", @(kind), date.wmf_midnightUTCDateFromLocalDate, url.absoluteString];
    fetchRequest.fetchLimit = 1;
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return nil;
    }
    return [contentGroups firstObject];
}

- (nullable NSArray<WMFContentGroup *> *)groupsOfKind:(WMFContentGroupKind)kind forDate:(NSDate *)date {
    NSFetchRequest *fetchRequest = [WMFContentGroup fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"contentGroupKindInteger == %@ && midnightUTCDate == %@", @(kind), date.wmf_midnightUTCDateFromLocalDate];
    NSError *fetchError = nil;
    NSArray *contentGroups = [self.dataStore.viewContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups: %@", fetchError);
        return nil;
    }
    return contentGroups;
}

#pragma mark - section add / remove

- (nullable WMFContentGroup *)createGroupForURL:(nullable NSURL *)URL ofKind:(WMFContentGroupKind)kind forDate:(NSDate *)date withSiteURL:(nullable NSURL *)siteURL associatedContent:(nullable NSArray<NSCoding> *)associatedContent customizationBlock:(nullable void (^)(WMFContentGroup *group))customizationBlock {
    WMFContentGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"WMFContentGroup" inManagedObjectContext:self.dataStore.viewContext];
    group.date = date;
    group.midnightUTCDate = date.wmf_midnightUTCDateFromLocalDate;
    group.contentGroupKind = kind;
    group.siteURLString = siteURL.absoluteString;
    group.content = associatedContent;

    if (customizationBlock) {
        customizationBlock(group);
    }

    if (URL) {
        group.URL = URL;
    } else {
        [group updateKey];
    }
    [group updateContentType];
    [group updateDailySortPriority];

    return group;
}

- (nullable WMFContentGroup *)createGroupOfKind:(WMFContentGroupKind)kind forDate:(NSDate *)date withSiteURL:(nullable NSURL *)siteURL associatedContent:(nullable NSArray<NSCoding> *)associatedContent customizationBlock:(nullable void (^)(WMFContentGroup *group))customizationBlock {
    return [self createGroupForURL:nil ofKind:kind forDate:date withSiteURL:siteURL associatedContent:associatedContent customizationBlock:customizationBlock];
}

- (nullable WMFContentGroup *)fetchOrCreateGroupForURL:(NSURL *)URL ofKind:(WMFContentGroupKind)kind forDate:(NSDate *)date withSiteURL:(nullable NSURL *)siteURL associatedContent:(nullable NSArray<NSCoding> *)associatedContent customizationBlock:(nullable void (^)(WMFContentGroup *group))customizationBlock {

    WMFContentGroup *group = [self contentGroupForURL:URL];
    if (group) {
        group.date = date;
        group.midnightUTCDate = date.wmf_midnightUTCDateFromLocalDate;
        group.contentGroupKind = kind;
        group.content = associatedContent;
        group.siteURLString = siteURL.absoluteString;
        if (customizationBlock) {
            customizationBlock(group);
        }
    } else {
        group = [self createGroupForURL:URL ofKind:kind forDate:date withSiteURL:siteURL associatedContent:associatedContent customizationBlock:customizationBlock];
    }

    return group;
}

- (nullable WMFContentGroup *)createGroupOfKind:(WMFContentGroupKind)kind forDate:(NSDate *)date withSiteURL:(nullable NSURL *)siteURL associatedContent:(nullable NSArray<NSCoding> *)associatedContent {
    return [self createGroupOfKind:kind forDate:date withSiteURL:siteURL associatedContent:associatedContent customizationBlock:NULL];
}

- (void)removeContentGroup:(WMFContentGroup *)group {
    NSParameterAssert(group);
    [self.dataStore.viewContext deleteObject:group];
}

- (void)removeContentGroups:(NSArray<WMFContentGroup *> *)contentGroups {
    for (WMFContentGroup *group in contentGroups) {
        [self.dataStore.viewContext deleteObject:group];
    }
}

- (BOOL)save:(NSError **)saveError {
    return [self.dataStore save:saveError];
}

- (void)removeContentGroupsWithKeys:(NSArray<NSString *> *)keys {
    NSFetchRequest *request = [WMFContentGroup fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"key IN %@", keys];
    NSError *fetchError = nil;
    NSArray<WMFContentGroup *> *groups = [self.dataStore.viewContext executeFetchRequest:request error:&fetchError];
    if (fetchError) {
        DDLogError(@"Error fetching content groups for deletion: %@", fetchError);
        return;
    }
    [self removeContentGroups:groups];
}

- (void)removeAllContentGroupsOfKind:(WMFContentGroupKind)kind {
    NSArray *groups = [self contentGroupsOfKind:kind];
    [self removeContentGroups:groups];
}

@end

NS_ASSUME_NONNULL_END
