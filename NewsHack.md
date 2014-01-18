NewsHack
========

*The following is a short document explaining planned features for the app. Items are sorted by priority, with the most important features at the top of the list.*

---


### Comments / news sorted by date ###

Nice feature, not trivial to implement ...


### Improved caching for comments ###

The following code could be problematic:

    NSString *key = [FS_NEWS_ITEM_COMMENTS_DATA_KEY stringByAppendingFormat:@"-%d", newsItem.identifier];
    NSData *data = [[EGOCache globalCache] dataForKey:key];

Can't rely on the identifier to exist, might create a bogus key. Either way, undefined behaviour could happen. 

Users might also want some option to remove old cached items. 


### Add the ability to sort news by time or popularity ###

Currently popularity is implemented, but some users prefer to see newest items first.


### Ability to vote postings / comments up and down ###

Will make the app slightly more useful as a replacement for the website.


### Ability to share news on Social Networks ###

Perhaps Twitter has highest prio? "Click-to-share" on your Twitter account.


### Inverse colors mode ###

Some Hackers might prefer a dark colored app instead of the light colored one. Some option to switch between a light and dark scheme could be nice.