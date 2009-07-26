//
//  BetaViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "BetaViewController.h"
#import "Transaction.h"


@implementation BetaViewController

@synthesize managedObjectContext, resultsController, progressBar;
@synthesize addDataButton, clearDataButton;

@synthesize numberOfTransactionsAdded, run;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Beta screen";
    }
    return self;
}

-(IBAction)addData:(id)sender {
	UIActionSheet * confrmation = [[UIActionSheet alloc] initWithTitle:@"This will take a while!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Do it!" otherButtonTitles:nil];

	[confrmation showInView:self.view];
	[confrmation release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
		NSLog(@"Parsing and adding transactions");
		
		numberOfTransactionsAdded = 0;
		
		progressBar.hidden = NO;
		progressBar.progress = 0.0;
		
		addDataButton.enabled = NO;
		clearDataButton.enabled = NO;
		
		NSURL * dataLocation = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sampleTransactions" ofType:@"xml"]];
		NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:dataLocation]; 
		
		currentString = [[NSMutableString alloc] init];

		[parser setDelegate:self];

		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
	    [parser setShouldResolveExternalEntities:NO];
	
		[parser parse];
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	NSLog(@"Actionsheet cancelled");
}

-(IBAction)clearData:(id)sender {
	
}


#pragma mark
#pragma mark -
#pragma mark Add beta transaction content

+(void)increaseProgressBar:(BetaViewController*)view {
	if (view.progressBar.hidden == YES) {
		view.progressBar.hidden = NO;
		view.addDataButton.enabled = NO;
		view.clearDataButton.enabled = NO;
	}
	view.progressBar.progress += 0.01;
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
		progressBar.hidden = YES;
		addDataButton.enabled = YES;
		clearDataButton.enabled = YES;
		[[[UIApplication sharedApplication] delegate] saveAction:self];
		
	} else if ([elementName isEqualToString:@"transaction"]) {
		numberOfTransactionsAdded += 1;
		if ((numberOfTransactionsAdded % 10) == 0) {
			[NSThread detachNewThreadSelector:@selector(increaseProgressBar:) toTarget:[BetaViewController class] withObject:self];
		}
		
		
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



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[addDataButton release];
	[clearDataButton release];
	
	[managedObjectContext release];
	[resultsController release];
    [progressBar release];
	
	[super dealloc];
}


@end
