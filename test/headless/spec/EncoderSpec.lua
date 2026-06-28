-- luacheck: ignore 143

--[[
  Tests for the generic byte-string codec (code/Encoder.lua).
]]--

describe("Encoder", function()
  local encoder = rgp.encoder

  it("round-trips strings of every length class", function()
    local samples = { "", "a", "ab", "abc", "abcd", "hello world", string.rep("x", 100) }

    for _, sample in ipairs(samples) do
      assert.are.equal(sample, (encoder.Decode(encoder.Encode(sample))))
    end
  end)

  it("round-trips every byte value 0-255", function()
    local bytes = {}

    for value = 0, 255 do
      bytes[#bytes + 1] = string.char(value)
    end

    local blob = table.concat(bytes)

    assert.are.equal(blob, (encoder.Decode(encoder.Encode(blob))))
  end)

  it("produces only paste-safe characters", function()
    local encoded = encoder.Encode("some payload bytes \1\2\3 with controls")

    assert.is_nil(string.find(encoded, "[^%w+/=]"))      -- only the base64 alphabet
    assert.is_nil(string.find(encoded, "|", 1, true))    -- never the WoW escape char
    assert.is_nil(string.find(encoded, "%s"))            -- no whitespace or newlines
  end)

  it("detects a corrupted character via the checksum", function()
    local encoded = encoder.Encode("important configuration data")
    local firstChar = string.sub(encoded, 1, 1)
    local replacement = firstChar == "A" and "B" or "A"
    local corrupted = replacement .. string.sub(encoded, 2)

    local result, err = encoder.Decode(corrupted)

    assert.is_nil(result)
    assert.are.equal("checksum", err)
  end)

  it("rejects malformed base64", function()
    assert.is_nil(encoder.Decode("not valid base64 !!!"))
    assert.is_nil(encoder.Decode("ABC"))  -- length not a multiple of 4
  end)

  it("rejects empty and non-string input without raising", function()
    assert.is_nil(encoder.Decode(""))
    assert.is_nil(encoder.Decode(nil))
  end)
end)
