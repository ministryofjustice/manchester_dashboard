class Dashing.TakeoverImage extends Dashing.Widget
 
  onData: (data) ->
    # clear all other takeovers
    $('.widget-takeover, .widget-takeover-image').clearQueue().hide()

    now = Math.round(new Date().getTime() / 1000)
    delay = 30000
    delay = parseInt(data.delay) * 1000 if data.delay?
    path = data.path or ""
    if @updatedAt > Math.round(new Date().getTime() / 1000) - 10
      $(@node).find(".background").attr("style", "background-image: url(#{path})")
      $(@node).clearQueue().hide().fadeIn(200).delay(delay).fadeOut(500)
      # document.getElementById('alert').play();