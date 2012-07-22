express = require 'express'
jade = require 'jade'
fs = require 'fs'

console.log 'Loading files'

index = jade.compile fs.readFileSync './app/templates/index.jade', 'utf8'

console.log 'Loading Complete'

posts = [
  {title: 'Post number 1', summary: 'Some kind of summary - Some kind of summary - Some kind of summary - Some kind of summary - Some kind of summary'}
  {title: 'Post number 2', summary: 'Some kind of summary - Some kind of summary - Some kind of summary - Some kind of summary - Some kind of summary'}
]

console.log jade.doctypes

app = express.createServer()

app.get '/blog/:id', (req, res) ->
  res.send 'sup son2' + req.params.id

app.get '/blog/', (req, res) ->
  console.log index
  console.log index items:posts

  res.send index items:posts

app.listen 3000