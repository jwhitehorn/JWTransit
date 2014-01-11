//
//  JWTransit.m
//  TransitTestsIOS
//
//  Created by Jason Whitehorn on 1/8/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import "JWTransit.h"

@interface JWTransit ()

@property (strong, nonatomic) JSContext *jsContext;

- (void) registerBuiltInFunctions;

@end

@implementation JWTransit

@synthesize jsContext;

- (id) init{
    self = [super init];
    if(self){
        jsContext = [[JSContext alloc] initWithVirtualMachine:[JSVirtualMachine new]];
        [self registerBuiltInFunctions];
    }
    return self;
}

- (void) loadFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error{
    [jsContext evaluateScript:[NSString stringWithContentsOfFile:path encoding:enc error:error]];
}

- (void) define:(NSString *)function withBlock:(id)block{
    jsContext[function] = block;
}

- (id) execute:(NSString *)statement{
    NSString *result = [[jsContext evaluateScript:statement] toString];
    return [result isEqualToString:@"undefined"] ? nil : result;
}

- (id) invokeBlock:(JSValue *)block{
    //http://trac.webkit.org/changeset/144489
    
    NSString *statement = [NSString stringWithFormat:@"(%@());", [block toString]];
    return [self execute:statement];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void) registerBuiltInFunctions{
    [self execute:@"var JWTransit = {};"];
    [self define:@"JWTransit.Dispatch" withBlock:^(NSString *queue, JSValue *block){
        NSLog(@"JWTransit.Dispatch enter!");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self invokeBlock:block];
        });
    }];
}

@end