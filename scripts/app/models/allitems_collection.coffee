define [
  "backbone"
], (
  Backbone
) ->
  class AllItems extends Backbone.Collection


    favorites: (limit) ->
      items = @filter (m) -> m.get("type") isnt "menu" and m.get("clicks") > 0
      items.sort (a, b) -> b.get("clicks") - a.get("clicks")
      items = items.slice(0, limit) if limit
      return items

