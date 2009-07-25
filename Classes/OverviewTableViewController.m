//
//  ExpensesTableViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 12.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OverviewTableViewController.h"
#import "Transaction.h"
#import "DetailTableViewController.h"

@implementation OverviewTableViewController

@synthesize overviewTableCell;

- (id)initWithStyle:(UITableViewStyle)style andContext:(NSManagedObjectContext*)context {
	self = [super initWithStyle:style andContext:context];
	if (self != nil) {
	}
	return self;
}

-(void)viewDidLoad {
	self.title = NSLocalizedString(@"Overview", @"Overview table transaction view");
	
	UIBarButtonItem * addBetaContentButton = 
		[[UIBarButtonItem alloc] initWithTitle:@"Add beta content" 
										 style:UIBarButtonItemStyleBordered 
										target:self 
										action:@selector(addBetaContent)];

	
	addBetaContentButton.enabled = YES;
	self.navigationItem.leftBarButtonItem = addBetaContentButton;
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
		
	// Load the expenses
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" 
											  inManagedObjectContext:self.managedObjectContext]; 
	[request setEntity:entity];
	
	NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
									initWithKey:@"date" ascending:NO];
	
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortByDate, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	[sortDescriptors release]; 
	[sortByDate release]; 
	
	NSError *error; 
	NSFetchedResultsController * localRC = [[NSFetchedResultsController alloc] 
											initWithFetchRequest:request 
											managedObjectContext:self.managedObjectContext 
											sectionNameKeyPath:@"yearMonth" cacheName:@"transactionCache"]; 
	localRC.delegate=self;
	
	self.resultsController = localRC;
	[localRC release];
	
	if (![resultsController performFetch:&error]) { 
		NSLog(@"Error when performing fetch in OverviewTableViewController");
		NSLog(@"ERROR: %@", [error localizedDescription]);
	} 	
	[request release];
	
	[self.tableView reloadData];

	if ([[resultsController fetchedObjects] count] > 20) {
		self.navigationItem.leftBarButtonItem.enabled = NO;
	}
	

}

#pragma mark Table view methods

/*
 We always return that there is 1 section.
 In the table there will be displayed one row per each section
 in the resultsController...
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [[resultsController sections] count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	// Get a cell:
	static NSString *CellIdentifier = @"OverviewCell";
	OverviewTableCell *cell = (OverviewTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OverviewTableCell" owner:self options:nil]; 
		cell = self.overviewTableCell;
	}
	
	// Get info to put into cell:
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * transactionsInSection = [currenctSection objects];

	Transaction * aTransaction = (Transaction*)[transactionsInSection objectAtIndex:0];
	
	// Sum the amount
	int iKroner = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.kroner"] intValue];
	int iOre = [(NSNumber*)[transactionsInSection valueForKeyPath:@"@sum.ore"] intValue];

	double amount = iKroner + ((double)iOre/100);
	
	NSDate * dateFromObject = aTransaction.date;
	NSNumber * calculatedAmount = [NSNumber numberWithDouble:amount];
	
	[cell updateCellWithDate:dateFromObject andAmount:[aTransaction numberToMoney:calculatedAmount]];
	
    return cell;
		
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    DetailTableViewController * detailController = 
	[[[DetailTableViewController alloc] initWithStyle:UITableViewStylePlain 
										   andContext:self.managedObjectContext] autorelease];

	
	// Must be able to cache this somehow... Dictionary? To save this extra traversal...
	NSArray * sections = [resultsController sections];
	id <NSFetchedResultsSectionInfo> currenctSection = [sections objectAtIndex:indexPath.row];
	NSArray * transactionsInSection = [currenctSection objects];	
	Transaction * aTransaction = (Transaction*)[transactionsInSection objectAtIndex:0];
	
	detailController.yearMonthToDisplay = aTransaction.yearMonth;
	
	[self.navigationController pushViewController:detailController animated:YES];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (void)dealloc {
	[overviewTableCell release];
	[super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark Add beta transaction content

-(void)addBetaContent {
	NSLog(@"Parsing and adding transactions");
	
	self.navigationItem.leftBarButtonItem.enabled = NO;
	
	NSURL * dataLocation = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sampleTransactions" ofType:@"xml"]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:dataLocation]; 
	
	currentString = [[NSMutableString alloc] init];
	
	[parser setDelegate:self];
	
	[parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
		
	[parser parse];
}


#pragma mark NSXMLParser methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"transaction"]) {
		betaTransaction = (Transaction*)[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
    } else if ([elementName isEqualToString:@"transactionDescription"] || [elementName isEqualToString:@"kroner"] || [elementName isEqualToString:@"ore"] || [elementName isEqualToString:@"expense"] || [elementName isEqualToString:@"lat"] || [elementName isEqualToString:@"lng"] || [elementName isEqualToString:@"yearMonth"] || [elementName isEqualToString:@"day"] || [elementName isEqualToString:@"date"] || [elementName isEqualToString:@"tags"]) {
		[currentString setString:@""];
		storingCharacters = YES;
	} else {
		// Do nothing
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"transactions"]) {
		[self.tableView reloadData];
	} else if ([elementName isEqualToString:@"transaction"]) {
		[[[UIApplication sharedApplication] delegate] saveAction:self];
		
    } else if ([elementName isEqualToString:@"transactionDescription"]) {
		betaTransaction.transactionDescription = [currentString copy];
	} else if ([elementName isEqualToString:@"kroner"]) {
		betaTransaction.kroner = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"ore"]) {
		betaTransaction.ore = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"expense"]) {
		betaTransaction.expense = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"lat"]) {
		betaTransaction.lat = [NSNumber numberWithFloat:[currentString floatValue]];
	} else if ([elementName isEqualToString:@"lng"]) {
		betaTransaction.lng = [NSNumber numberWithFloat:[currentString floatValue]];
	} else if ([elementName isEqualToString:@"yearMonth"]) {
		NSLog(@"Adding year month: %@", currentString);
		betaTransaction.yearMonth = [currentString copy];
	} else if ([elementName isEqualToString:@"day"]) {
		betaTransaction.day = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"date"]) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
		betaTransaction.date = [inputFormatter dateFromString:currentString];
	} else if ([elementName isEqualToString:@"tags"]) {
		betaTransaction.tags = [currentString copy];
	}
	[currentString setString:@""];
	storingCharacters = NO;
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (storingCharacters) {
		[currentString appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Error when parsing: %@", parseError);
}


@end

