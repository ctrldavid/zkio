redis = require 'redis'
client = redis.createClient()

monitorClient = redis.createClient()
monitorClient.monitor()
monitorClient.on 'monitor', (time, args) ->
  console.log "Monitor Event @#{time}: #{args}"

client.on 'error', (err) ->
  console.error err

client.set 'string key', 'string val', redis.print
client.hset 'hash key', 'hashtest 1', 'some value', redis.print
client.hset ['hash key', 'hashtest 2', 'some other value'], redis.print
client.hkeys 'hash key', (err, replies) ->
  console.log "#{replies.length} replies:"
  console.log "  #{i}: #{reply}" for reply, i in replies
  client.quit()


console.log client.command_queue.length