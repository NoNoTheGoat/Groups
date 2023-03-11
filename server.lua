-- Define the blacklisted names
local blacklist = {
    "nword",
    "fag",
    "cunt",
    -- Add more names here
}

-- Create the group table
local groups = {}

-- Register the command
RegisterCommand("group", function(source, args)
    local cmd = args[1]
    local playerName = GetPlayerName(source)

    -- Create a group
    if cmd == "create" then
        local groupName = args[2]

        -- Check if the group name is blacklisted
        if IsNameBlacklisted(groupName) then
            TriggerClientEvent("chatMessage", source, "^1Error: Group name contains blacklisted words.")
            return
        end

        -- Check if the group name is already taken
        if groups[groupName] then
            TriggerClientEvent("chatMessage", source, "^1Error: Group name is already taken.")
            return
        end

        -- Create the group
        groups[groupName] = {
            leader = playerName,
            members = {
                [playerName] = "leader"
            }
        }

        TriggerClientEvent("chatMessage", source, "^2Success: Group '" .. groupName .. "' created!")
    
    -- Join a group
    elseif cmd == "join" then
        local groupName = args[2]

        -- Check if the group exists
        if not groups[groupName] then
            TriggerClientEvent("chatMessage", source, "^1Error: Group does not exist.")
            return
        end

        -- Check if the player is already in the group
        if groups[groupName].members[playerName] then
            TriggerClientEvent("chatMessage", source, "^1Error: You are already in the group.")
            return
        end

        -- Join the group
        groups[groupName].members[playerName] = "member"
        TriggerClientEvent("chatMessage", source, "^2Success: You have joined the group '" .. groupName .. "'!")

    -- Show group info
    elseif cmd == "info" then
        local groupName = GetPlayerGroup(playerName)

        -- Check if the player is in a group
        if not groupName then
            TriggerClientEvent("chatMessage", source, "^1Error: You are not in a group.")
            return
        end

        -- Get the group info
        local leader = groups[groupName].leader
        local members = groups[groupName].members

        -- Show the group info
        TriggerClientEvent("chatMessage", source, "^2Group Name: " .. groupName)
        TriggerClientEvent("chatMessage", source, "^2Leader: " .. leader)
        TriggerClientEvent("chatMessage", source, "^2Members:")

        for member, role in pairs(members) do
            TriggerClientEvent("chatMessage", source, "^2 - " .. member .. " (" .. role .. ")")
        end

    -- Assign a role to a member
    elseif cmd == "role" then
        local groupName = GetPlayerGroup(playerName)

        -- Check if the player is the leader of the group
        if playerName ~= groups[groupName].leader then
            TriggerClientEvent("chatMessage", source, "^1Error: Only the group leader can assign roles.")
            return
        end

        local memberName = args[2]
        local roleName = args[3]

        -- Check if the member is in the group
        if not groups[groupName].members[memberName] then
            TriggerClientEvent("chatMessage", source, "^1Error: Member is not in the group.")
            return
        end
    
        -- Check if the role is valid
        if roleName ~= "leader" and roleName ~= "member" then
            TriggerClientEvent("chatMessage", source, "^1Error: Invalid role.")
            return
        end
    
        -- Assign the role
        groups[groupName].members[memberName] = roleName
        TriggerClientEvent("chatMessage", source, "^2Success: " .. memberName .. " is now a " .. roleName .. " of the group!")
    
    -- Leave the group
    elseif cmd == "leave" then
        local groupName = GetPlayerGroup(playerName)
    
        -- Check if the player is in a group
        if not groupName then
            TriggerClientEvent("chatMessage", source, "^1Error: You are not in a group.")
            return
        end
    
        -- Check if the player is the leader of the group
        if playerName == groups[groupName].leader then
            TriggerClientEvent("chatMessage", source, "^1Error: You cannot leave the group as the leader. Use /group delete instead.")
            return
        end
    
        -- Leave the group
        groups[groupName].members[playerName] = nil
        TriggerClientEvent("chatMessage", source, "^2Success: You have left the group.")
    
    -- Delete the group
    elseif cmd == "delete" then
        local groupName = GetPlayerGroup(playerName)
    
        -- Check if the player is the leader of the group
        if playerName ~= groups[groupName].leader then
            TriggerClientEvent("chatMessage", source, "^1Error: Only the group leader can delete the group.")
            return
        end
    
        -- Delete the group
        groups[groupName] = nil
        TriggerClientEvent("chatMessage", source, "^2Success: Group '" .. groupName .. "' deleted!")
    
    -- Invalid command
    else
        TriggerClientEvent("chatMessage", source, "^2Error: Make sure you follow;")
        TriggerClientEvent("chatMessage", source, "^2HowTo:  /group [Create/Delete/Join/Leave/Info] [Group Name].")
    end
    end)

    -- Check if a name is blacklisted
    function IsNameBlacklisted(name)
    for i, blacklistedName in ipairs(blacklist) do
    if string.find(name, blacklistedName, 1, true) then
    return true
    end
    end

    return false
    end

    -- Get the name of the group the player is in
    function GetPlayerGroup(playerName)
    for groupName, groupData in pairs(groups) do
    if groupData.members[playerName] then
    return groupName
    end
    end

    return nil
    end