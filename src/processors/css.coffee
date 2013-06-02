
path = require 'path'

# Regex for detecting & adjusting URLs of fingerprinted/compressed assets referred in .css files
# From https://github.com/icflorescu/aspa/blob/master/lib/aspa.iced#L28
stylesheetAssetUrlPattern = ///
  url\(             # url(
  [\'\"]?           # optional ' or "
  ([^\?\#\'\"\)]+)  # file                                       -> file
  ([^\'\"\)]*)      # optional suffix, i.e. #iefix in font URLs  -> suffix
  [\'\"]?           # optional ' or "
  \)                # )
///gi

findAssetUrl = (manager, assetPath, cssPath, options)->
  # Firs try to find already asseted file
  if manager.get(assetPath)?
    return manager.get(assetPath)

  fullPath = path.join(path.dirname(cssPath), assetPath)
  if manager.get(fullPath)?
    return manager.get(fullPath)

  # If not exists try to make asset
  if manager.process(assetPath, fullPath, options)
    return manager.get(assetPath)
  # Without changes
  return assetPath

module.exports = (manager, filename, content, options)->
  content = content.toString()
  content = content.replace stylesheetAssetUrlPattern, (src, assetPath, suffix) ->
    url = findAssetUrl(manager, assetPath, filename, options)
    return "url(\"#{url}#{suffix}\")"
  return content
