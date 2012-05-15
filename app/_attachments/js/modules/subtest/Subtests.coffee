class Subtests extends Backbone.Collection
  
  url: "subtest"
  model: Subtest

  comparator: (subtest) ->
    subtest.get "order"
  
  initialize: (options) ->

  fetch: (options) ->
    super options

  # call this after you load the collection you're going to be working with
  maintainOrder: ->
    test = (model.get("order") for model in @models).join("")
    ordered = (i for model,i in @models).join("")
    if test != ordered
      for subtest, i in @models
        subtest.set "order", i
        subtest.save()
  
