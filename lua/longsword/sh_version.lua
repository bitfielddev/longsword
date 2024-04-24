function longsword.checkForUpdates()
    if not longsword.config.shouldCheckForUpdates then return end

    longsword.print("Checking for updates...")
    HTTP({
        type = "application/json; charset=utf-8",
        method = "GET",
        url = "https://api.github.com/repos/bitfielddev/longsword/tags",
        timeout = 5,
        success = function(code, body, headers)
            data = util.JSONToTable(body)
            tag = data[1].name

            longsword.modified = true

            for index, tagData in pairs(data) do
                if tagData.name == longsword.version then
                    longsword.modified = false
                end
            end

            if longsword.modified then
                longsword.print("You are running a modified version of longsword.")
                return
            end


            longsword.print(longsword.version != tag and ("You are running longsword " .. longsword.version .. ", while the latest version is " .. tag .. ".") or ("You are up-to-date!"))

            

        end,
        failed = function(reason)
            longsword.print("Could not check for update from GitHub!")
        end
    })
end

hook.Add("Initialize", "longswordCheckUpdates", function()
    longsword.checkForUpdates()
end)
