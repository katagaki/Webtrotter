# Webtrotter
Experimental Google search client in SwiftUI

Parsed search results from Google's horrible HTML class names and odd layouts, presented with nothing more than iOS's native list view, that opens in the user's default browser.

## Why I built this
The official iOS app for Google Search traps you inside the app by using a web view, when it really should be opening search results in the default browser. Web views do not support Safari's content blockers and extensions, which make the web browsing experience that much less pleasant.

By building a client above Google Search, it creates a better experience for users by always presenting a user interface that is familiar to users, and always opening search results in the user's default browser. Additionally, it also removes the distractions Google presents in search results, in an attempt to keep users on Google's services.

## What works
- Simple search queries
- The first page of search results
- Search result titles, descriptions, and link parsing (may be broken if Google decides to mess up their HTML even more)
- Opening links to search results

## What's planned
- The second page of search results, and beyond
- Opt-in search suggestions
- Image search (this one is going to be tough)
- Clear cookies before every new search
