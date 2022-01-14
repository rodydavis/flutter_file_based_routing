[![github pages](https://github.com/rodydavis/flutter_file_based_routing/actions/workflows/main.yml/badge.svg)](https://github.com/rodydavis/flutter_file_based_routing/actions/workflows/main.yml)

# Flutter File Based Routing

I was inspired by the routing in [remix.run](https://remix.run/) with nested layouts and server side components so I decided to experiment with flutter.

Since this needs to be at compile time I wrote a generator to parse the pages directory for file based routing path names to define the regex like [regex_router](https://pub.dev/packages/regex_router).

[Demo](https://rodydavis.github.io/flutter_file_based_routing/)

Archived in favor of: https://github.com/rodydavis/vscode-router-generator

## Installation

You need to install dart locally on your machine then you can run the following at your project directory:

```
dart generator/bin/main.dart
```

This will generate a `generated.g.dart` which can be used to import the generated widget to run the application.

```dart
import 'package:flutter/material.dart';

import 'generated.g.dart';

void main() {
  runApp(GeneratedApp(
    themeMode: ThemeMode.system,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ));
}

```

I also included a `router.dart` that is needed by the generator and all local widgets.

## Defining a base layout

You can define a base layout with the root name. For example: `about.dart`

```dart
import 'package:flutter/material.dart';

import '../generated.g.dart';

class AboutPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: child,
    );
  }
}

```

If you notice the child can be null and is used for the nested layout. 

This is not a widget but instead a class we can use to optionally load data in.

## Defining the index route

You can define the index route for when there are no args needed. For example: `about/index.dart`

```dart
import 'package:flutter/material.dart';

import '../../generated.g.dart';

class AboutDetails extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return const Center(
      child: Text('About'),
    );
  }
}

```

Since this is a nested layout all you need to do is provide the component and it will inherit from the parent layout (about.dart).

## Defining a named arg

You can define a named arg for a route if there is something that does not need data fetched for. For example: `/about/guest.dart`

```dart
import 'package:flutter/material.dart';

import '../../generated.g.dart';

class GuestPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return const Center(
      child: Text('Guest'),
    );
  }
}

```

This is also just a component.

## Defining a dynamic arg

Sometimes the arg is generated at runtime or needs to be pulled from a database. For example: `about/:id.dart`

```dart
import 'package:flutter/material.dart';

import '../../generated.g.dart';

class AccountPage extends UiRoute<Map<String, String>> {
  @override
  loader(route, args) => args;

  @override
  Widget builder(
      BuildContext context, Map<String, String> data, Widget? child) {
    return Center(
      child: Text('ID: ${data['id']}'),
    );
  }
}

```

You can see we set the file name with a prefix of `:` to define an arg to look for and match against. This will be provided in a map.

The loader can be used to pull data from a database but in this case it returns the arg map. By default it returns null.

The loader runs before the widget is built.

## Routing

To navigate to another page, instead of using `Navigator.of(context)` you will need to dispatch the following event:

```dart
RoutingRequest('ROUTE_HERE').dispatch(context)
```

`ROUTE_HERE` should be the named of your route like `/about/30`.

## Storing state

Everything should be stateless, but in the example you can see that even bottom tab navigation index can be done just with the route.

## Conclusion

This solves a variety of layout issues and can provide pretty urls while also only loading the data once and caching if needed.
