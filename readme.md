qb-core/shaed/main.lua

remove line 76: ['driver_license'] = { amount = 1, item = 'driver_license' }, 



qb-core/server/player.lua

change line 106 from ['driver] = true to false



Add the following to qb-core/shaed/items.lua

['driving_test_permit'] 				 = {['name'] = 'driving_test_permit',				['label'] = 'Driving Test Permit',			['weight'] = 0,			['type'] = 'item',		['image'] = 'driving_test_permit.png',		['unique'] = true,		['useable'] = true,		['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'Permite for Driving Test'},

Add the image from img folder into qb-inventory/html/images


Once images added  can remove the folder.
