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
        let selected = document.getElementById('selected')
        if (selected) {
            showSelector(selected)
        }
    },
    mounted() {
        console.log('mounted')
    }
}

let showSelector = (selected) => {
    let selector = document.getElementById('selector')
    let rect = selected.getBoundingClientRect()
    selector.style.top = rect.top
    selector.style.left = rect.left
    selector.style.display = 'inline-block'
    selected.style.display = 'none'
}

let hideSelector = () => {
    let selected = document.getElementById('selected')
    let selector = document.getElementById('selector')
    if (selector) {
        selector.style.display = 'none'
        selected.style.display = 'inline-block'
    }
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

window.add_more = add_more

window.onscroll = function(ev) {
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
        add_more()
    }
    hideSelector()
};