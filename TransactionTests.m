#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "TestUtils.h"
#import "Transaction.h"

@interface TransactionTests : SenTestCase {
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;	
	NSPersistentStoreCoordinator *coodinator;
	
	Transaction * trs;
}
@end


@implementation TransactionTests

- (void)setUp {
	managedObjectContext = [TestUtils managedObjectContext];
	
	trs = [NSEntityDescription
		   insertNewObjectForEntityForName:@"Transaction"
		   inManagedObjectContext:managedObjectContext];
	
	STAssertNotNil(trs, @"Should have a transaction");
}
- (void) tearDown {
	[TestUtils clearData];
	[trs release];
}


#pragma mark
#pragma mark -
#pragma mark setDate
- (void) testDateSetter {
	NSDate * date =[NSDate dateWithTimeIntervalSince1970:0]; // 1 January 1970
	trs.date = date;

	STAssertEquals(1, [trs.day intValue], @"Should set the correct day");
	STAssertTrue([@"197001" isEqualToString:trs.yearMonth], @"Should set year month to a valid string");
	
}

#pragma mark
#pragma mark -
#pragma mark Tags
- (void) testDescriptionAndTags {
	STAssertTrue([@"" isEqualToString:[trs descriptionAndTags]],@"Shouldn't have any tags by default");
	
	trs.transactionDescription = @"Test";
	STAssertTrue([@"Test" isEqualToString:[trs descriptionAndTags]],@"");
	
	trs.tags = @"en tag";
	STAssertTrue([@"Test (en tag)" isEqualToString:[trs descriptionAndTags]],@"");
	
	trs.transactionDescription = @"";
	STAssertTrue([@"(en tag)" isEqualToString:[trs descriptionAndTags]],@"");
	
}

// Test tags accessors
- (void) testGetTagsArray {
	
	STAssertTrue([trs respondsToSelector:@selector(tagsArray)], @"Should have a tags array method");
	
	trs.tags = @"";
	STAssertEqualObjects(trs.tagsArray, [[[NSArray alloc] init] autorelease], @"Should be empty array for no tags");

	trs.tags = @" hehe ";
	STAssertTrue([trs.tagsArray count] == 1, @"Should have 1 element");
	
	trs.tags = @" hehe haha ";
	STAssertTrue([trs.tagsArray count] == 2, @"Should have 1 element");
}
- (void) testSetTagsArray {
	
	STAssertTrue([trs respondsToSelector:@selector(setTagsArray:)], @"Should have a method to set the tags as an array");
	NSMutableArray * tags = [[NSMutableArray alloc] init];
	
	[tags addObject:@"test"];
	trs.tagsArray = tags;
	STAssertTrue([trs.tags isEqualToString:@" test "], @"Should be able to set tags from an array");
	
	[tags addObject:@"haha"];
	[tags addObject:@"hehe"];
	trs.tagsArray = tags;
	STAssertTrue([trs.tags isEqualToString:@" test haha hehe "], @"Should be able to set tags from an array");
	
	// Remove duplicates
	[tags addObject:@"hehe"];
	trs.tagsArray = tags;
	STAssertTrue([trs.tags isEqualToString:@" test haha hehe "], @"Should be able to set tags from an array");

}


#pragma mark
#pragma mark -
#pragma mark Rounding error when typing in numbers
- (void) testSetKroner {
	[trs addNumber:5];
	[trs addNumber:8];
	trs.currency = @"USD";
	
	NSString * amount = [trs absAmountInLocalCurrency];
	STAssertTrue([amount isEqualToString:@"$0.58"] || [amount isEqualToString:@"$0,58"], @"Should display the amount right");
	
	[trs eraseOneNum]; [trs eraseOneNum];
	[trs addNumber:2];[trs addNumber:5];[trs addNumber:5];
	amount = [trs absAmountInLocalCurrency];
	STAssertTrue([amount isEqualToString:@"$2.55"] || [amount isEqualToString:@"$2,55"], @"Should display the amount right");
	
}


@end
