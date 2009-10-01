#import "AmountEditor.h"
#import "KleioCustomStyles.h"
#import "Transaction.h"

@implementation ExpenseToggle

@synthesize delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Public

- (void) reset {
	[eiCtrl setSelectedSegmentIndex:0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private
- (void) setup {
	
	eiCtrl = [[[UISegmentedControl alloc] init] autorelease];
	[eiCtrl insertSegmentWithTitle:NSLocalizedString(@"Expense", nil) atIndex:0 animated:NO];
	[eiCtrl insertSegmentWithTitle:NSLocalizedString(@"Income", nil) atIndex:1 animated:NO];
	[eiCtrl setSegmentedControlStyle:UISegmentedControlStylePlain];
	[eiCtrl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
	int padding = 10;
	eiCtrl.frame = CGRectMake(padding, padding, self.width - 2*padding, self.height - 2*padding);
	
	[self reset];
	
	[self addSubview:eiCtrl];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Callbacks

- (void) valueChanged:(UISegmentedControl*)sender {
	
	if ([self.delegate respondsToSelector:@selector(expenseToggleChangedToValue:)]) {
		TTLOG(@"Informing delegate about change of value for expense/income");
		if ([sender selectedSegmentIndex] == 0) {
			[self.delegate expenseToggleChangedToValue:KleioExpenseIncomeToggleSelectedExpense];
		} else {
			[self.delegate expenseToggleChangedToValue:KleioExpenseIncomeToggleSelectedIncome];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) init {
	if (self = [super init]) {
		[TTStyleSheet setGlobalStyleSheet:[[[KleioCustomStyles alloc] init] autorelease]];
		
		self.frame = CGRectMake(0, 0, 320, 57);
		self.style = TTSTYLEVAR(expenseInputField);
		
		[self setup];
	}
	return self;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AmountLabel

@synthesize amount = _amount, delegate = _delegate;
- (void) setAmount:(NSString *)theAmount {
	[theAmount retain];
	[_amount release];
	_amount = theAmount;
	[self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

/*
 If it receives a touch, then we should display the 
 dialog where currencies can be changed. The amount label delegate
 handles the actual work when the value is returned...
 */
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[super touchesBegan:touches withEvent:event];
	
	[self.delegate presentCurrencyTable];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.style = TTSTYLEVAR(amountFieldStyle);
		self.multipleTouchEnabled = YES;
	}
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Puclib
- (void)drawContent:(CGRect)rect {
	
	int padding = 20;
	CGRect frame = self.frame;
	frame.size.width = frame.size.width - 2 * padding;
	frame.size.height = frame.size.height - 2 * padding;
	frame.origin.x = padding;
	frame.origin.y = padding;
	
	UIFont * font = [UIFont systemFontOfSize:50];
	
	CGPoint textPoint = CGPointMake(padding, padding);
	CGSize textSize = [_amount sizeWithFont:font];
	
	if (textSize.width < frame.size.width) {
		textPoint.x = padding + frame.size.width - textSize.width;
	} else {
		textSize.width = frame.size.width;
	}
	
	[[UIColor whiteColor] set];
	
	[_amount drawAtPoint:textPoint 
							forWidth:textSize.width
							withFont:font
					 minFontSize:12.f 
				actualFontSize:nil
				 lineBreakMode:UILineBreakModeHeadTruncation 
		baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
	
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AmountEditor 
@synthesize currentTransaction = _currentTransaction, delegate = _delegate;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Private

- (void) updateExpenseDisplay {
	
	// Show delete button if there is a value
	if ([_currentTransaction needsDeleteButton]) {
		[_keyboard enableClearButton];
	} else {
		[_keyboard disableClearButton];
	}
	
	// Check if it can be added to?
	if ([_currentTransaction canBeAddedTo] == YES) {
		[_keyboard enableNumericButtons];
	} else {
		[_keyboard disableNumericButtons];
	}
	
	NSString * text = [_currentTransaction absAmountInLocalCurrency];
	[_amount setAmount:text];
}

- (void) layout {
	
	TTFlowLayout * flow = [[TTFlowLayout alloc] init];
	[flow layoutSubviews:self.view.subviews forView:self.view];
	[flow release];
	
}

- (void) createAndSetupTransaction {
		
	[self updateExpenseDisplay];
	[_expenseIncomeControl reset];
	
}

-(void) currencySelected:(NSString*)currencyCode {
	_currentTransaction.currency = currencyCode;
	[self updateExpenseDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Custom getters/setters

- (void) setCurrentTransaction:(Transaction *)trs {
	[trs retain];
	[_currentTransaction release];
	_currentTransaction = trs;
	
	[self updateExpenseDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	NSObject

- (void) dealloc {
	TT_RELEASE_SAFELY(_currentTransaction);
	TT_RELEASE_SAFELY(_amount);
	TT_RELEASE_SAFELY(_expenseIncomeControl);
	TT_RELEASE_SAFELY(_keyboard);
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	UIViewController

- (void) loadView {
	[super loadView];

	self.view.frame = TTToolbarNavigationFrame();
	
	_amount = [[AmountLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
	_amount.delegate = self;
	
	_expenseIncomeControl = [[ExpenseToggle alloc] init];
	_expenseIncomeControl.delegate = self;
	
	[self.view addSubview:_amount];
	[self.view addSubview:_expenseIncomeControl];

	_keyboard = [[CurrencyKeyboard alloc] init];
	_keyboard.delegate = self;
	[_keyboard showKeyboardWithAnimation:NO];
		
	[self layout];
	
	[self updateExpenseDisplay];
	
	/*
	 This hack is needed to make the screen big enough for 
	 the whole keyboard
	 */
	self.view.height += 100;
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Change of state - ExpenseToggleDelegate method(s)

- (void)expenseToggleChangedToValue:(KleioExpenseIncomeToggle)value {
	switch (value) {
		case KleioExpenseIncomeToggleSelectedIncome:
			[_currentTransaction setExpense:[NSNumber numberWithBool:NO]];
			break;
		case KleioExpenseIncomeToggleSelectedExpense:
			[_currentTransaction setExpense:[NSNumber numberWithBool:YES]];
			break;
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	AmountLabelDelegate

-(void)presentCurrencyTable {
	/* 
	 Called when the user clicks on the amount
	 Let the user select another input currency
	 */ 
	
	CurrencySelectionDialog *currencySelectionDialog = [[CurrencySelectionDialog new] autorelease];
	// So we can report back the currency change
	currencySelectionDialog.delegate = self;
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:currencySelectionDialog];
	navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[_delegate presentModalViewController:navController animated:YES];
	[navController release];
	
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	CurrencyKeyboardDelegate
- (void) numericButtonPressed:(NSInteger)key {
	[_currentTransaction addNumber:key];
	[self updateExpenseDisplay];
}
- (void) deleteButtonPressed {
	[_currentTransaction eraseOneNum];
	[self updateExpenseDisplay];
}
- (void) doubleZeroButtonPressed {
	[_currentTransaction addNumber:0];
	[_currentTransaction addNumber:0];
	[self updateExpenseDisplay];
}
- (CGFloat) viewHeight {
	return self.view.frame.size.height;
}				


@end