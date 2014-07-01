class Dashing.Takeover extends Dashing.Widget
 
  onData: (data) ->
    # clear all other takeovers
    $('.widget-takeover, .widget-takeover-image').clearQueue().hide()

    now = Math.round(new Date().getTime() / 1000)
    delay = 30000
    delay = parseInt(data.delay) * 1000 if data.delay?
    type = data.type or ""
    if @updatedAt > Math.round(new Date().getTime() / 1000) - 10
      $(@node).find('.background').attr("class", "background #{type}")
      $(@node).clearQueue().hide().fadeIn(200).delay(delay).fadeOut(500)
      if type is "warning"
        document.getElementById('alert-tone').play()
      else
        document.getElementById('msg-tone').play()