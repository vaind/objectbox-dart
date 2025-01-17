ObjectBox for Dart/Flutter
==========================
ObjectBox for Dart is a standalone database storing Dart objects locally, with strong ACID semantics.

Help wanted
-----------
ObjectBox for Dart is still in a prototype stage supporting only the most basic database tasks, like putting and getting objects.
However, the ObjectBox core supports many more features, e.g. queries, indexing, async operations, transaction control.
To bring all these features to Dart, we're asking the community to help out. PRs are more than welcome!
The ObjectBox team will try its best to guide you and answer questions. 

### Open Development Process

This project is completely managed here on GitHub using its [issue tracker](https://github.com/objectbox/objectbox-dart/issues) and [project boards](https://github.com/objectbox/objectbox-dart/projects).

To prepare an upcoming version, we create a (Kanban like) board for it.
Once it is decided which features and fixes go into the version, the according issues are added to the board.
Issues on the board are referred to as "cards" which move from left to right:

* New cards start in the "To Do" column.
  Within the column, cards are ordered: more important tasks should be above less important ones.  
* Once somebody starts on a task, the according card is moved to "In progress".
  Also, please assign yourself to the issue.
* Once a task is considered complete (e.g. PR is made), put it in the "Review" column.
* Once another person had a look and is happy, the task is finally moved to "Done"
 
Anyone can contribute in this process. Look for tasks having a **"help wanted"** tag.

### Feedback

Also, please let us know your feedback by opening an issue:
for example, if you experience errors or if you have ideas for how to improve the API.
Thanks!

Getting started
---------------
To try out the demo code in this repository, follow these steps:

1. Install [objectbox-c](https://github.com/objectbox/objectbox-c) system-wide: `bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-c/master/download.sh) 0.7` (answer Y when it asks about installing to /usr/lib).
2. Back in this repository, run `pub get`.
3. Execute `pub run build_runner build`. This regenerates the ObjectBox model to make it usable in Dart (i.e. the file `test/test.g.dart`) and is necessary each time you add or change a class annotated with `@Entity(...)`.
4. Finally run `pub run test test/test.dart` to run the unit tests.

Dart integration
----------------
In general, Dart class annotations are used to mark classes as ObjectBox entities and provide meta information.
Note that right now, only a limited set of types is supported; this will be expanded upon in the near future.
Entity IDs and UIDs that are defined in their respective annotations need to be unique across all entities, while property IDs only need to be unique in their respective entity; property UIDs also need to be globally unique.

All non-annotated class instance variables are ignored by ObjectBox.

### Object IDs

Each entity is required to have an _Id_ property of type _Long_.
Already persisted entities have an ID greater or equal to 1.
New (not yet persisted) objects typically have _Id_ value of `0` or `null`: calling `Box.put` automatically assigns a new ID to the object.

### Example

*Note:* specifying the (meta model) IDs in annotations manually is a temporary quick solution.
In a later version, you won't have to do this the and e.g. `@Property(id: 2, uid: 1002)` can be dropped completely.
As specified in step 3 of the _Getting started_ section, Dart's _build\_runner_ and _source\_gen_ are currently used and the generator will be extended to automatically manage the meta model IDs in the future.

```dart
import "../lib/objectbox.dart";
part "test.g.dart";

@Entity(id: 1, uid: 1)
class Note {
    @Id(id: 1, uid: 1001)       // automatically always 'int' in Dart code and 'Long' in ObjectBox
    int id;

    @Property(id: 2, uid: 1002)
    String text;

    Note();             // empty default constructor needed
    Note.construct(this.text);
    toString() => "Note{id: $id, text: $text}";
}
```

In your main function, you can then create a _store_ which needs an array of your entity classes and definitions to be constructed. If you have several entities, construct your store like `Store([[Entity1, Entity1_OBXDefs], [Entity2, Entity2_OBXDefs]])` etc.
Finally, you need a _box_, representing the interface for objects of one specific entity type.

```dart
var store = Store([[Note, Note_OBXDefs]]);
var box = Box<Note>(store);

var note = Note.construct("Hello");
note.id = box.put(note);
print("new note got id ${note.id}");
print("refetched note: ${box.get(note.id)}");

store.close();
```

Basic technical approach
------------------------
ObjectBox offers a [C API](https://github.com/objectbox/objectbox-c) which can be called by [Dart FFI](https://dart.dev/server/c-interop).
The C API is is also used by the ObjectBox language bindings for [Go](https://github.com/objectbox/objectbox-go), [Swift](https://github.com/objectbox/objectbox-swift), and [Python](https://github.com/objectbox/objectbox-python).
These language bindings currently serve as an example for this Dart implementation.

Internally, ObjectBox uses [FlatBuffers](https://google.github.io/flatbuffers/) to store objects.
There are two basic ways to make the conversion: generated binding code, or implicit FlatBuffers conversion.
The latter is used at the moment (helped us to get started quickly).
A future version will exchange that with code generation.  

Changelog
---------
[CHANGELOG.md](CHANGELOG.md)

License
-------
    Copyright 2019 ObjectBox Ltd. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

