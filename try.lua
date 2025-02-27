local colors  = _G.colors
local fs      = _G.fs
local os      = _G.os
local UI      = require('opus.ui')
local Util    = require('opus.util')

-- Variables pour stocker les paramètres de sécurité
local isBootDisabled = false
local isLockEnabled  = false

-- Fonction pour désactiver le démarrage depuis des périphériques externes (comme une disquette)
local function disableBootFromDisk()
    -- Simulation de la désactivation du démarrage depuis un périphérique externe.
    -- Vous pouvez ici ajouter des appels spécifiques pour votre environnement.
    print("Démarrage depuis des disquettes désactivé.")
    isBootDisabled = true
end

-- Fonction pour activer le verrouillage de certaines zones du système
local function enableSystemLock()
    -- Simuler un verrouillage du système.
    -- Ce pourrait être un verrouillage des fichiers système ou un mot de passe pour y accéder.
    print("Verrouillage du système activé.")
    isLockEnabled = true
end

-- Fonction pour réinitialiser les sécurités
local function resetSecuritySettings()
    print("Réinitialisation des paramètres de sécurité...")
    isBootDisabled = false
    isLockEnabled = false
end

-- Créer l'interface utilisateur avec différentes pages
local page = UI.Page {
    backgroundColor = colors.blue,
    titleBar = UI.TitleBar {
        title = "Sécurisation du PC",
    },
    notification = UI.Notification(),
    accelerators = {
        q = 'quit',
    },
}

-- Page principale avec les options de sécurité
local mainPage = UI.Window {
    titleBar = UI.TitleBar {
        title = "Options de Sécurité",
    },
    buttons = {
        UI.Button {
            text = "Désactiver le démarrage depuis une disquette",
            event = 'disable_boot',
            x = 2, y = 2,
        },
        UI.Button {
            text = "Activer le verrouillage du système",
            event = 'enable_lock',
            x = 2, y = 4,
        },
        UI.Button {
            text = "Réinitialiser les paramètres de sécurité",
            event = 'reset_security',
            x = 2, y = 6,
        },
    },
    accelerators = {
        q = 'quit',
    },
    eventHandler = function(self, event)
        if event.type == 'quit' then
            UI:exitPullEvents()
        elseif event.type == 'disable_boot' then
            disableBootFromDisk()
        elseif event.type == 'enable_lock' then
            enableSystemLock()
        elseif event.type == 'reset_security' then
            resetSecuritySettings()
        end
        return true
    end,
}

-- Page pour afficher le statut actuel de la sécurité
local statusPage = UI.Window {
    titleBar = UI.TitleBar {
        title = "Statut de Sécurité",
    },
    text = UI.TextArea {
        x = 2, y = 3, ex = -2, ey = -2,
    },
    accelerators = {
        q = 'quit',
    },
    eventHandler = function(self, event)
        if event.type == 'quit' then
            UI:exitPullEvents()
        end
        return true
    end,
}

-- Fonction pour mettre à jour le statut de sécurité
local function updateStatusPage()
    local statusText = "Sécurité actuelle :\n"
    statusText = statusText .. (isBootDisabled and "Démarrage depuis disquette : Désactivé\n" or "Démarrage depuis disquette : Activé\n")
    statusText = statusText .. (isLockEnabled and "Verrouillage du système : Activé\n" or "Verrouillage du système : Désactivé\n")
    statusPage.text:setText(statusText)
end

-- Ajouter les pages à l'application
UI:addPage('main', mainPage)
UI:addPage('status', statusPage)

-- Activer la page principale au lancement
UI:setPage('main')

-- Afficher la page de statut après chaque modification de la sécurité
local function displayStatusPageAfterChange()
    updateStatusPage()
    UI:setPage('status')
end

-- Lancer l'application
local success, errorMsg = pcall(function()
    UI:start()
end)

if not success then
    UI.term:reset()
    _G.printError(errorMsg)
end
