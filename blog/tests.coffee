Fiber = require 'fibers'
Future = require 'fibers/future'
wait = Future.wait

sleep = (ms) ->
  future = new Future
  setTimeout ->
    future.return()
  , ms
  future

calc = (ms) ->
  start = new Date
  sleep(ms).wait()
  new Date - start

calc = calc.future()

calc(500).resolve (e, v) ->
  console.log v


console.log 'a'

Fiber(->
  console.log 'in fiber'
  
  sleep(50).wait()

  console.log 'after fiber'  
).run()

console.log 'c'
