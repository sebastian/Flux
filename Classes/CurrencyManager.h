/*
 CurrencyManager.h
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

@interface CurrencyManager : NSObject {
	
	NSString *baseCurrency;
	NSMutableDictionary *exchangeRates;
	NSDate *lastRefresh;
	BOOL isRefreshing;
	NSArray *availableCurrencies;
	
	NSDictionary * countryToCurrency;
	
	NSMutableDictionary *conversionDict;
	NSNumberFormatter *numberFormatterWithFraction;
	NSNumberFormatter *numberFormatterWithoutFraction;
}
@property (nonatomic, retain) NSDictionary * countryToCurrency;
@property (retain) NSString *baseCurrency;
@property (nonatomic, retain) NSDate *lastRefresh;
@property (retain) NSMutableDictionary *exchangeRates;
@property (retain) NSArray *availableCurrencies;
@property (retain) NSMutableDictionary *conversionDict;

+ (CurrencyManager *)sharedManager;

- (NSString *)currencyDescription:(NSString*)currencyCode;
- (NSString *)baseCurrencyDescription;

- (NSString *)currencyDescriptionForAmount:(NSString*)amount currency:(NSString*)currencyCode;
- (NSString *)baseCurrencyDescriptionForAmount:(NSString *)amount;

- (NSString *)currencyDescriptionForAmount:(NSNumber *)amount withFraction:(BOOL)withFraction currency:(NSString*)currencyCode;
- (NSString *)baseCurrencyDescriptionForAmount:(NSNumber *)amount withFraction:(BOOL)withFraction;
- (void)forceRefresh;
- (void)refreshIfNeeded;
- (void)refreshExchangeRates;
- (void)refreshFailed;
- (void)finishRefreshWithExchangeRates:(NSMutableDictionary *)newExchangeRates;
- (float)convertValue:(float)sourceValue fromCurrency:(NSString *)sourceCurrency;

@end