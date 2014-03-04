//
//  filmSearch.m
//  filmSearch
//
//  Created by Kirbyk on 18.02.2014.
//  Copyright (c) 2014 Kirbyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SearchLoader/TLLibrary.h>

#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)
#define GET_INT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).intValue : default)
#define GET_STR(key, default) (prefs[key] ? prefs[key] : default)

@interface TLfilmSearchDatastore : NSObject <TLSearchDatastore> {
  BOOL $usingInternet;
}
@end

@implementation TLfilmSearchDatastore
- (void)performQuery:(SDSearchQuery *)query withResultsPipe:(SDSearchQuery *)results {
  NSString *searchString = [query searchString];

  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/me.kirbyk.filmsearch.plist"];
  int limit = GET_INT(@"MovieLimit", 5);

  searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

  NSString *format = [NSString stringWithFormat:@"http://www.omdbapi.com/?s=%@", searchString];
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:format]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:2];

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

      TLCommitResults(searchResults, TLDomain(@"com.film.film", @"filmSearch"), results);
    }

    TLRequireInternet(NO);
    $usingInternet = NO;
    [results storeCompletedSearch:self];

    TLFinishQuery(results);
  }];

}

- (NSArray *)searchDomains {
  return [NSArray arrayWithObject:[NSNumber numberWithInteger:TLDomain(@"com.film.film", @"filmSearch")]];
}

- (NSString *)displayIdentifierForDomain:(NSInteger)domain {
  return @"com.film.film";
}

- (BOOL)blockDatastoreComplete {
  return $usingInternet;
}
@end
