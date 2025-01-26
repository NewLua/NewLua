-- Charger la bibliothèque DFPWM
local dfpwm = require("NewLua.Audio.dfpwm")

-- Trouver une disquette pour le stockage temporaire
local function findDiskDrive()
    for _, side in ipairs(peripheral.getNames()) do
        if peripheral.getType(side) == "drive" and disk.isPresent(side) then
            return side
        end
    end
    return nil
end

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

-- Lecture de fichiers DFPWM (alternative avec playSound)
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

        -- Alternatif : jouer un son via playSound
        -- Simulation de lecture de DFPWM en envoyant des notifications sonores.
        for i = 1, #decoded do
            speaker.playSound("minecraft:block.note_block.bell", decoded[i])
        end
    end

    file.close()
    print("Lecture terminée :", filePath)
end

-- Lecture d'un fichier DFPWM à partir d'une URL, avec gestion de disquette
local function playDFPWMFromURL(url)
    if not http then
        error("L'API HTTP n'est pas activée.")
    end

    local tempFile
    local diskSide = findDiskDrive()

    if diskSide then
        tempFile = disk.getMountPath(diskSide) .. "/temp.dfpwm"
        print("Utilisation de la disquette pour le stockage temporaire :", tempFile)
    else
        tempFile = "/tmp/temp.dfpwm"
        print("Aucune disquette détectée, stockage temporaire local :", tempFile)
    end

    -- Télécharger et jouer le fichier
    downloadFile(url, tempFile)
    playDFPWM(tempFile)

    -- Nettoyer le fichier temporaire
    fs.delete(tempFile)
    print("Fichier temporaire supprimé :", tempFile)
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
