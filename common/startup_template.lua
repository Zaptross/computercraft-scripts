-- Require update script, then check for updates
os.loadAPI("API_update.lua")
API_update.MF_CheckForUpdates()


os.loadAPI("API_perip.lua")
os.loadAPI("API_args.lua")
os.loadAPI("API_coms.lua")


shell.run("main.lua")