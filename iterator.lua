--!strict
local Iterator = {}
Iterator.__index = Iterator

type self<Item> = {
	Next: () -> Item?,
    SizeHint: (() -> (number, number?))?,
}

export type Iterator<Item> = typeof( setmetatable({} :: self<Item>, Iterator) )
export type Pair<FirstItem, SecondItem> = {first: FirstItem, second: SecondItem}

function Iterator.__call<Item>(self: Iterator<Item>): Item?
    return self.Next()
end

-- Helpers
local function getTableSize(iterable: {[any]: any}): number
    local size = 0
    for _ in iterable do
        size += 1
    end
    return size
end

-- Iterator Constructors
function Iterator.new<Item>(next: () -> Item?, size_hint: (() -> (number, number?))?): Iterator<Item>
	return setmetatable({
        Next = next,
        SizeHint = size_hint,
    } :: self<Item>, Iterator)
end

function Iterator.keys<Key, Value>(iterable: {[Key]: Value}): Iterator<Key>
    local itemsCount = getTableSize(iterable)

    local key: Key?
    return Iterator.new(function()
        local _value: Value?
        key, _value = next(iterable, key)
        itemsCount -= 1
        return key
    end, function()
        return itemsCount, itemsCount
    end)
end

function Iterator.values<Key, Value>(iterable: {[Key]: Value}): Iterator<Value>
    local itemsCount = getTableSize(iterable)

    local key: Key?
    return Iterator.new(function()
        local value: Value?
        key, value = next(iterable, key)
        itemsCount -= 1
        return value
    end, function()
        return itemsCount, itemsCount
    end)
end

function Iterator.iota(start: number, step: number): Iterator<number>
    return Iterator.new(function()
        start += step
        return start
    end)
end

-- Iterator Adapters
function Iterator.Take<Item>(self: Iterator<Item>, count: number): Iterator<Item>    
    return Iterator.new(function()
        if count == 0 then return nil end
        count -= 1
        return self.Next()
    end, function()
        return count, count
    end)
end

function Iterator.Map<Item, NewItem>(self: Iterator<Item>, mapper: (Item) -> NewItem): Iterator<NewItem>
    return Iterator.new(function()
        local item = self.Next()
        if item == nil then return nil end
        return mapper(item)
    end, self.SizeHint)
end

function Iterator.Filter<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): Iterator<Item>
    return Iterator.new(function()
        for item in self.Next do
            if predicate(item) then
                return item
            end
        end
        return nil
    end, function()
        local min, max = 0, nil
        if self.SizeHint then
            local _discard
            _discard, max = self.SizeHint()
        end
        return min, max
    end)
end

function Iterator.Zip<FirstItem, SecondItem>(self: Iterator<FirstItem>, other: Iterator<SecondItem>): Iterator<Pair<FirstItem, SecondItem>>
    return Iterator.new(function()
        local first = self.Next()
        if first == nil then return nil end
        local second = other.Next()
        if second == nil then return nil end
        return {first = first, second = second}
    end, function()
        local min, max: number? = 0, nil
        if self.SizeHint and other.SizeHint then
            local min1, max1 = self.SizeHint()
            local min2, max2 = other.SizeHint()
            min = math.min(min1, min2)
            max = math.min(max1 or min1, max2 or min2)
        elseif self.SizeHint then
            min, max = self.SizeHint()
        elseif other.SizeHint then
            min, max = other.SizeHint()
        end
        return min, max
    end)
end

function Iterator.Enumerate<Item>(self: Iterator<Item>): Iterator<Pair<number, Item>>
    return Iterator.iota(0, 1):Zip(self)
end

-- Iterator Consumers

function Iterator.Fold<Item, Accumulator>(self: Iterator<Item>, folder: (Accumulator, Item) -> Accumulator, initial: Accumulator): Accumulator
    local accumulator = initial
    for item in self.Next do
        accumulator = folder(accumulator, item)
    end
    return accumulator
end

function Iterator.Reduce<Item>(self: Iterator<Item>, reducer: (Item, Item) -> Item): Item?
    local initial = self.Next()
    if initial == nil then return nil end
    return self:Fold(reducer, initial)
end

function Iterator.ForEach<Item>(self: Iterator<Item>, action: (Item) -> ()): ()
    for item in self.Next do
        action(item)
    end
end

function Iterator.Drain<Item>(self: Iterator<Item>): ()
    for _ in self.Next do end
end

function Iterator.Any<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): boolean
    for item in self.Next do
        if predicate(item) then return true end
    end
    return false
end

function Iterator.All<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): boolean
    for item in self.Next do
        if not predicate(item) then return false end
    end
    return true
end

function Iterator.Find<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): Item?
    for item in self.Next do
        if predicate(item) then return item end
    end
    return nil
end

function Iterator.Position<Item>(self: Iterator<Item>, predicate: (Item) -> boolean): number?
    local index = 1
    for item in self.Next do
        if predicate(item) then return index end
        index += 1
    end
    return nil
end

function Iterator.Count<Item>(self: Iterator<Item>): number
    local count = 0
    for item in self.Next do
        count += 1
    end
    return count
end

function Iterator.Collect<Item>(self: Iterator<Item>): {Item}
    local capacity = 0
    if self.SizeHint then
        local min, max = self.SizeHint()
        capacity = max or min
    end

    // print(`Collect allocated {capacity} items`)
    local result = table.create(capacity)
    for item in self.Next do
        table.insert(result, item)
    end
    return result
end

function Iterator.Unzip<FirstItem, SecondItem>(self: Iterator<Pair<FirstItem, SecondItem>>): ({FirstItem}, {SecondItem})
    local capacity = 0
    if self.SizeHint then
        local min, max = self.SizeHint()
        capacity = max or min
    end
    local first = table.create(capacity)
    local second = table.create(capacity)
    for pair in self.Next do
        table.insert(first, pair.first)
        table.insert(second, pair.second)
    end
    return first, second
end

return Iterator
