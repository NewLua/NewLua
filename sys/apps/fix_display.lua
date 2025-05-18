local function fixDisplay()
  -- Sauvegarde des paramètres actuels
  local oldTerm = term.current()
  
  -- Réinitialisation du terminal
  term.reset()
  
  -- Nettoyage de l'écran
  term.clear()
  term.setCursorPos(1,1)
  
  -- Restauration des buffers graphiques
  if term.native then
    term.redirect(term.native())
  end
  
  -- Réinitialisation des couleurs
  if term.setBackgroundColor then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
  end
  
  -- Restauration du terminal original
  if oldTerm then
    term.redirect(oldTerm)
  end
  
  -- Force le rafraîchissement de l'écran
  os.queueEvent("term_resize")
  
  print("Réparation de l'affichage terminée")
  print("Redémarrez votre ordinateur si le problème persiste")
end

-- Exécution de la réparation
fixDisplay() 