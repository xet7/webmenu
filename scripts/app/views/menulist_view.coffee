define [
  "backbone.viewmaster"

  "cs!app/application"
  "cs!app/views/menuitem_view"
  "hbs!app/templates/menulist"
], (
  ViewMaster

  Application
  MenuItemView
  template
) ->
  class MenuListView extends ViewMaster

    className: "bb-menu"

    template: template

    constructor: (opts) ->
      super

      @initial = @model
      @setCurrent()
      @firstApp = null
      @firstAppIndex = 0

      @listenTo Application.global, "select", (model) =>
        if model.get("type") is "menu"
          @model = model
          @setCurrent()
          @refreshViews()

      if FEATURE_SEARCH
        @listenTo Application.global, "search", (filter) =>
          if filter.trim()
            @setItems @collection.searchFilter(filter)
            @setStartApplication(0)
          else
            @setCurrent()
          @refreshViews()

        @listenTo Application.global, "startFirstApplication",  =>
          if @firstApp?.model
            Application.bridge.trigger "open", @firstApp.model.toJSON()
            @firstApp = null

        @listenTo Application.global, "nextFirstApplication", =>
          @setStartApplication(@firstAppIndex + 1)
          console.log "fistAppIndex: ", @firstAppIndex

    setRoot: ->
      @setItems(@initial.items.toArray())

    setCurrent: ->
      @setItems(@model.items.toArray())

    setItems: (models) ->
      @setView ".menu-app-list", models.map (model) ->
        new MenuItemView
          model: model

    setStartApplication: (index) ->
      @firstApp.hideSelectHighlight() if @firstApp
      @firstAppIndex = index
      @firstApp = @getViews(".menu-app-list")?[@firstAppIndex]
      @firstApp.displaySelectHighlight()
