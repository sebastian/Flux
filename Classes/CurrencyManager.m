/*
 CurrencyManager.m
 AppSalesMobile
 
 * Copyright (c) 2008, omz:software
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the <organization> nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY omz:software ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CurrencyManager.h"


@implementation CurrencyManager

@synthesize baseCurrency;
@synthesize lastRefresh;
@synthesize exchangeRates;
@synthesize availableCurrencies;
@synthesize conversionDict;
@synthesize countryToCurrency;

- (id)init
{
	[super init];
	
	numberFormatterWithFraction = [NSNumberFormatter new];
	[numberFormatterWithFraction setMinimumFractionDigits:2];
	[numberFormatterWithFraction setMaximumFractionDigits:2];
	[numberFormatterWithFraction setMinimumIntegerDigits:1];
	
	numberFormatterWithoutFraction = [NSNumberFormatter new];
	[numberFormatterWithoutFraction setMinimumFractionDigits:0];
	[numberFormatterWithoutFraction setMaximumFractionDigits:0];
	[numberFormatterWithoutFraction setMinimumIntegerDigits:1];
		
	self.availableCurrencies = [NSArray arrayWithObjects:
								  @"USD", @"AUD", @"BHD", @"THB", @"BND", 
								  @"CLP", @"DKK", @"EUR", @"HUF", @"HKD", @"ISK", @"CAD", 
								  @"QAR", @"KWD", @"MYR", @"MTL", @"MUR", @"MXN", 
								  @"NPR", @"TWD", @"NZD", @"NOK", @"PKR", @"GBP", 
								  @"ZAR", @"BRL", @"CNY", @"OMR", @"IDR", @"RUB", 
								  @"SAR", @"ILS", @"SEK", @"CHF", @"SGD", @"SKK", 
								  @"LKR", @"KRW", @"KZT", @"CZK", @"AED", @"JPY", 
								  @"LVL", @"LTL", @"EEK", @"CYP", @"INR", nil];
	
	self.countryToCurrency = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"USD",@"AS",@"USD",@"EC",@"USD",@"SV",@"USD",@"GU",@"USD",@"MH",
							  @"USD",@"FM",@"USD",@"MP",@"USD",@"PW",@"USD",@"PA",@"USD",@"PR",@"USD",
							  @"TC",@"USD",@"US",@"USD",@"UM",@"USD",@"VG",@"USD",@"VI",@"AUD",@"CX",
							  @"AUD",@"CC",@"AUD",@"HM",@"AUD",@"KI",@"AUD",@"NR",@"AUD",@"NF",@"AUD",@"TV",
							  @"AUD",@"AU",@"BHD",@"BH",@"THB",@"TH",@"BND",@"BN",@"CLP",@"CL",@"DKK",@"DK",
							  @"DKK",@"FO",@"DKK",@"GL",@"EUR",@"AD",@"EUR",@"AT",@"EUR",@"BE",@"EUR",@"CY",
							  @"EUR",@"FI",@"EUR",@"FR",@"EUR",@"FX",@"EUR",@"GF",@"EUR",@"TF",@"EUR",@"DE",
							  @"EUR",@"GR",@"EUR",@"GP",@"EUR",@"VA",@"EUR",@"IE",@"EUR",@"IT",@"EUR",@"LU",
							  @"EUR",@"MT",@"EUR",@"MQ",@"EUR",@"YT",@"EUR",@"MC",@"EUR",@"NL",@"EUR",@"PT",
							  @"EUR",@"RE",@"EUR",@"SM",@"EUR",@"CS",@"EUR",@"SK",@"EUR",@"SI",@"EUR",@"ES",
							  @"EUR",@"PM",@"HUF",@"HU",@"HKD",@"HK",@"ISK",@"IS",@"CAD",@"CA",@"QAR",@"QA",
							  @"KWD",@"KW",@"MYR",@"MY",@"MUR",@"MU",@"MXN",@"MX",@"NPR",@"NP",@"TWD",@"TW",
							  @"NZD",@"CK",@"NZD",@"NZ",@"NZD",@"NU",@"NZD",@"PN",@"NZD",@"TK",@"NOK",@"AQ",
							  @"NOK",@"BV",@"NOK",@"NO",@"NOK",@"SJ",@"PKR",@"PK",@"GBP",@"IO",@"GBP",@"GS",
							  @"GBP",@"GB",@"ZAR",@"LS",@"ZAR",@"NA",@"ZAR",@"ZA",@"CNY",@"CN",@"OMR",@"OM",
							  @"IDR",@"ID",@"RUB",@"RU",@"SAR",@"SA",@"ILS",@"IL",@"SEK",@"SE",@"CHF",@"LI",
							  @"CHR",@"CH",@"SGD",@"SG",@"LKR",@"LK",@"KRW",@"KR",@"KZT",@"KZ",@"CKZ",@"CZ",
							  @"AED",@"AE",@"JPY",@"JP",@"INR",@"IN",@"LVL",@"LV",@"LTL",@"LT",@"EEK",@"EE", nil];
	
	isRefreshing = NO;
	self.baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerBaseCurrency"];
	if (!self.baseCurrency)
		self.baseCurrency = @"EUR";
	
	self.lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerLastRefresh"];
	if (!self.lastRefresh)
		self.lastRefresh = [NSDate dateWithTimeIntervalSince1970:1225397963]; //Oct, 30, 2008
	
	exchangeRates = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CurrencyManagerExchangeRates"] retain];
	if (!exchangeRates) {
		exchangeRates = [NSMutableDictionary new];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2178] forKey:@"\"AED to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5096] forKey:@"\"AUD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.1227] forKey:@"\"BHD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5519] forKey:@"\"BND to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.3351] forKey:@"\"BRL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.6378] forKey:@"\"CAD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.6605] forKey:@"\"CHF to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0012] forKey:@"\"CLP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1171] forKey:@"\"CNY to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.0112] forKey:@"\"CYP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0389] forKey:@"\"CZK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1343] forKey:@"\"DKK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:1.0000] forKey:@"\"EUR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:1.1968] forKey:@"\"GBP to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.1033] forKey:@"\"HKD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0037] forKey:@"\"HUF to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0001] forKey:@"\"IDR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2003] forKey:@"\"ILS to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0159] forKey:@"\"INR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0036] forKey:@"\"ISK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0084] forKey:@"\"JPY to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0006] forKey:@"\"KRW to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.9416] forKey:@"\"KWD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0067] forKey:@"\"KZT to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0073] forKey:@"\"LKR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.7266] forKey:@"\"MTL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0246] forKey:@"\"MUR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0592] forKey:@"\"MXN to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.221] forKey:@"\"MYR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.11335] forKey:@"\"NOK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0101] forKey:@"\"NPR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.4338] forKey:@"\"NZD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:2.0786] forKey:@"\"OMR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0101] forKey:@"\"PKR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2198] forKey:@"\"QAR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.029] forKey:@"\"RUB to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2134] forKey:@"\"SAR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0978] forKey:@"\"SEK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.5226] forKey:@"\"SGD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0329] forKey:@"\"SKK to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0228] forKey:@"\"THB to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.024] forKey:@"\"TWD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.8003] forKey:@"\"USD to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0764] forKey:@"\"ZAR to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:1.4279] forKey:@"\"LVL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.2912] forKey:@"\"LTL to EUR\""];
		[exchangeRates setObject:[NSNumber numberWithFloat:0.0639] forKey:@"\"EEK to EUR\""];
		[self refreshIfNeeded];
	}

	self.conversionDict = [[NSMutableDictionary alloc] init];
		
	return self;
}

- (void)setBaseCurrency:(NSString *)newBaseCurrency
{
	[self.conversionDict removeAllObjects];
	
	[newBaseCurrency retain];
	[baseCurrency release];
	baseCurrency = newBaseCurrency;
	[[NSUserDefaults standardUserDefaults] setObject:baseCurrency forKey:@"CurrencyManagerBaseCurrency"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerDidChangeBaseCurrency" object:self];
}

- (NSString *)baseCurrencyDescription
{
	return [self currencyDescription:baseCurrency];
}
- (NSString *)currencyDescription:(NSString*)currencyCode {
	if ([currencyCode isEqual:@"EUR"])
		return @"€";
	else if ([currencyCode isEqual:@"USD"])
		return @"$";
	else if ([currencyCode isEqual:@"JPY"])
		return @"¥";
	else if ([currencyCode isEqual:@"GBP"])
		return @"£";
	
	return currencyCode;	
}

- (NSString *)baseCurrencyDescriptionForAmount:(NSString *)amount
{
	return [self currencyDescriptionForAmount:amount currency:baseCurrency];
}
- (NSString *)currencyDescriptionForAmount:(NSString*)amount currency:(NSString*)currencyCode {
	if ([currencyCode isEqual:@"USD"]) {
		return [NSString stringWithFormat:@"$%@", amount];
	} else {
		return [NSString stringWithFormat:@"%@ %@", amount, [self currencyDescription:currencyCode]];
	}
}


- (NSString *)baseCurrencyDescriptionForAmount:(NSNumber *)amount withFraction:(BOOL)withFraction
{
	return [self currencyDescriptionForAmount:amount withFraction:withFraction currency:baseCurrency];
}
- (NSString *)currencyDescriptionForAmount:(NSNumber *)amount withFraction:(BOOL)withFraction currency:(NSString*)currencyCode
{
	NSNumberFormatter *numberFormatter = (withFraction) ? (numberFormatterWithFraction) : (numberFormatterWithoutFraction);
	NSString *formattedAmount = [numberFormatter stringFromNumber:amount];
	return [self currencyDescriptionForAmount:formattedAmount currency:currencyCode];
}

- (void)refreshIfNeeded
{
	if (!isRefreshing && ([[NSDate date] timeIntervalSinceDate:self.lastRefresh] > 21600)) { 
		isRefreshing = YES;
		[self performSelectorInBackground:@selector(refreshExchangeRates) withObject:nil];
	}
}

- (void)forceRefresh
{
	if (isRefreshing)
		return;
	[self performSelectorInBackground:@selector(refreshExchangeRates) withObject:nil];
}

- (void)refreshFailed
{
	isRefreshing = NO;
	[self.conversionDict removeAllObjects];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerError" object:self];
}

- (void)finishRefreshWithExchangeRates:(NSMutableDictionary *)newExchangeRates
{
	self.exchangeRates = newExchangeRates;
	isRefreshing = NO;
	self.lastRefresh = [NSDate date];

	[self.conversionDict removeAllObjects];

	[[NSUserDefaults standardUserDefaults] setObject:self.exchangeRates forKey:@"CurrencyManagerExchangeRates"];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastRefresh forKey:@"CurrencyManagerLastRefresh"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CurrencyManagerDidUpdate" object:self];
}

- (void)refreshExchangeRates
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSMutableDictionary *newExchangeRates = [NSMutableDictionary dictionary];
	
	[newExchangeRates setObject:[NSNumber numberWithFloat:1.0] forKey:@"\"EUR to EUR\""];
	
	NSMutableString *urlString = [NSMutableString stringWithString:@"http://quote.yahoo.com/d/quotes.csv?s="];
		
	int i = 0;
	for (NSString *currency in self.availableCurrencies) {
		if (i > 0)
			[urlString appendString:@"+"];
		if (![currency isEqual:@"EUR"])
			[urlString appendFormat:@"%@%@=X", currency, @"EUR"];
		i++;
	}
	[urlString appendString:@"&f=nl1"];
	
	NSStringEncoding enc;
	NSString *csv = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] usedEncoding:&enc error:NULL]; //[NSString stringWithContentsOfURL:[NSURL URLWithString:urlString]];

	if (!csv) {
		TTLOG(@"URL could not be retrieved in %@", self);
		[self performSelectorOnMainThread:@selector(refreshFailed) withObject:nil waitUntilDone:YES];
		[pool release];
		return;
	}
	NSArray *lines = [csv componentsSeparatedByString:@"\n"];
	for (NSString *line in lines) {
		NSArray *comps = [line componentsSeparatedByString:@","];
		if ([comps count] == 2) {
			NSString *currenciesString = [comps objectAtIndex:0]; //ex: "USD to EUR"
			float exchangeRate = [[comps objectAtIndex:1] floatValue];
			[newExchangeRates setObject:[NSNumber numberWithFloat:exchangeRate] forKey:currenciesString];
		}
	}
	[self performSelectorOnMainThread:@selector(finishRefreshWithExchangeRates:) withObject:newExchangeRates waitUntilDone:YES];
	[pool release];
}

- (float)convertValue:(float)sourceValue fromCurrency:(NSString *)sourceCurrency
{
	
	/* short-circuit if the source is the same as the destination */
	if ([sourceCurrency isEqualToString:self.baseCurrency])
		return sourceValue;

	NSNumber *conversionFromSourceCurrency = [self.conversionDict objectForKey:sourceCurrency];
	float conversionFactor;

	if (conversionFromSourceCurrency) {
		conversionFactor = [conversionFromSourceCurrency floatValue];

	} else {
		/* Convert to euros, our universal common factor */
		NSNumber *conversionRateEuroNumber = [exchangeRates objectForKey:[NSString stringWithFormat:@"\"%@ to EUR\"", sourceCurrency]];
		if (!conversionRateEuroNumber) {
			TTLOG(@"Error: Currency code not found or exchange rates not downloaded yet");
			return 0.0;
		}	
		
		conversionFactor = [conversionRateEuroNumber floatValue];
		if (![self.baseCurrency isEqualToString:@"EUR"]) {
			/* If the destination currency isn't euros, convert euros to our destination currency.
			 * The exchangeRates stores X to EUR, so we divide by the conversion rate to go EUR to X.
			 */
			NSNumber *conversionRateBaseCurrencyNumber = [exchangeRates objectForKey:[NSString stringWithFormat:@"\"%@ to EUR\"", self.baseCurrency]];
			conversionFactor /= [conversionRateBaseCurrencyNumber floatValue];
		}
		
		/* Cache this conversion for next time */
		[self.conversionDict setObject:[NSNumber numberWithFloat:conversionFactor] forKey:sourceCurrency];
	}
	
	return (sourceValue * conversionFactor);
}

+ (CurrencyManager *)sharedManager
{
	static CurrencyManager *sharedManager = nil;
	if (sharedManager == nil)
		sharedManager = [CurrencyManager new];
	return sharedManager;
}

- (void)dealloc
{
	self.conversionDict = nil;

	[numberFormatterWithFraction release];
	[numberFormatterWithoutFraction release];
	
	[exchangeRates release];
	[baseCurrency release];
	[super dealloc];
}

@end
