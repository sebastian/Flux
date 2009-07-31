//
//  Utilities.m
//  Finance
//
//  Created by Sebastian Probst Eide on 30.07.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import "Utilities.h"


@implementation Utilities

+(double)sumAmountForTransactionArray:(NSArray*)transactions {
	
	// Predicates
	NSPredicate * expensePredicate = [NSPredicate predicateWithFormat:@"expense = YES"];
	NSPredicate * incomePredicate = [NSPredicate predicateWithFormat:@"expense = NO"];
	
	NSArray * expenseTransactions = [transactions filteredArrayUsingPredicate:expensePredicate];
	NSArray * incomeTransactions = [transactions filteredArrayUsingPredicate:incomePredicate];
	
	int iKronerExpense;
	int iKronerIncome;
	@try {
		iKronerExpense = [(NSNumber*)[expenseTransactions valueForKeyPath:@"@sum.kroner"] intValue];
		iKronerIncome = [(NSNumber*)[incomeTransactions valueForKeyPath:@"@sum.kroner"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error summing kroner for transactions");
		iKronerExpense = 0;
		iKronerIncome = 0;
	}
	
	int iOreExpense;
	int iOreIncome;
	@try {
		iOreExpense = [(NSNumber*)[expenseTransactions valueForKeyPath:@"@sum.ore"] intValue];
		iOreIncome = [(NSNumber*)[incomeTransactions valueForKeyPath:@"@sum.ore"] intValue];
	}
	@catch (NSException * e) {
		NSLog(@"Error summing ore for transactions");
		iOreExpense = 0;
		iOreIncome = 0;
	}
	
	int iKroner = iKronerExpense - iKronerIncome;
	int iOre = iOreExpense - iOreIncome;
	
	double amount = iKroner + ((double)iOre/100);

	return amount;
}
+(float)keyboardAnimationDuration {return 0.3;}
@end
