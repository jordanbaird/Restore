<div align='center'>
    <img src='/media/header.svg'>
    <h2>Take a snapshot of an object and restore from it.</h2>
    <br/>
</div>

![Build](https://img.shields.io/github/workflow/status/jordanbaird/Restore/Build)
[![Code Coverage](https://codecov.io/gh/jordanbaird/Restore/branch/main/graph/badge.svg?token=X5xATHinur)](https://codecov.io/gh/jordanbaird/Restore)
![Release](https://img.shields.io/github/v/release/jordanbaird/Restore)
![Swift Version](https://img.shields.io/badge/Swift-5.6%2B-orange)
![License](https://img.shields.io/github/license/jordanbaird/Restore)

[Read the full documentation here](https://jordanbaird.github.io/Restore/documentation/restore/)

``Restore`` is a convenient, easy to use package that allows you to take a snapshot of an object, and restore the object to the state it was in when the snapshot was taken. 

Start by creating a type that conforms to the ``RestorableObject`` protocol, and decorating the properties you wish to include in snapshots with the ``Restorable`` property wrapper.

```swift
class FavoriteFruits: RestorableObject {
    @Restorable var rank1 = "Apple"
    @Restorable var rank2 = "Banana"
    @Restorable var rank3 = "Watermelon"
}
let favorites = FavoriteFruits()
```

Let's say that somewhere down the line, "Banana" overtakes "Apple", moving into `rank1`. As an extra precaution, the judges want to save the current results in case a mistake was made. They do so using the ``RestorableObject/takeSnapshot(withKey:)`` method. Now they are free to update the results.

```swift
favorites.takeSnapshot(withKey: "BackupResults")

favorites.rank1 = "Banana"
favorites.rank2 = "Apple"
```

Later, they find out that a mistake was indeed made. The vote was miscounted, and the results are now invalid. Thankfully, they have the backup. Rather than having to go through each individual property and set their values back to their original states, they can simply call the ``RestorableObject/restore(withKey:)`` method. Every property is set back to the way it was before the mistake was made. Crisis averted.

```swift
favorites.restore(withKey: "BackupResults")

print(favorites.rank1) // Prints "Apple"
print(favorites.rank2) // Prints "Banana"
```

Now, let's say that the judges get a fancy new `Counter` object. It automatically tallies the results and stores them within itself. But they still want the people viewing the results to be able to access the results from the counter. To do this, they must use a computed property.

```swift
class FavoriteFruits: RestorableObject {
    let counter = Counter()
    
    var rank1: String { 
        counter.rank1 
    }
    var rank2: String {
        counter.rank2
    }
    var rank3: String {
        counter.rank3
    }
}
```

This poses a problem, however, as computed properties don't support property wrappers. Now they can't mark their ranks as ``Restorable``. Then one of the judges, who read the manual, remembered that they can add computed properties to the ``RestorableObject/references-4bbzk`` array, and they will still be included in snapshots and restorations. Again, crisis averted.

```swift
class FavoriteFruits: RestorableObject {
    let counter = Counter()

    var rank1: String { 
        counter.rank1 
    }
    var rank2: String {
        counter.rank2
    }
    var rank3: String {
        counter.rank3
    }
    
    var references: [Reference<FavoriteFruits>] {
        Reference(owner: self, name: "rank1", keyPath: \.rank1)
        Reference(owner: self, name: "rank2", keyPath: \.rank2)
        Reference(owner: self, name: "rank3", keyPath: \.rank3)
    }
}
```

> The `name` parameter in the ``Reference`` type's initializer must be the same as the name of the property, or the property will not be saved.

You can also access individual properties from a snapshot.

```swift
let properties = try favorites.properties(withKey: "BackupResults")
print(properties.rank1)
// Prints: "Apple"
```
