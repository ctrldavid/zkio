express = require 'express'
app = express.createServer()

app.get '/blog/:id', (req, res) ->
  res.send 'sup son2' + req.params.id


app.get '/blog/', (req, res) ->
  res.send 'sup son'

app.listen 3000