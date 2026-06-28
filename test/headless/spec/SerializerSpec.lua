-- luacheck: ignore 143

--[[
  Tests for the generic table (de)serializer (code/Serializer.lua).
]]--

describe("Serializer", function()
  local serializer = rgp.serializer

  it("round-trips a representative Pulse config", function()
    local original = {
      lockEnergyBar = true,
      energyBarWidth = 200,
      energyBarHeight = 45,
      frames = {
        P_EnergyBar = {
          point = "CENTER",
          relativePoint = "CENTER",
          relativeTo = false,
          posX = 12.5,
          posY = -30.25
        }
      }
    }

    assert.are.same(original, serializer.Deserialize(serializer.Serialize(original)))
  end)

  it("round-trips booleans, numbers, empty strings and deep nesting", function()
    local original = {
      yes = true,
      no = false,
      zero = 0,
      negative = -17.25,
      empty = "",
      nested = { a = { b = { c = { d = 1 } } } }
    }

    assert.are.same(original, serializer.Deserialize(serializer.Serialize(original)))
  end)

  it("is immune to type tags and delimiters embedded in string values", function()
    -- a naive delimiter parser would choke on these; length-prefixing must not
    local original = {
      tricky = "t3:looks like a table z T F n2:99",
      colons = "a:b:c:d",
      newline = "line1\nline2\ttabbed"
    }

    assert.are.same(original, serializer.Deserialize(serializer.Serialize(original)))
  end)

  it("returns nil plus an error for truncated input", function()
    local encoded = serializer.Serialize({ key = "value", other = 1 })
    local result, err = serializer.Deserialize(string.sub(encoded, 1, #encoded - 4))

    assert.is_nil(result)
    assert.is_string(err)
  end)

  it("returns nil for empty and non-string input without raising", function()
    assert.is_nil(serializer.Deserialize(""))
    assert.is_nil(serializer.Deserialize(nil))
    assert.is_nil(serializer.Deserialize(42))
  end)

  it("rejects trailing garbage after a valid value", function()
    local encoded = serializer.Serialize({ a = 1 })

    assert.is_nil(serializer.Deserialize(encoded .. "garbage"))
  end)

  it("rejects a malformed length prefix", function()
    assert.is_nil(serializer.Deserialize("s999:short"))
  end)
end)
