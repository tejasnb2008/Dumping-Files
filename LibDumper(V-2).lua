local gg=gg

function toHex(val)
  return string.format('%x', val)
end

function renameFile(starting, ending, pathing, naming)
  local oldPath = pathing..'/'..info.packageName..'-'..toHex(starting)..'-'..toHex(ending)..'.bin'
  local newPath = pathing..'/'..naming
  os.rename(oldPath, newPath)
  print('\nSuccess!\n\nFile Path is \n--> '..newPath)
end

function getEnd(lib)
  local t = gg.getRangesList(lib)
  return t[#t]['end']-1
end

function getLib(index, path)
  if not os.rename(path, path) then
    return print('Invalid Path.')
  end
  local fullPath=path..'/'..names[index]
  local old = io.open(lib_t[index].internalName, "rb")
  local new = io.open(fullPath, "wb")
  local old_size, new_size = 0, 0
  while true do
    local block = old:read(2^13)
    if not block then 
      old_size = old:seek( "end" )
      break
    end
    new:write(block)
  end
  old:close()
  new_size = new:seek( "end" )
  new:close()
  print('\nSuccess!\n\nFile Path is \n--> '..fullPath)
end

function dumpLib(index, path)
  if not os.rename(path, path) then
    return print('Invalid Path.')
  end
  local starting = lib_t[index].start
  local ending = lib_t[index].endForDump
  local naming = '(start address- '..toHex(starting)..')'..names[index]
  gg.dumpMemory(starting, ending, path)
  renameFile(starting, ending+1, path, naming)
end

function dumpMetadata(path)
  if not os.rename(path, path) then return print('Invalid Path.') end
  local t = gg.getRangesList('global-metadata.dat')
  if not t[1] then return print('This game \"'..info.label..'\" does not have global-metadata.dat') end
  local starting = t[1].start
  local ending = t[1]['end']
  gg.dumpMemory(starting, ending-1, path)
  renameFile(starting, ending, path, 'global-metadata.dat')
end

function Lib()
  ::menuAgain::
  local menu = gg.choice(names, largestLib, 'These are suitable libs to dump\nChoose the One\n\nRecommended One: '..names[largestLib])
  if not menu then return main() end
  ::there::
  local output = gg.prompt({'Choose Path for Output','Methods (slide bar) :[1;2]', 'Click true to know About two methods'},{'/sdcard/dump'}, {'path','number', 'checkbox'})
  if not output then goto menuAgain end
  if output[3] then gg.alert('-> Method-1 is directly getting lib.so from game. This method is recommended if the lib is normal and not obfuscated\n\n\n-> Some games like freefire, lol wild rift obfuscate their lib. When the game is launched, the obfuscated lib produces its normal lib values into memory process.\n\n\n-> Method-2 gets normal lib values from memory process. This method is recommended if the lib is obfuscated\n\nMy advice for newbies is if method 1 doesnt work, use method 2. Using Method-2 will need his start address.I\'ll add that in resulted lib name.') goto there end
  if output[2]=='1' then getLib(menu, output[1]) end
  if output[2]=='2' then dumpLib(menu, output[1]) end
end

function Metadata()
  local output = gg.prompt({'Choose Path for Output'},{'/sdcard/dump'}, {'path'})
  if not output then return main() end
  dumpMetadata(output[1])
end

function main()
  local menu = gg.choice({'Dump Libil2cpp.so💙', 'Dump Global Metadata-dat❤'}, 0, 'Made by Lover1500')
  if not menu then return print('Cancel!') end
  if menu==1 then Lib()
  elseif menu==2 then Metadata()
  end
end


--Here we go
lib_t={}
names ={}
info = gg.getTargetInfo()
for i, v in ipairs(gg.getRangesList('/data/*.so')) do
  if not string.find(v.internalName, info.packageName) then goto skipLib end
  v.shortName = string.gsub(v.internalName, '.+/', '')
  v.shortName = string.gsub(v.shortName, ':.*', '')
  for a, b in ipairs(lib_t) do
    if b.shortName==v.shortName then goto skipLib end
  end
  v.endForDump = getEnd(v.shortName)
  table.insert(lib_t, v)
  table.insert(names, v.shortName)
  ::skipLib::
end
if #names==0 then return print('This game \"'..info.label..'\" does not have any Libs.\nScript is useless Now') end
largestLib = 0
local diff, temp=0,0
for i, v in ipairs(lib_t) do
  temp = v.endForDump - v.start
  if temp > diff then
    diff = temp
    largestLib=i
  end
end

main()

--Lover1500