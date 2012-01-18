# config:

fbcomments_host = "localhost:3000"
fbcomments_host = "http://#{fbcomments_host}"

blog_name = "localhost:3001"

# 


fb_init = ->
  FB.init
    appId: "204625772947506"
    status: true
    cookie: true
    xfbml: true

console.log "loading fbcomments"

class FbComments
  
  constructor: (@blog) ->
    console.log "initializing fbcomments"
    @comments = []
    @callback = null


  fetch_from_fb: (callback) ->
    for url in @urls
      $.getJSON this.graph_url(url), (comments) =>
        console.log "fetched ", comments, " from: ", this.graph_url(url)
        comments_data = _(comments).values()[0].data
        for comment in comments_data
          # console.log comment
          this.fetched this.comment_html_fb(comment)
    callback()
  
  latest: (callback) ->
    $.getJSON "#{fbcomments_host}/blogs/#{@blog}/comments", (comments) =>
      console.log "got comments: ", comments
      for comment in comments
        comment = this.comment_html comment
        @comments.push comment
      this.render()
      
  # latest: (callback) ->
  #   post_url = "http://localhost:3001/page1"
  #   post_url = encodeURIComponent post_url
  #   $.getJSON "#{fbcomments_host}/comments/#{post_url}", (comments) =>
  #     console.log "got comments: ", comments
  #     for comment in comments
  #       comment = this.comment_html comment
  #       @comments.push comment
  #     this.render()    
  
  latest_from_fb: (callback) ->
    this.fetch_from_fb ->
      @callback = callback if callback
    
  fetched: (comment) ->
    @comments.push comment
    this.render() if @comments.size == @urls.size
    
  render: ->
    $(".fb_comments").html @comments.join("\n")
    @callback() if @callback
  
  graph_url: (url) ->
    "https://graph.facebook.com/comments/?ids=#{url}"

  # views:
  
  
  comment_html: (c) ->
    "
    <div class='fbc_comment'>
      <fb:profile-pic uid='#{c.user_id}' linked='true'></fb:profile-pic>
      <div class='fbc_from'>
          <fb:name uid='#{c.user_id}' linked='true'></fb:name> commented on <a href='#{c.post.url}'>#{c.post.name}</a> (sul blog generale:) in TITOLO_BLOG
      </div>
      <div class='fbc_message'>#{c.text}</div>
      </div>
    </div>"
    
  comment_html_fb: (comment) ->
    "
    <div class='fbc_comment'>
      <fb:profile-pic uid='#{comment.from.id}' linked='true'></fb:profile-pic>
      <div class='fbc_from'>#{comment.from.name}</div>
      <div class='fbc_message'>#{comment.message}</div>
    </div>"


##
    



$ ->




  $("body").bind "page_loaded", ->
    
    window.fbAsyncInit = ->
      fb_init()
      
      # cool but no
      #
      # fbc_subscribe = (comm) ->
      #   id = comm.commentID
      #   url = encodeURIComponent comm.href
      #   text = "blabla"
      #   console.log "comment post: ", comm
      # 
      #   $.post "#{fbcomments_host}/comments/#{url}", { fb_id: id, text: text, blog: blog_name }, (data) ->
      #     console.log "comment inserted", data
      #
      # FB.Event.subscribe 'comment.create', (comm) ->
      #   fbc_subscribe comm
      #   
      # FB.Event.subscribe 'comment.remove', (comm) ->
      #   id = comm.commentID
      #   url = comm.href
      #   console.log "deleted comment:", resp
      #   $.ajax { 
      #     url: "#{fbcomments_host}/comments", 
      #     type: 'delete', 
      #     success: (data) ->
      #       console.log "comment deleted", data            
      #   }
      
      FB.getLoginStatus (response) ->  
        if response.status == "connected"
          $(".nav_right").append "Logged in as user: #{response.session.uid}"
        else
          $(".fb-login-button").fadeIn()
      
    ((d) ->
      js = undefined
      id = "facebook-jssdk"
      return  if d.getElementById(id)
      js = d.createElement("script")
      js.id = id
      js.async = true
      js.src = "//connect.facebook.net/en_US/all.js"
      d.getElementsByTagName("head")[0].appendChild js
    ) document
  
  $("body").bind "page_js_loaded", ->
    fb_init()
  
  
    
  # 
  
  home_page = ->
    fbcomm = new FbComments blog_name
    comments = fbcomm.latest  ->
      console.log fbcomm
      # fb_init()    
    # fb_init()
    # fbcomm.fetch_from_fb()
    
  
  $("body").bind "page_loaded", ->
    home_page()
    
  $("body").bind "page_js_loaded", ->
    home_page()
