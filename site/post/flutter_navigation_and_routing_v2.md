# About Flutter Navigation and Routing System

It's recommended that you read the [official document](https://flutter.dev/docs/development/ui/navigation) first. If you are still confused about the system after that, then this post is for you.

# Core

In my opinion, the core of the new system is making three things synchronous, the app state, UI, and URI.

How does the system do that? It relies on two classes, [`RouteInformationParser`](https://api.flutter.dev/flutter/widgets/RouteInformationParser-class.html) and [`RouterDelegate`](https://api.flutter.dev/flutter/widgets/RouterDelegate-class.html). They work together to synchronize the app state, UI, and URI.

![demonstration](../asset/image/navigation_and_routing_v2_demonstration.gif)

# SSOT

To avoid messing up these things, we make the app state the single source of truth (a.k.a. **SSOT**). All the other things must keep synchronizing with it.

Supposing we have an app state. How can a user change the state? There are two ways:

1. Interact with UI.
2. Change the URI when the user uses a browser.

In the first case, we change the app state, updating the UI and URI. Everything is in synchronization.

In the second case, we change the URI, updating the app state according to the new URI, and finally updating the UI. Again, everything is in synchronization.

# `RouteInformationParser` and `RouterDelegate`

To implement the new navigation and routing system, we need to implement four methods.

1. `RouteInformationParser.parseRouteInformation`
2. `RouteInformationParser.restoreRouteInformation`
3. `RouterDelegate.currentConfiguration` (a getter method)
4. `RouterDelegate.setNewRoutePath`

For these methods to work together, we introduce an abstract path model (let me give the model a name: **path**). Below this the transitions, these methods make.

1. `RouteInformationParser.parseRouteInformation`: URI to path
2. `RouteInformationParser.restoreRouteInformation`: path to URI
3. `RouterDelegate.currentConfiguration` (a getter method): app state to path
4. `RouterDelegate.setNewRoutePath`: path to app state

Aren't they perfectly symmetrical? Now we have some works to do. Let's suppose that we are the flutter framework now.

1. When a user has interacted with the UI, we get an event. We update the app state, then calling the third method (in the above list), finally calling the second method. Of course, we need to update the UI at last. After all these things we have synchronized the app state, URI, and UI.
2. When a user has changed the URI in the browser, we get a new URI. We call the first method, then calling the fourth method. Again, we need to update the UI at last. After all these things we have synchronized the app state, URI, and UI.

Basically, the flutter framework does the same things as we did (you can verify this by checking the logging from the demonstration app in the last of this post).

# What's Next

You can refer to the [demonstration app](https://github.com/YRFT/YRFT.github.io/tree/main/dart_and_flutter/navigation_and_routing_v2). The main code is in `/lib/main.dart`.
