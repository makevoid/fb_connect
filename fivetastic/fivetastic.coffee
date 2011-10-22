class FiveTastic
  constructor: ->
    @hamls = []
    # @layout = null
    # @page = null
    
  start: ->  
    this.load_layout()
    this.load_index()
    # console.log "fivetastic started"
    
    
  # 
  
  render: ->
    html = @layout
    html.find("#content").html @page
    html = html.get(1)
    $("body").html html
  
  assign: (name, html) ->
    html = $(html)  
    if name == "layout"
      @layout = html
    else
      @page = html
  
  # events
  
  haml_loaded: (name, html) ->
    haml = _.detect(@hamls, (h) -> h.name == name )
    haml.loaded = true
    all_loaded = _.all(@hamls, (h) -> h.loaded == true)
    this.assign name, html
    this.render() if all_loaded
    html
      
  # haml
    
  load_layout: ->
    this.load_haml "layout"
    
  load_index: ->
    this.load_haml "index"
    
  load_haml: (name) ->
    @hamls.push { name: name, loaded: false }
    $.get "/haml/#{name}.haml", (data) =>
      html = haml.compileStringToJs(data)({})
      this.haml_loaded name, html
      

# go go go!

five = new FiveTastic 
five.start()
  
  
  