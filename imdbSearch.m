//
//  imdbSearch.m
//  imdbSearch
//
//  Created by Kirbyk on 18.02.2014.
//  Copyright (c) 2014 Kirbyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

@interface TLimdbSearchDatastore : NSObject <TLSearchDatastore> {
  BOOL $usingInternet;
}
@end

@implementation TLimdbSearchDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
  NSString *searchString = [query searchString];

  searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

  NSLog(@"\n\n\n%@\n\n", searchString);
  NSString *format = [NSString stringWithFormat:@"http://www.omdbapi.com/?s=%@", searchString];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:5];

  TLRequireInternet(YES);
  $usingInternet = YES;

  NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:queue
                         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error){
    if (data != nil) {
      NSMutableArray *searchResults = [NSMutableArray array];

      NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

      NSArray *movies = root[@"Search"];
      
      int limit = 10;
      int count = 0;
      for (NSDictionary *movie in movies) {
        if (count >= limit) break;

        NSMutableString *url = [NSMutableString stringWithString:@"imdb:///title/"];
	[url appendString:[NSString stringWithFormat:@"%@", movie[@"imdbID"]]];

        SPSearchResult *result = [[[SPSearchResult alloc] init] autorelease];
        [result setTitle:movie[@"Title"]];
        [result setSubtitle:movie[@"Year"]];
        [result setUrl:url];

        [searchResults addObject:result];
        count++;
      }

      TLCommitResults(searchResults, TLDomain(@"com.imdb.imdb", @"imdbSearch"), results);
    }

    TLRequireInternet(NO);
    $usingInternet = NO;
    [results storeCompletedSearch:self];

    TLFinishQuery(results);
  }];

}

- (NSArray *)searchDomains {
  return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.imdb.imdb", @"imdbSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
  return @"com.imdb.imdb";
}

- (BOOL)blockDatastoreComplete {
  return $usingInternet;
}
@end
