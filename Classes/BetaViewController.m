//
//  BetaViewController.m
//  Finance
//
//  Created by Sebastian Probst Eide on 26.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "BetaViewController.h"
#import "Transaction.h"
#import "Utilities.h"
#import "CacheMasterSingleton.h"

@implementation BetaViewController

@synthesize managedObjectContext, resultsController, progressBar, progressView;
@synthesize addDataButton, clearDataButton;

@synthesize numberOfTransactionsAdded, run;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = @"Beta screen";
		self.tabBarItem.image = [UIImage imageNamed:@"Settings.png"];
    }
    return self;
}
- (void)dealloc {
	[addDataButton release];
	[clearDataButton release];
	
	[managedObjectContext release];
	[resultsController release];
    [progressBar release];
	[progressView release];
	
	[super dealloc];
}
- (void)viewDidUnload {
	// Save the context to make sure last minute changes get saved too
	[[Utilities toolbox] save:managedObjectContext];
}
- (void)viewDidLoad {
	
	NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"betascreen" ofType:@"html"];
	NSURL * url = [NSURL fileURLWithPath:htmlFile];
	NSURLRequest * request = [NSURLRequest requestWithURL:url];
	[webview loadRequest:request];
	
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"ERROR: %@", error);
}

-(IBAction)addData:(id)sender {
	UIActionSheet * confrmation = [[UIActionSheet alloc] initWithTitle:@"This will take about 10 minutes! Afterwards you should restart your device because otherwise you will get low memory warnings and everything will crash... sorry about that!" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Do it!" otherButtonTitles:nil];

	[confrmation showInView:self.view];
	[confrmation release];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"Parsing and adding transactions");
		
	NSURL * dataLocation = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sampleTransactions" ofType:@"xml"]];
	NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL:dataLocation]; 
		
	currentString = [[NSMutableString alloc] init];

	[parser setDelegate:self];

	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
	
	progressView.hidden = YES;
}
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	NSLog(@"Actionsheet cancelled");
}

-(IBAction)clearData:(id)sender {
	
	[[Utilities toolbox] setReloadingTableNotAllowed];
	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSError *error;
	
	// Get all the transactions
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
	
	[items addObjectsFromArray:[managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];

	// Getting the tags -> which in turn will delete the dates as well
	fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
	
	[items addObjectsFromArray:[managedObjectContext executeFetchRequest:fetchRequest error:&error]];
    [fetchRequest release];
	
	
	numberOfTransactionsAdded = 0;
	int numTotal = [items count];
	int stepSize = numTotal / 100;
	
	stepSize = stepSize == 0 ? 1 : stepSize;
	
    for (NSManagedObject *managedObject in items) {
		numberOfTransactionsAdded += 1;
        [managedObjectContext deleteObject:managedObject];
		if ((numberOfTransactionsAdded % stepSize) == 0) {
			[NSThread detachNewThreadSelector:@selector(increaseProgressBar:) toTarget:[BetaViewController class] withObject:self];
		}
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting Transaction - error:%@",error);
    }
	
	/* This shouldn't really be needed... and probably there is a bug somewhere, but heck... */
	[[Utilities toolbox] setReloadingTableAllowed];
	[[CacheMasterSingleton sharedCacheMaster] clearCache];
	
	progressView.hidden = YES;
	addDataButton.enabled = YES;
	clearDataButton.enabled = YES;
}

#pragma mark
#pragma mark -
#pragma mark Add beta transaction content

+(void)increaseProgressBar:(BetaViewController*)view {
	if (view.progressView.hidden == YES) {
		view.progressBar.progress = 0.0;
		view.progressView.hidden = NO;
		view.addDataButton.enabled = NO;
		view.clearDataButton.enabled = NO;
	}
	view.progressBar.progress += 0.01;
}

-(void)save {
	NSError *error;
	if (![[self managedObjectContext] save:&error]) {
		// Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

#pragma mark NSXMLParser methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	// Stop the table view from reloading data
	

	if ([elementName isEqualToString:@"transaction"]) {
		betaTransaction = (Transaction*)[NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:self.managedObjectContext];
		tempLocation = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    } else if ([elementName isEqualToString:@"transactions"]) {
		NSLog(@"Stopping reloading of table");
		[[Utilities toolbox] setReloadingTableNotAllowed];
    } else if ([elementName isEqualToString:@"transactionDescription"] || [elementName isEqualToString:@"autotags"] || [elementName isEqualToString:@"kroner"] || [elementName isEqualToString:@"ore"] || [elementName isEqualToString:@"expense"] || [elementName isEqualToString:@"lat"] || [elementName isEqualToString:@"lng"] || [elementName isEqualToString:@"yearMonth"] || [elementName isEqualToString:@"day"] || [elementName isEqualToString:@"date"] || [elementName isEqualToString:@"tags"]) {
		[currentString setString:@""];
		storingCharacters = YES;
	} else {
		// Do nothing
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"transactions"]) {
		[self save];
		// Have to save a second time to get the new tags saved
		[self save];
		progressView.hidden = YES;
		addDataButton.enabled = YES;
		clearDataButton.enabled = YES;
		
		NSLog(@"Enabling reloading of table");
		[[Utilities toolbox] setReloadingTableAllowed];
		// Force a global reload
		[[NSNotificationCenter defaultCenter] postNotificationName:@"GlobalTableViewReloadData" object:self];
		
		
	} else if ([elementName isEqualToString:@"transaction"]) {
		betaTransaction.location = tempLocation;
		[tempLocation release];
		numberOfTransactionsAdded += 1;
		if ((numberOfTransactionsAdded % 5) == 0) {
			[NSThread detachNewThreadSelector:@selector(increaseProgressBar:) toTarget:[BetaViewController class] withObject:self];
		}
		
		
    } else if ([elementName isEqualToString:@"transactionDescription"]) {
		betaTransaction.transactionDescription = [currentString copy];
	} else if ([elementName isEqualToString:@"kroner"]) {
		betaTransaction.kroner = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"expense"]) {
		betaTransaction.expense = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"lat"]) {
		double tempLongitude = tempLocation.coordinate.longitude;
		[tempLocation release];
		tempLocation = [[CLLocation alloc] initWithLatitude:[currentString doubleValue] longitude:tempLongitude];
	} else if ([elementName isEqualToString:@"lng"]) {
		double tempLatitude = tempLocation.coordinate.latitude;
		[tempLocation release];
		tempLocation = [[CLLocation alloc] initWithLatitude:tempLatitude longitude:[currentString doubleValue]];
	} else if ([elementName isEqualToString:@"yearMonth"]) {
		betaTransaction.yearMonth = [currentString copy];
	} else if ([elementName isEqualToString:@"day"]) {
		betaTransaction.day = [NSNumber numberWithInt:[currentString integerValue]];
	} else if ([elementName isEqualToString:@"date"]) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
		betaTransaction.date = [inputFormatter dateFromString:currentString];
		// So many records are saved without a date... we have to fix that...
		if (betaTransaction.date == nil) {betaTransaction.date = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];}
		
	} else if ([elementName isEqualToString:@"tags"]) {
		betaTransaction.tags = [currentString copy];
	} else if ([elementName isEqualToString:@"autotags"]) {
		betaTransaction.autotags = [currentString copy];
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
