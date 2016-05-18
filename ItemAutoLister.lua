local activeListings = 0;
local IAL_AUCTION_HOUSE_SHOW = false;
local _;

-- Defaults
local IAL_Quality = 2;		-- Green items
local IAL_ReqLevel = 85		-- Level 85 required
local IAL_Class = "Armor"	-- Only Armor is allowed
local IAL_Price = 999999	-- Bid and Buyouts are at 99g 99s 99c
local IAL_Duration = 2		-- Auction duration at 24 hours
local IAL_StackSize = 1		-- Only sell stack of one item
local IAL_NumStacks = 1		-- Only sell one stack

local IAL_Defaults = {{"quality", IAL_Quality}, {"reqlvl", IAL_ReqLevel}, {"class", IAL_Class}, {"price", IAL_Price}, {"duration", IAL_Duration}, {"stacksize", IAL_StackSize}, {"numstacks", IAL_NumStacks}};

-- Determines if item should be auto-listed (uses above congifurable globals.)
function IAL_canListItem(itemID)
	local name;
	local quality;
	local reqLevel;
	local class;
	name, _, quality, _, reqLevel, class, _, _, _, _, _ = GetItemInfo(itemID);	-- Get the item's info (and trash the garbage data).

	if (quality ~=IAL_Quality) then
		return false; 	-- Don't list a non green item.
	end

	if (reqLevel >= IAL_ReqLevel) then
		return false;	-- Don't list a high level item.
	end

	if (class ~= IAL_Class) then
		return false;	-- Don't list non-Armor items.
	end

	return true;
end

-- Gets the number of current listings by the player.
function IAL_updateActiveListingCount()
	local counter = 1;
	while (true) do
		local name = GetAuctionItemInfo("owner", counter);
		if(name == nil) then
			break;
		end
		counter = counter + 1;
	end
	activeListings = counter - 1;
end

-- Lists the item in the given bag's slot.
function IAL_listItem(bag, slot)
	ClearCursor();
	AuctionFrameAuctions.duration = IAL_Duration;	-- Required to stop the listing price error calculations in the Blizz UI.
	PickupContainerItem(bag, slot);
	ClickAuctionSellItemButton();
	StartAuction(IAL_Price, IAL_Price, IAL_Duration, IAL_StackSize, IAL_NumStacks);
	ClearCursor();
end

-- Loops through player's inventory, and adds valid items to the listing table.
function IAL_listNextItem()
	if (not IAL_AUCTION_HOUSE_SHOW) then
		print("Auction House isn't available. Make sure the Auction House window is open.")
		return;
	end

	for bag = 0, 4 do 	-- Loop through the bags
		local slots = GetContainerNumSlots(bag);

		for slot = 1, slots do 	-- Loop through the item slots in the bag
			local itemID = GetContainerItemID(bag, slot);
			if (itemID ~= nil) then
				if (IAL_canListItem(itemID)) then	-- If the item in that slot is 'listable'
					IAL_listItem(bag, slot);
					return;
				end
			end
		end

	end

end

-- Main function for the user.
function ItemAutoLister(args)
	if (args.quality) then
		IAL_Quality = args.quality;
	end

	if (args.reqlvl) then
		IAL_ReqLevel = args.reqlvl;
	end

	if (args.class) then
		IAL_Class = args.class;
	end

	if (args.price) then
		IAL_Price = args.price;
	end

	if (args.duration) then
		IAL_Duration = args.duration;
	end

	if (args.stacksize) then
		IAL_StackSize = args.stacksize;
	end

	if (args.numstacks) then
		IAL_NumStacks = args.numstacks;
	end

	IAL_listNextItem();
end

-- main
-- Create a frame and handle auction house event updates.
local frame = CreateFrame("FRAME", "IAL Frame");

frame:RegisterEvent("AUCTION_HOUSE_SHOW");
frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
frame:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
local function eventHandler(self, event, ...)
	if(event == "AUCTION_HOUSE_SHOW") then
		IAL_AUCTION_HOUSE_SHOW = true;
	end

	if(event == "AUCTION_HOUSE_CLOSED") then
		IAL_AUCTION_HOUSE_SHOW = false;
	end

	if(event == "AUCTION_OWNED_LIST_UPDATE") then
		print("It's probably safe to run the ItemAutoLister macro now.");
	end
end
frame:SetScript("OnEvent", eventHandler);

-- Greeting
print('ItemAutoLister Loaded');
print('To Run: Set up a macro with the text "/run ItemAutoLister{};", (Note the brackets instead of parentheses.) then run the macro.')
print('To Configure: Set up a macro with the text "/run ItemAutoLister{<optional arguments go here>};"');
print('Options are of the format <option>=<value>, and are separated by commas.');
print('An example macro with options might be "/run ItemAutoLister{class="Weapon", duration=3, quality=1};"');
print('This would create listings of your white quality weapons, and list them for 48 hours. (Overwriting the default options seen below.)');
print('Currently implemented options (and their defaults) can be found below.');
for iter = 1, #IAL_Defaults do
	print(' ', IAL_Defaults[iter][1], '=', IAL_Defaults[iter][2]);
end
print('See wowprogramming.com/docs/api/GetItemInfo and wowprogramming.com/docs/api/StartAuction for more info on the option names and required values.');
