local Iterator = require('iterator')

local function isEven(x: number): boolean
    return x % 2 == 0
end

-- Prints the first 5 even numbers from 0 (exclusive)
-- 2, 4, 6, 8, 10
Iterator.iota(0, 1):Filter(isEven):Take(5):ForEach(print)
