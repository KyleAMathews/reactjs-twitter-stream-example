# @cjsx React.DOM

React = require 'react'
Tweet = require './tweet'

module.exports = React.createClass
  render: ->
    tweets = @props.tweets.map (tweet) ->
      <Tweet key={tweet.id_str} tweet={tweet} />

    if tweets.length is 0 and @props.following? and @props.following isnt ""
      tweets = <div>
          <br />
          <span>Connecting to Twitter stream for "{@props.following}"</span>
        </div>

    return (
      <div>
        {tweets}
      </div>
    )
