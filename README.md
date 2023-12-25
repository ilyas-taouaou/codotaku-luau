# codotaku-luau
Luau OOP type checked Iterators, inspired from Rust

# API:
Iterator.__call<Item>(self: Iterator<Item>): Item?: Calls the next item in the iterator.

Iterator.new<Item>(next: () -> Item?, size_hint: (() -> (number, number?))?): Iterator<Item>: Creates a new iterator.

Iterator.keys<Key, Value>(iterable: {[Key]: Value}): Iterator<Key>: Returns an iterator over the keys of the given table.

Iterator.values<Key, Value>(iterable: {[Key]: Value}): Iterator<Value>: Returns an iterator over the values of the given table.

Iterator.iota(start: number, step: number): Iterator<number>: Returns an iterator that produces a sequence of numbers.

Iterator.Take<Item>(self: Iterator<Item>, count: number): Iterator<Item>: Returns an iterator that takes the first count items from the original iterator.

Iterator.Map<Item, NewItem>(self: Iterator<Item>, mapper: (Item) -> NewItem): Iterator<NewItem>: Returns an iterator that applies a function to each item of the original iterator.

Iterator.Filter<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): Iterator<Item>: Returns an iterator that includes only items that satisfy a predicate.

Iterator.Zip<FirstItem, SecondItem>(self: Iterator<FirstItem>, other: Iterator<SecondItem>): Iterator<Pair<FirstItem, SecondItem>>: Returns an iterator that combines two iterators into one.

Iterator.Enumerate<Item>(self: Iterator<Item>): Iterator<Pair<number, Item>>: Returns an iterator that pairs each item with its index.

Iterator.Fold<Item, Accumulator>(self: Iterator<Item>, folder: (Accumulator, Item) -> Accumulator, initial: Accumulator): Accumulator: Reduces the iterator to a single value using a binary function.

Iterator.Reduce<Item>(self: Iterator<Item>, reducer: (Item, Item) -> Item): Item?: Similar to Fold, but uses the first item as the initial value.

Iterator.ForEach<Item>(self: Iterator<Item>, action: (Item) -> ()): (): Applies a function to each item of the iterator for its side effects.

Iterator.Drain<Item>(self: Iterator<Item>): (): Consumes the iterator without producing any result.

Iterator.Any<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): boolean: Returns true if any item satisfies a predicate.

Iterator.All<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): boolean: Returns true if all items satisfy a predicate.

Iterator.Find<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): Item?: Returns the first item that satisfies a predicate.

Iterator.Position<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): number?: Returns the index of the first item that satisfies a predicate.

Iterator.Count<Item>(self: Iterator<Item>): number: Returns the number of items in the iterator.

Iterator.Collect<Item>(self: Iterator<Item>): {Item}: Collects all items into a table.

Iterator.Unzip<FirstItem, SecondItem>(self: Iterator<Pair<FirstItem, SecondItem>>): ({FirstItem}, {SecondItem}): Separates an iterator of pairs into two tables.
