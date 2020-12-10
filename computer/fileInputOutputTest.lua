os.loadAPI("API_update")
API_update.MF_CheckForUpdates()

function FileIOTest()
    fileName = "test.txt"

    file = fs.open(fileName, "w")

    file.write("TESTING\nTESTING")

    file.close()
end