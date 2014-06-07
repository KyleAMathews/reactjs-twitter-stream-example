# @cjsx React.DOM

React = require 'react'
Tweets = require './tweets'

module.exports = React.createClass
  getInitialState: ->
    @lastRender = 0

    return {
      text: ''
      tweets: []
      following: ''
      clientsCount: 0
    }

  componentWillMount: ->
    @socket = io()
    @socket.on 'clientsCount', (count) =>
      @setState clientsCount: count

    @socket.on 'newFilter', (filter) =>
      @setState
        following: filter
        tweets: []

    @socket.on 'tweet', (tweet) =>
      newTweets = [tweet].concat @state.tweets
      if newTweets.length > 20
        newTweets.pop()

      @setState tweets: newTweets

  onChange: (e) ->
    @setState text: e.target.value

  handleSubmit: (e) ->
    e.preventDefault()
    @socket.emit('newFilter', @state.text)
    @setState
      following: @state.text
      text: ''
      tweets: []

  render: ->
    if @state.tweets.length > 0
      following = <h2>Streaming tweets matching "{@state.following}" to 
      {@state.clientsCount} client(s)</h2>

    return (
      <div>
        <h1>Follow the realtime Twitter stream!</h1>
        <p>Enter comma-seperated keywords and press follow to ride the twitterstream.</p>
        <form onSubmit={@handleSubmit}>
          <input onChange={@onChange} value={@state.text} placeholder="apple,banana" />
          <button>Follow</button>
        </form>
        {following}
        <Tweets tweets={@state.tweets} following={@state.following}></Tweets>
      </div>
    )
