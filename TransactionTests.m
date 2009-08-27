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


@end
