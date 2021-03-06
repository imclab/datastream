$ ->
  window.data = []
  socket = io.connect 'http://localhost:3000'
  socket.emit 'test',{a: "b"}
  socket.on 'welcome',(data) ->
    console.log(data)
  socket.on 'data', (data) ->
    console.log "data recieved", data
    if ! window.data[data.set]?
      window.data[data.set] = []
    window.data[data.set].push {time: data.data.timestamp, value: data.data.value}
    if window.data[data.set].length > 15
      window.data[data.set] = window.data[data.set].slice(-15)
  $('.setlist').on 'click',(e) ->
    console.log "subscribing to #{e.target.id}"
    socket.emit 'subscribe', {name: e.target.id}
  $.ajax
    url: '/sets'
    success: (d,s,xhr) ->
      list = $('.setlist')
      for i in d.sets
        list.append "<li class='dataset' id='#{i.name}'>#{i.name}</li>"
    failure: (d,s,xhr) ->
      $('.errors').append "There was an error getting the set list"

  w = 20
  h = 80
  x = d3.scale.linear().domain([0,1]).range([0,w])
  y = d3.scale.linear().domain([0,100]).rangeRound([0,h])

  redraw = (current)->
    rect = chart.selectAll("rect").data window.data["asdf"],(d,i) -> d.time

    rect.enter().insert("svg:rect", "line")
      .attr("x", (d,i) -> return x(i+1) - 0.5)
      .attr("y", (d) -> h - y(d.value) - .5)
      .attr("height", (d) -> y(d.value))
      .attr("width", -> 20)
      .transition()
      .duration(500)
      .attr("x", (d,i) -> x(i) - .5)

    rect.transition()
      .duration(500)
      .attr("x",(d,i) -> x(i) - .5)

    rect.exit().transition()
      .duration(500)
      .attr("x", (d,i) -> x(i-1) - .5)
      .remove()

  chart = d3.select("body")
    .append("svg:svg")
    .attr("class","chart")
    .attr("width", 600)
    .attr("height", 100)
  chart.selectAll("rect")
    .data([])
    .enter().append("svg:rect")
    .attr("d", (d) -> d)
    .attr("i", (d,i) -> i)
    .attr("height", (d) -> d.value)
    .attr("x", (d,i) -> x(i) - 0.5)
    .attr("y", (d) -> h - y(d.value) - 0.5)
#  chart.append("svg:line")
#    .attr("x1",0)
#    .attr("x2",w * window.data["asdf"].length())
#    .attr("y1",h - .5)
#    .attr("y2",h - .5)
#    .attr("stroke","#000")


