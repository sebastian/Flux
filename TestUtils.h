//
//  TestUtils.h
//  Finance
//
//  Created by Sebastian Probst Eide on 23.08.09.
//  Copyright 2009 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import <SenTestingKit/SenTestingKit.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>


@interface TestUtils : NSObject {	
}

+ (NSManagedObjectContext *) managedObjectContext;
+ (NSString*)filePath;
+ (void) clearData;
@end
