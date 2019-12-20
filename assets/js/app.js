// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import {Socket} from "phoenix"
import {LiveSocket, debug} from "phoenix_live_view"

let Hooks = {}
Hooks.TableHook = {
    updated() {
        let buttons = document.getElementsByClassName('buttons')
        for (let b of buttons) {
            b.addEventListener('click', select)
        }
    },
    mounted() {
        console.log('mounted')
    }
}

let showSelector = (node, date, meal) => {
    let selector = document.getElementById('selector')
    let rect = node.getBoundingClientRect()
    let buttons = selector.children
    for (let b of buttons) {
        b.setAttribute('phx-value-date', date)
        b.setAttribute('phx-value-meal', meal)
    }
    selector.style.top = rect.top
    selector.style.left = rect.left
    selector.style.display = 'inline-block'
}

let hideSelector = () => {
    let selector = document.getElementById('selector')
    selector.style.display = 'none'
}

let select = (event) => {
    let elem = event.target.parentNode
    let date = elem.dataset.date
    let meal = elem.dataset.meal
    showSelector(elem, date, meal)
}

let liveSocket = new LiveSocket("/live", Socket, {viewLogger: debug, hooks: Hooks})
liveSocket.connect()

window.liveSocket = liveSocket;

let add_more = () => {
    let layer = document.getElementsByClassName('main')[0].parentElement
    let view = liveSocket.views[layer.id]
    view.channel.push('event', {
        event: 'view_more',
        type: null,
        value: 3
    }, 20000).receive("ok", resp => { view.update(resp.diff) })
}

window.onscroll = function(ev) {
    if ((window.innerHeight + window.scrollY + 50) >= document.body.offsetHeight) {
        add_more()
    }
    hideSelector()
};