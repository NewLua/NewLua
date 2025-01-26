-- Charger la bibliothèque DFPWM
local dfpwm = require("NewLua.Audio.dfpwm")

-- Téléchargement d'un fichier depuis une URL
local function downloadFile(url, outputFile)
    print("Téléchargement du fichier depuis l'URL :", url)
    local response = http.get(url)
    if not response then
        error("Échec du téléchargement depuis l'URL : " .. url)
    end

    local file = fs.open(outputFile, "wb")
    file.write(response.readAll())
    file.close()
    response.close()

    print("Fichier téléchargé et sauvegardé sous :", outputFile)
end

-- Lecture de fichiers DFPWM
local function playDFPWM(filePath)
    local decoder = dfpwm.make_decoder()
    local speaker = peripheral.find("speaker")

    if not speaker then
        error("Aucun périphérique speaker détecté.")
    end

    local file = fs.open(filePath, "rb")
    if not file then
        error("Impossible d'ouvrir le fichier DFPWM : " .. filePath)
    end

    print("Lecture du fichier DFPWM :", filePath)

    while true do
        local chunk = file.read(16 * 1024) -- Lire par blocs de 16 Ko
        if not chunk then break end

        local decoded = decoder(chunk)
        speaker.playAudio(decoded)
    end

    file.close()
    print("Lecture terminée :", filePath)
end

-- Lecture d'un fichier DFPWM à partir d'une URL
local function playDFPWMFromURL(url)
    if not http then
        error("L'API HTTP n'est pas activée.")
    end

    local tempFile = "/tmp/temp.dfpwm" -- Fichier temporaire pour sauvegarder l'audio
    downloadFile(url, tempFile)
    playDFPWM(tempFile)
    fs.delete(tempFile) -- Nettoyer le fichier temporaire après la lecture
end

-- Afficher l'aide de la commande
local function showHelp()
    print("Utilisation : speaker <commande> [arguments]")
    print("Commandes disponibles :")
    print("  playSound <nom> [volume] [pitch]  - Joue un son Minecraft.")
    print("  playDFPWM <fichier>               - Joue un fichier DFPWM local.")
    print("  playURL <url>                     - Télécharge et joue un fichier DFPWM depuis une URL.")
    print("  help                              - Affiche ce message d'aide.")
end

-- Commande principale
local args = {...}

if #args == 0 then
    showHelp()
    return
end

local command = args[1]

if command == "playSound" then
    local name = args[2]
    local volume = tonumber(args[3]) or 1.0
    local pitch = tonumber(args[4]) or 1.0

    if not name then
        error("Nom du son requis. Utilise : speaker playSound <nom> [volume] [pitch]")
    end

    local speaker = peripheral.find("speaker")
    if not speaker then
        error("Aucun périphérique speaker détecté.")
    end

    speaker.playSound(name, volume, pitch)
    print(string.format("Son joué : '%s' (Volume: %.2f, Pitch: %.2f)", name, volume, pitch))

elseif command == "playDFPWM" then
    local filePath = args[2]
    if not filePath then
        error("Chemin du fichier requis. Utilise : speaker playDFPWM <fichier>")
    end
    playDFPWM(filePath)

elseif command == "playURL" then
    local url = args[2]
    if not url then
        error("URL requise. Utilise : speaker playURL <url>")
    end
    playDFPWMFromURL(url)

elseif command == "help" then
    showHelp()

else
    print("Commande inconnue :", command)
    showHelp()
end
