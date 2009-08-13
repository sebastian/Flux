//
//  EditTransaction.m
//  Finance
//
//  Created by Sebastian Probst Eide on 04.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "EditTransaction.h"
#import "CurrencyKeyboard.h"
#import "Transaction.h"
#import "Utilities.h"
#import "CurrencyManager.h"

@interface EditTransaction (PrivateMethods)
-(void)cancel;
-(void)save;
@end



@implementation EditTransaction

@synthesize currentTransaction;
@synthesize currencyKeyboard;

// Values for safe keeping
@synthesize transactionDescription;
@synthesize tags;
@synthesize autotags;
@synthesize kroner;
@synthesize expense;
@synthesize location;
@synthesize currency;
@synthesize date;
@synthesize yearMonth;
@synthesize day;


#pragma mark
#pragma mark -
#pragma mark Setup, init and teardown
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self 
																				   action:@selector(cancel)];

	UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																				   target:self 
																				   action:@selector(save)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = saveButton;
	[cancelButton release];
	[saveButton release];
	
	self.view.backgroundColor = [UIColor clearColor];
	
	scrollview.contentSize = CGSizeMake(editView.frame.size.width, editView.frame.size.height);
	[scrollview addSubview:editView];
	
	// Add currency keyboard
	currencyKeyboardShowing = NO;
	self.currencyKeyboard = [[CurrencyKeyboard alloc] initWithNibName:@"CurrencyKeyboard" bundle:[NSBundle mainBundle]];
	self.currencyKeyboard.delegate = self;
	[self.currencyKeyboard hideKeyboard];
	
	
	// Set up the date picker
	[self.view addSubview:datePickerView];
	[self.view bringSubviewToFront:datePickerView];
	
	// Set the current locale
	NSLocale * currentLocale = [NSLocale currentLocale]; 
	datePicker.locale = currentLocale;
	
	// Set date picker to current date
	if (currentTransaction.date) {
		datePicker.date = currentTransaction.date;
	}
	
	// Hide it
	CGRect datePickerViewFrame = datePickerView.frame;
	datePickerViewFrame.origin.y = self.view.frame.size.height;
	datePickerView.frame = datePickerViewFrame;
	datePickerViewShowing = NO;
	
	// Things that only have to be setup once
	
	// Expense control
	expenseIncomeControl.tintColor = [UIColor grayColor];
	[expenseIncomeControl setTitle:NSLocalizedString(@"Expense",nil) forSegmentAtIndex:0];
	[expenseIncomeControl setTitle:NSLocalizedString(@"Income",nil) forSegmentAtIndex:1];
	if ([self.currentTransaction.expense boolValue]) {
		[expenseIncomeControl setSelectedSegmentIndex:0];
	} else {
		[expenseIncomeControl setSelectedSegmentIndex:1];
	}
		
	// Label texts...
	dateLabel.text = NSLocalizedString(@"Date:", nil);
	locationLabel.text = NSLocalizedString(@"Location:",nil);
	locationDataLabel.text = NSLocalizedString(@"Getting location...",nil);
	[locationClearButton setTitle:NSLocalizedString(@"Clear",nil) forSegmentAtIndex:0];
	locationClearButton.tintColor = [UIColor grayColor];
	tagsLabel.text = NSLocalizedString(@"Tags:", nil);
	descriptionLabel.text = NSLocalizedString(@"Description:",nil);
	descriptionView.font = tagsField.font;
	
	// Geo code location
	if (currentTransaction.location != nil) {
		[[Utilities toolbox] reverseGeoCode:currentTransaction.location.coordinate forDelegate:self];
	}
	
	// Setup the contents of the dynamic fields
	[self setupControls];
		
}

- (void) setupControls {
	// Setup controls
	amountLabel.text = NSLocalizedString(@"Amount:", nil);
	[amountButton setTitle:[self.currentTransaction amountInLocalCurrency] forState:UIControlStateNormal];
	if ([self.currentTransaction.currency isEqualToString:[[CurrencyManager sharedManager] baseCurrency]]) {
		baseCurrencyAmountLabel.text = @"";
	} else {
		baseCurrencyAmountLabel.text = [NSString stringWithFormat:@"(%@)", [self.currentTransaction amountInBaseCurrency]];
	}
	
	[dateButton setTitle:[self.currentTransaction longFormattedDate] forState:UIControlStateNormal];
		
	// Geo code location
	if (currentTransaction.location == nil) {
		locationDataLabel.text = NSLocalizedString(@"No location data available", nil);
		CGSize size = [[Utilities toolbox] sizeOfTextOfLabel:locationDataLabel];
		CGRect frame = locationDataLabel.frame;
		frame.size.height = size.height * 2;
		locationDataLabel.frame = frame;
	}
	
	tagsField.text = self.currentTransaction.tags;
	
	descriptionView.text = self.currentTransaction.transactionDescription;
	
}

- (void)didReceiveMemoryWarning {
	NSLog(@"didReceiveMemoryWarning: %@", self);
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
- (void)dealloc {
	[currencyKeyboard release];
	[currentTransaction release];
	
	// remove safe keeping values
	self.transactionDescription = nil;
	self.tags = nil;
	self.autotags = nil;
	self.kroner = nil;
	self.expense = nil;
	self.location = nil;
	self.currency = nil;
	self.date = nil;
	self.yearMonth = nil;
	self.day = nil;
	
    [super dealloc];
}


#pragma mark
#pragma mark -
#pragma mark CurrencyKeyboardDelegate methods
- (void)numericButtonPressed:(NSInteger)key {
	[self.currentTransaction addNumber:key];
	[self keyboardCheck];
}
- (void)deleteButtonPressed {
	[self.currentTransaction eraseOneNum]; 
	[self keyboardCheck];
}
- (void)doubleZeroButtonPressed {
	[self.currentTransaction addNumber:0];
	[self.currentTransaction addNumber:0];
	[self keyboardCheck];
}
- (CGFloat)viewHeight {
	return self.view.frame.size.height;
}
- (void) keyboardCheck {

	// Show delete button if there is a value
	if ([currentTransaction needsDeleteButton]) {
		[currencyKeyboard enableClearButton];
	} else {
		[currencyKeyboard disableClearButton];
	}
	
	// Check if it can be added to?
	if ([currentTransaction canBeAddedTo] == YES) {
		[currencyKeyboard enableNumericButtons];
	} else {
		[currencyKeyboard disableNumericButtons];
	}
	
	[self setupControls];
}

#pragma mark
#pragma mark -
#pragma mark Assorted...
- (IBAction)clearLocationAction {
	NSLog(@"Clearing location data");
	self.currentTransaction.location = nil;
	[self setupControls];
}
- (IBAction)amountButtonAction {
	
	if (currencyKeyboardShowing) {
		[self.currencyKeyboard hideKeyboardWithAnimation:YES];
		[amountButton setBackgroundImage:nil forState:UIControlStateNormal];
		
		// Now it shouldn't be showing anymore ... shortly anyway
		currencyKeyboardShowing = NO;
		
		[self adjustViewSizeWith:0 andScrollFor:nil];
		
	} else {
		[amountButton setBackgroundImage:[UIImage imageNamed:@"EditTextFieldsActive.png"] forState:UIControlStateNormal];
		[self.currencyKeyboard showKeyboardWithAnimation:YES];
		
		// It is going to be showing, yeho
		currencyKeyboardShowing = YES;
		
		[self adjustViewSizeWith:[self.currencyKeyboard keyboardHeight] andScrollFor:nil];
	}
}
- (IBAction)dateButtonAction {
	
	CGRect frame = datePickerView.frame;
	
	if (datePickerViewShowing) {
		
		// Move it out of the way
		frame.origin.y = 480;
		
		// No it is not showing anymore...
		datePickerViewShowing = NO;
		
		[dateButton setBackgroundImage:nil forState:UIControlStateNormal];
		[self adjustViewSizeWith:0 andScrollFor:nil];
		
	} else {
		
		frame.origin.y = self.view.frame.size.height - frame.size.height;
		
		// No it should be showing :)
		datePickerViewShowing = YES;
		
		[dateButton setBackgroundImage:[UIImage imageNamed:@"EditTextFieldsActive.png"] forState:UIControlStateNormal];

		[self adjustViewSizeWith:frame.size.height andScrollFor:dateButton];
	}

	
	// Perform animations
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
    
	datePickerView.frame = frame;	
    
    [UIView commitAnimations];
	
	[datePicker becomeFirstResponder];
	[datePickerView bringSubviewToFront:datePicker];
	[self.view bringSubviewToFront:datePickerView];
	
}
- (IBAction)dateChangedAction {
	NSLog(@"Date value changed!");
	[self.currentTransaction setDate:datePicker.date];
	[dateButton setTitle:[self.currentTransaction longFormattedDate] forState:UIControlStateNormal];
}
- (IBAction)expenseIncomeToggleAction {
	if (expenseIncomeControl.selectedSegmentIndex == 0) {
		self.currentTransaction.expense = [NSNumber numberWithBool:YES];
	} else {
		self.currentTransaction.expense = [NSNumber numberWithBool:NO];
	}
	[self setupControls];
}
- (IBAction)didStartEditingField {
	// FIXME: Hardcoded keyboard size!
	[self adjustViewSizeWith:(216 - 50) andScrollFor:tagsField];
}
- (void)adjustViewSizeWith:(NSInteger)fromNormal andScrollFor:(UIView*)view {
	/* 
	 This is needed (sort of a hack) to change the size of the view
	 when showing and hiding keyboards
	 */
	if (viewFrameCache.size.height == 0) {
		viewFrameCache = scrollview.frame;
	}
	
	// Calculate new frame
	CGRect viewFrame = viewFrameCache;
	viewFrame.size.height = viewFrameCache.size.height - fromNormal;

	// Perform animations
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[Utilities toolbox] keyboardAnimationDuration]];
	scrollview.frame = viewFrame;    
    [UIView commitAnimations];
	
	// If we should scroll, then we scroll
	if (view != nil) {
		// Scroll the date view into view, and add some padding at the bottom
		CGRect frameToScrollTo = view.frame;
		frameToScrollTo.origin.y = frameToScrollTo.origin.y + 20;
		[scrollview scrollRectToVisible:frameToScrollTo animated:YES];		
	}
}

- (void)save {
		
	// Update the fields that can be changed directly
	currentTransaction.transactionDescription = descriptionView.text;
	currentTransaction.tags = tagsField.text;
	
	[[Utilities toolbox] save:self.currentTransaction.managedObjectContext];
	[self.navigationController popViewControllerAnimated:YES];	
	
}
- (void)cancel {
	// Reset the changes done to the transaction
	currentTransaction.location = self.location;
	currentTransaction.transactionDescription = self.transactionDescription;
	currentTransaction.tags = self.tags;
	currentTransaction.kroner = self.kroner;
	currentTransaction.expense = self.expense;
	currentTransaction.currency = self.currency;
	currentTransaction.date = self.date;
	currentTransaction.yearMonth = self.yearMonth;
	currentTransaction.day = self.day;
	currentTransaction.autotags = self.autotags;
		
	// Remove view
	[self.navigationController popViewControllerAnimated:YES];	
}
- (void)setCurrentTransaction:(Transaction*)trs {
	[trs retain];
	[currentTransaction release];
	currentTransaction = trs;
	
	// Setup safe keeping values
	self.transactionDescription = trs.transactionDescription;
	self.tags = trs.tags;
	self.autotags = trs.autotags;
	self.kroner = trs.kroner;
	self.expense = trs.expense;
	self.location = trs.location;
	self.currency = trs.currency;
	self.date = trs.date;
	self.yearMonth = trs.yearMonth;
	self.day = trs.day;
}

#pragma mark
#pragma mark -
#pragma mark UITextViewDelegate and UITextFieldDelegate
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	NSLog(@"Asked if could stop editing");
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self adjustViewSizeWith:0 andScrollFor:nil];
	[tagsField resignFirstResponder];
	return YES;
}

#pragma mark
#pragma mark -
#pragma mark CoreLocation - MKReverseGeocoder
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {

	NSInteger numberOfLines = 0;
	
	NSString * locationText = @"";
	if (placemark.thoroughfare != nil) {
		locationText = [locationText stringByAppendingFormat:@"%@", placemark.thoroughfare];
		numberOfLines++;
	}
	if (placemark.postalCode != nil) {
		locationText = [locationText stringByAppendingFormat:@"\n%@", placemark.postalCode];
		numberOfLines++;
	}
	if (placemark.locality != nil) {
		locationText = [locationText stringByAppendingFormat:@" %@", placemark.locality];
	}
	if (placemark.country != nil) {
		locationText = [locationText stringByAppendingFormat:@"\n%@", placemark.country];
		numberOfLines++;
	}
	if (placemark.subLocality != nil) {
		locationText = [[NSString stringWithFormat:@"%@", placemark.subLocality] stringByAppendingString:locationText];
		numberOfLines++;
	}
	
	CGSize sizeOfText = [locationText sizeWithFont:locationDataLabel.font];
	CGRect frame = locationDataLabel.frame;
	frame.size.height = sizeOfText.height * numberOfLines;
	locationDataLabel.frame = frame;
	locationDataLabel.text = locationText;

}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	NSString * errorText = NSLocalizedString(@"Location not found",nil);
	CGSize sizeOfText = [errorText sizeWithFont:locationDataLabel.font];

	// This is an asynchronous call, so it might return later...
	if (locationDataLabel != nil) {
		CGRect frame = locationDataLabel.frame;
		frame.size.height = sizeOfText.height;
		locationDataLabel.frame = frame;
		locationDataLabel.text = errorText;		
	}
}


@end
