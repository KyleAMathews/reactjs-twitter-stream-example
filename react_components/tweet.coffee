# @cjsx React.DOM

React = require 'react'

module.exports = React.createClass
  render: ->
    return (
      <div style={
        paddingBottom: '7px'
        borderBottom: '1px solid'
        marginBottom: '7px'
        borderColor: '#ccc'
      }>{@props.tweet.text}</div>
    )
