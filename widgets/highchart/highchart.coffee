class Dashing.Highchart extends Dashing.Widget

  @accessor 'current', Dashing.AnimatedValue

  onData: (data) ->
    obj = @get('data')

    obj['chart']['renderTo'] = @node
    setTimeout ( ->
      @chart = new Highcharts.Chart(
        obj
      )
    ), 1000
