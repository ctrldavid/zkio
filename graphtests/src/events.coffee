class Snake.EventEmitter
  on: (name, fnc) ->
    @listeners ||= {}
    @listeners[name] ||= []
    @listeners[name].push fnc
  
  emit: (name, args...) -> 
    if name? && @listeners?[name]
      fnc.apply this, args for fnc in @listeners[name]
