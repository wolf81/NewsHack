NewsHack
========

An application for scraping the HackerNews website and displaying it in a more readable format on iPhone devices.

**PLEASE NOTE:** I haven't tested this code in the past year or so. The app has not been released on the AppStore due to Apple finding the functionality too limited. I couldn't figure out what to add, since I basically wanted to release an app just for reading and commenting on the HackerNews website.

The code might be useful for aspiring iOS developers as it teaches:
- Good Objective-C style (prefixes, method and parameter names, etc...)
- Speedy table view drawing for the comments view by drawing directly on the canvas instead of using lots of views.
- A nice way of handling errors ([I've documented my approach in this StackOverflow post][0])
- Implementing In-App purchases.

[0]: http://stackoverflow.com/questions/4654653/how-can-i-use-nserror-in-my-iphone-app/14086231#14086231
