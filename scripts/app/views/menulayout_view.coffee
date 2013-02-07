define [
  "backbone.viewmaster"

  "cs!app/views/menulist_view"
  "cs!app/views/breadcrumbs_view"
  "cs!app/views/profile_view"
  "cs!app/views/favorites_view"
  "cs!app/views/search_view"
  "cs!app/views/lightbox_view"
  "cs!app/views/logout_view"
  "cs!app/application"
  "hbs!app/templates/menulayout"
  "app/utils/debounce"
], (
  ViewMaster

  MenuListView
  Breadcrumbs
  ProfileView
  Favorites
  Search
  Lightbox
  LogoutView
  Application
  template
  debounce
) ->

  class MenuLayout extends ViewMaster

    className: "bb-menu-layout"

    template: template

    constructor: (opts) ->
      super

      @allItems = opts.allItems
      @user = opts.user
      @config = opts.config
      @lightbox = null

      @menuListView = new MenuListView
        model: opts.initialMenu
        collection: opts.allItems

      @setView ".menu-list-container", @menuListView

      @setView ".search-container", new Search

      @breadcrumbs = new Breadcrumbs model: opts.initialMenu
      @setView ".breadcrumbs-container", @breadcrumbs

      @setView ".profile-container", new ProfileView
        model: @user
        config: @config

      @setView ".favorites-container", new Favorites
        collection: @allItems
        config: @config

      @listenTo this, "open-menu", (model, sender) =>
        # Update MenuListView when user navigates from breadcrumbs
        if sender is @breadcrumbs
          @menuListView.broadcast("open-menu", model)
        # Update breadcrums when user navigates from menu tree
        if sender isnt @breadcrumbs
          @breadcrumbs.broadcast("open-menu", model)

      # Connect search events to MenuListView
      @listenTo this, "search", (searchString) =>
        @menuListView.broadcast("search", searchString)


      @listenTo this, "reset", @removeLightbox

      @listenTo this, "open-logout-view", =>
        @displayViewInLightbox new LogoutView
          hostType: @config.get("hostType")

    displayViewInLightbox: (view) ->
      @removeLightbox()
      @lightbox = new Lightbox view: view
      @lightbox.render()
      @lightbox.once "close", =>
        @removeLightbox()

    removeLightbox: ->
      @lightbox?.remove()
      @lightbox = null


